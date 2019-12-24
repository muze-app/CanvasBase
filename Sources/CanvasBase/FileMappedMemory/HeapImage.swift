//
//  HeapImage.swift
//  muze
//
//  Created by Greg Fajen on 8/15/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import UIKit
import MuzePrelude

enum ContextError: Error {
    case badParams
}

private let releaseCallback: CGDataProviderReleaseDataCallback = { _, _, _ in
    
}

// warning: retain this object, NOT CGImages or UIImages created from it
// when this object is release, it will free the underlying memory, and any CGImages trying to use it will crash
class HeapImage {
    
    let address: UnsafeMutableRawPointer
    let width: Int
    let height: Int
    let stride: Int
    var size: CGSize { return CGSize(width: width, height: height) }
    var bounds: CGRect { return .zero & size }
    
    init(_ image: CGImage, heapSet optionalHeapSet: FileMappedHeapManager.Set? = nil) throws {
//        let heapSet: FileMappedHeapManager.Set
//        if let s = optionalHeapSet {
//            heapSet = s
//        } else if image.width <= 8, image.height <= 8 {
//            heapSet = .nano
//        } else {
//            heapSet = .main
//        }
        
        fatalError()
        /*
        let set = FileMappedHeapManager.shared.set(for: heapSet)
        let bytesPerPixel = 4
        let align = bytesPerPixel * 8
        let stride = (image.width * bytesPerPixel).lowestMultiple(of: align)
        let length = stride * image.height
        
        guard let address = set.alloc(length) else { throw MemoryError.outOfMemory }
        
        self.address = address
        self.width = image.width
        self.height = image.height
        self.stride = stride
        
        let alphaInfo: CGImageAlphaInfo = .premultipliedFirst
        let colorInfo: CGBitmapInfo = .byteOrder32Little
        let bitmapInfo: CGBitmapInfo = [colorInfo, CGBitmapInfo(alphaInfo)]
        
        guard let context = CGContext(data: address,
                            width: width,
                            height: height,
                            bitsPerComponent: 8,
                            bytesPerRow: stride,
                            space: .sRGBSpace,
                            bitmapInfo: bitmapInfo.rawValue) else {
                        throw ContextError.badParams
        }
        
        draw(in: context) { context.draw(image, in: bounds) }*/
    }
    
//    init(_ texture: MetalTexture, heapSet optionalHeapSet: FileMappedHeapManager.Set? = nil) throws {
//        let texture = texture.convertedToSRGB() // no-op if already there
//
//        let heapSet: FileMappedHeapManager.Set
//        if let s = optionalHeapSet {
//            heapSet = s
//        } else if texture.width <= 8, texture.height <= 8 {
//            heapSet = .nano
//        } else {
//            heapSet = .main
//        }
//
//        let set = FileMappedHeapManager.shared.set(for: heapSet)
//        let bytesPerPixel = 4
//        let align = bytesPerPixel * 8
//        let stride = (texture.width * bytesPerPixel).lowestMultiple(of: align)
//        let length = stride * texture.height
//
//        guard let address = set.alloc(length) else { throw MemoryError.outOfMemory }
//
//        self.address = address
//        self.width = texture.width
//        self.height = texture.height
//        self.stride = stride
//
//        let region = MTLRegionMake2D(0, 0, texture.width, texture.height)
//        texture._texture.getBytes(address, bytesPerRow: stride, from: region, mipmapLevel: 0)
//
//        let i = address.assumingMemoryBound(to: Int.self).pointee
//        print("i: \(i)")
//    }
    
    // make sure to retain HeapImage for the lifetime of this CGImage
    var cgImage: CGImage {
        fatalError()
        /*
        let provider = CGDataProvider(dataInfo: nil,
                                      data: address,
                                      size: stride * height,
                                      releaseData: releaseCallback)!
        
        let alphaInfo: CGImageAlphaInfo = .premultipliedFirst
        let colorInfo: CGBitmapInfo = .byteOrder32Little
        let bitmapInfo: CGBitmapInfo = [colorInfo, CGBitmapInfo(alphaInfo)]
        
        return CGImage(width: width,
                       height: height,
                       bitsPerComponent: 8,
                       bitsPerPixel: 32,
                       bytesPerRow: stride,
                       space: .sRGBSpace,
                       bitmapInfo: bitmapInfo,
                       provider: provider,
                       decode: nil,
                       shouldInterpolate: false,
                       intent: .absoluteColorimetric)!*/
    }
    
    // make sure to retain HeapImage for the lifetime of this UIImage
    var uiImage: UIImage {
        return UIImage(cgImage: cgImage)
    }
    
    func flip(_ context: CGContext) {
        context.scaleBy(x: 1, y: -1)
        context.translateBy(x: 0, y: -CGFloat(height))
    }
    
    func draw(in context: CGContext, _ block: ()->()) {
        UIGraphicsPushContext(context)
        context.saveGState()
        block()
        context.restoreGState()
        UIGraphicsPopContext()
    }
    
}
