//
//  MetalHeapManager+Image.swift
//  muze
//
//  Created by Greg Fajen on 5/14/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

//import UIKit
import Metal
import MetalKit
import MuzePrelude

public extension MTLSize {
    
    init(_ size: CGSize) {
        self = MTLSize(width: Int(size.width), height: Int(size.height), depth: 1)
    }
    
}

public extension MetalHeapManager {
    
    func makeTexture<T>(size fSize: CGSize, pixelFormat: MTLPixelFormat = .rgba32Float, data: UnsafePointer<T>, bytesPerRow: Int) -> MetalTexture? {
        let size = fSize.rounded
        guard let texture = makeTexture(size, pixelFormat, type: .longTerm) else { return nil }
        
        let tex = texture._texture
        let region = MTLRegion(origin: .zero, size: MTLSize(size))
        
        tex.replace(region: region, mipmapLevel: 0, withBytes: data, bytesPerRow: bytesPerRow)
        
        //        let r = data.advanced(by: 0).pointee
        //        let g = data.advanced(by: 1).pointee
        //        let b = data.advanced(by: 2).pointee
        //        let a = data.advanced(by: 3).pointee
        //        print("\(r), \(g), \(b), \(a)")
        
        return texture
    }
    
    func makeTexture(size fSize: CGSize, pixelFormat: MTLPixelFormat = .rgba8Unorm_srgb, _ drawing: ()->()) -> MetalTexture? {
        let size = fSize.rounded
        guard let texture = makeTexture(size, pixelFormat, type: .longTerm) else { return nil }
        texture.colorSpace = .p3
        
        let context = DrawingContext(size: size, scale: 1, bgra: false)
        context.draw {
            context.flip()
            drawing()
        }
        
        let image = context.cgImage
        let bytesPerRow = image.bytesPerRow
        let provider = image.dataProvider!
        let data = provider.data! as Data
        
        let tex = texture._texture
        let region = MTLRegion(origin: .zero, size: MTLSize(size))
        
        data.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) -> () in
            tex.replace(region: region,
                        mipmapLevel: 0,
                        withBytes: ptr.baseAddress!,
                        bytesPerRow: bytesPerRow)
        }
        
        return texture
    }
    
    #if os(iOS)
    func makeTexture(from image: UIImage) -> MetalTexture? {
        let size = image.size * image.scale
        
        return makeTexture(size: size) {
            image.draw(in: .zero & size)
        }
    }
    
    func makeTexture(from buffer: CVImageBuffer, orientation: UIImage.Orientation) -> MetalTexture? {
        #if targetEnvironment(simulator)
        return nil
        #else
        if buffer.isRAW {
            return makeTexture(fromRAW: buffer, orientation: orientation)
        }
        
        var textureCache: CVMetalTextureCache?
        CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, MetalDevice.device, nil, &textureCache)
        
        var cvTex: CVMetalTexture?
        CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCache!, buffer, nil, .bgra8Unorm_srgb, buffer.width, buffer.height, 0, &cvTex)
        
        let tex = MetalTexture(CVMetalTextureGetTexture(cvTex!)!).reoriented(from: orientation)
        
        return tex
        #endif
    }
    
    func makeTexture(fromRAW buffer: CVImageBuffer, orientation: UIImage.Orientation) -> MetalTexture? {
        #if targetEnvironment(simulator)
        return nil
        #else
        var cvTex: CVMetalTexture?
        CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCache, buffer, nil, .r16Unorm, buffer.width, buffer.height, 0, &cvTex)
        
        let tex = MetalTexture(CVMetalTextureGetTexture(cvTex!)!)
        return tex.reoriented(fromRAW: orientation)
        #endif
    }
    #endif
    
}

public extension CVImageBuffer {
    
    var isRAW: Bool {
        switch pixelFormat {
            case kCVPixelFormatType_14Bayer_RGGB: return true
            case kCVPixelFormatType_14Bayer_BGGR: return true
            case kCVPixelFormatType_14Bayer_GBRG: return true
            case kCVPixelFormatType_14Bayer_GRBG: return true
            default: return false
        }
    }
    
}

public extension MetalTexture {
    
    func halved() -> MetalTexture {
        let w = width/2
        let h = height/2
        return resized(to: CGSize(width: w, height: h))
    }
    
    func resized(to newSize: CGSize) -> MetalTexture {
        let target = MetalHeapManager.shared.makeTexture(newSize,
                                                         self.pixelFormat,
                                                         type: .longTerm)!
        
        let targetRect = (.zero & newSize).rectThatFills(size.aspectRatio)
        let transform = AffineTransform(from: .zero & size, to: targetRect)
        let input: RenderPayload = .transforming(.texture(self), transform)
        
        let pass = RenderPassDescriptor(identifier: "resize",
                                        pipeline: .drawPipeline2,
                                        inputs: [input],
                                        clearColor: nil).metalPass(target)
        
        pass.commit()
        pass.buffer.waitUntilCompleted()
        
        return target
    }
    
    #if os(iOS)
    func reoriented(from orientation: ImageOrientation) -> MetalTexture {
        let texture = MetalHeapManager.shared.makeTexture(size.after(orientation),
                                                          self.pixelFormat,
                                                          type: .longTerm)!
        let transform = orientation.inverseTransform(for: size)
        let pass = MetalPass(pipeline: .reorientPipeline,
                             drawable: texture,
                             vertexBuffers: [MetalPipeline.defaultVertexBuffer],
                             fragmentBuffers: [transform],
                             fragmentTextures: [_texture])
        
        pass.commit()
        
        pass.buffer.waitUntilCompleted()
        
        return texture
    }
    
    func reoriented(fromRAW orientation: ImageOrientation) -> MetalTexture {
        let texture = MetalHeapManager.shared.makeTexture(size.after(orientation),
                                                          .rgba16Float,
                                                          type: .longTerm)!
        let transform = orientation.inverseTransform(for: size)
        let pass = MetalPass(pipeline: .rawPipeline,
                             drawable: texture,
                             vertexBuffers: [MetalPipeline.defaultVertexBuffer],
                             fragmentBuffers: [transform],
                             fragmentTextures: [_texture])
        
        pass.commit()
        
        pass.buffer.waitUntilCompleted()
        
        return texture
    }
    #endif
    
    func convertedToSRGB() -> MetalTexture {
        if colorSpace == .srgb, pixelFormat == .bgra8Unorm_srgb { return self }
        
        let target = MetalHeapManager.shared.makeTexture(size, .bgra8Unorm_srgb, type: .longTerm)!
        target.colorSpace = .srgb
        
        let input: RenderPayload = .colorMatrix(.texture(self), colorSpace?.matrix(to: .srgb) ?? .identity)
        
        let pass = RenderPassDescriptor(identifier: "srgb",
                                        pipeline: .drawPipeline2,
                                        inputs: [input],
                                        clearColor: nil).metalPass(target)
        
        pass.commit()
        pass.buffer.waitUntilCompleted()
        
        return target
    }
    
}

#if os(iOS)
extension ImageOrientation {
    
    var isLeftOrRight: Bool {
        switch self {
            case .left: return true
            case .right: return true
            case .leftMirrored: return true
            case .rightMirrored: return true
            default: return false
        }
    }
    
}

public extension CGSize {
    
    func after(_ orientation: ImageOrientation) -> CGSize {
        if orientation.isLeftOrRight {
            return CGSize(width: height, height: width)
        } else {
            return self
        }
    }
    
}
#endif
