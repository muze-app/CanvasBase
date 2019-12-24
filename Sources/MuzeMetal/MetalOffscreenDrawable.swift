//
//  MetalOffscreenDrawable.swift
//  muze
//
//  Created by Greg on 12/26/18.
//  Copyright © 2018 Ergo Sum. All rights reserved.
//

import UIKit
import Metal
import MuzePrelude

@available(*, deprecated)
public final class MetalOffscreenDrawable: MetalDrawable, Equatable, AutoHash {

    #if !targetEnvironment(simulator)
    public var drawable: CAMetalDrawable? {
        return nil
    }
    #endif
    
    public static func == (lhs: MetalOffscreenDrawable, rhs: MetalOffscreenDrawable) -> Bool {
        return lhs === rhs
    }
    
    public var pixelFormat: MTLPixelFormat {
        return .bgra8Unorm
    }
    
    public var _texture: MTLTexture { return texture._texture }
    public let texture: MetalTexture
    static let device: MTLDevice = MTLCreateSystemDefaultDevice()!
    var device: MTLDevice {
        return MetalOffscreenDrawable.device
    }
    
    init(width: Int, height: Int, pixelFormat: MTLPixelFormat) {
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: pixelFormat,
                                                                  width: width,
                                                                  height: height,
                                                                  mipmapped: false)
        descriptor.usage = [.renderTarget, .shaderRead, .shaderWrite]
        
        texture = MetalHeapManager.shared.makeTexture(for: descriptor, type: .longTerm)!
//        _texture = device.makeTexture(descriptor: descriptor)!
//        texture = MetalTexture(_texture, heap: MetalHeapManager.shared.dynamicHeap)
    }
    
    public required convenience init(width: Int, height: Int) {
        self.init(width: width, height: height, pixelFormat: .bgra8Unorm)
    }
    
    convenience init(size: CGSize = UIScreen.main.bounds.size,
                     scale: CGFloat = UIScreen.main.scale,
                     pixelFormat: MTLPixelFormat) {
        let s = size * scale
        let w = Int(round(s.width))
        let h = Int(round(s.height))
        self.init(width: w, height: h, pixelFormat: pixelFormat)
    }
    
    public static var fullscreenPool: DrawablePool<MetalOffscreenDrawable> { return DrawablePool<MetalOffscreenDrawable>() }
    
    public var width: Int {
        return _texture.width
    }
    
    public var height: Int {
        return _texture.height
    }
    
    public var size: CGSize {
        return CGSize(width: width, height: height)
    }
    
    public var needsClear = true
    
    public func clear() {
        needsClear = true
    }
    
    // MARK: Blitting and Drawing
    
    // will still clear if needsClear is set
    public func blit<T: MetalDrawable>(_ source: T, clear: Bool = true) {
        let clearColor = clear ? UIColor.clear : nil
        
        let vertices = MetalPipeline.defaultVertexBuffer
        let pass = MetalPass(pipeline: .blitPipeline,
                             drawable: self,
                             clearColor: clearColor,
                             vertexBuffers: [vertices],
                             fragmentTextures: [source._texture])
        
        pass.commit()
    }
    
    func draw(_ texture: MTLTexture,
              vertexBuffer: MetalBuffer = MetalPipeline.defaultVertexBuffer,
              transform: CGAffineTransform,
              alpha: Float = 1,
              clear: Bool = false,
              completion: (()->())? = nil) {
        let clearColor = clear ? UIColor.clear : nil
        draw(texture,
             vertexBuffer: vertexBuffer,
             transform: transform,
             alpha: alpha,
             clearColor: clearColor,
             completion: completion)
    }
    
    func draw(_ texture: MTLTexture,
              vertexBuffer: MetalBuffer = MetalPipeline.defaultVertexBuffer,
              transform: CGAffineTransform,
              alpha: Float = 1,
              clearColor: UIColor?,
              completion: (()->())? = nil) {
        assert(vertexBuffer.length == 48)
        
        let pass = MetalPass(pipeline: .drawPipeline,
                             drawable: self,
                             clearColor: clearColor,
                             vertexBuffers: [vertexBuffer],
                             fragmentBuffers: [AffineTransform(transform), alpha],
                             fragmentTextures: [texture],
                             completion: completion)
        
        pass.commit()
    }
    
//    func blend(source: MTLTexture,
//               destination: MTLTexture,
//               alpha: Float,
//               blendMode: BlendMode,
//               vertexBuffer: MetalBuffer,
//               transform: CGAffineTransform,
//               clearColor: UIColor?,
//               completion: (()->())? = nil) {
//        assert(vertexBuffer.length == 48)
//
//        let pass = MetalPass(pipeline: blendMode.pipeline,
//                             drawable: self,
//                             clearColor: clearColor,
//                             vertexBuffers: [vertexBuffer],
//                             fragmentBuffers: [AffineTransform(transform), [alpha]],
//                             fragmentTextures: [source, destination],
//                             completion: completion)
//
//        pass.commit()
//    }
    
    // MARK: Other
    
    public let hashValue: Int = Int(arc4random())
    
    public weak var pool: DrawablePool<MetalOffscreenDrawable>?
    
}
