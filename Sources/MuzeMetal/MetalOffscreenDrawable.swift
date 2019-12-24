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
final class MetalOffscreenDrawable: MetalDrawable, Equatable, AutoHash {

    #if !targetEnvironment(simulator)
    var drawable: CAMetalDrawable? {
        return nil
    }
    #endif
    
    static func == (lhs: MetalOffscreenDrawable, rhs: MetalOffscreenDrawable) -> Bool {
        return lhs === rhs
    }
    
    var pixelFormat: MTLPixelFormat {
        return .bgra8Unorm
    }
    
    var _texture: MTLTexture { return texture._texture }
    let texture: MetalTexture
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
    
    required convenience init(width: Int, height: Int) {
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
    
    static var fullscreenPool: DrawablePool<MetalOffscreenDrawable> { return DrawablePool<MetalOffscreenDrawable>() }
    
    var width: Int {
        return _texture.width
    }
    
    var height: Int {
        return _texture.height
    }
    
    var size: CGSize {
        return CGSize(width: width, height: height)
    }
    
    var needsClear = true
    
    func clear() {
        needsClear = true
    }
    
    // MARK: Blitting and Drawing
    
    // will still clear if needsClear is set
    func blit<T: MetalDrawable>(_ source: T, clear: Bool = true) {
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
    
    let hashValue: Int = Int(arc4random())
    
    weak var pool: DrawablePool<MetalOffscreenDrawable>?
    
}

extension CGAffineTransform {
    
    var asFloats: [Float] {
        let values = [a,b,c,d,tx,ty]
        return values.map { Float($0) }
    }
    
    var asPaddedFloats: [Float] {
        let values = [a,b,c,d,tx,ty,0,0]
        return values.map { Float($0) }
    }
        
}

extension CGFloat {
    
    var abs: CGFloat {
        return self < 0 ? -self : self
    }
    
    static func ~= (lhs: CGFloat, rhs: CGFloat) -> Bool {
        let sigma = Swift.max(lhs / 10000, 0.00000001)
        let diff = (lhs - rhs).abs
        return diff <= sigma
    }
    
}

extension CGRect {
    
    static var random: CGRect {
        let upper: UInt32 = 2000
        let x = arc4random_uniform(upper)
        let y = arc4random_uniform(upper)
        let w = arc4random_uniform(upper)
        let h = arc4random_uniform(upper)
        return CGRect(x: x, y: y, width: w, height: h)
    }
    
    init(x: UInt32, y: UInt32, width: UInt32, height: UInt32) {
        self.init(x: CGFloat(x), y: CGFloat(y), width: CGFloat(width), height: CGFloat(height))
    }
    
    static func ~= (lhs: CGRect, rhs: CGRect) -> Bool {
        return lhs.minX ~= rhs.minX &&
               lhs.minY ~= rhs.minY &&
               lhs.maxX ~= rhs.maxX &&
               lhs.maxY ~= rhs.maxY
    }
    
}

extension CGPoint {
    
    static func ~= (lhs: CGPoint, rhs: CGPoint) -> Bool {
        return lhs.x ~= rhs.x && lhs.y ~= rhs.y
    }
    
}

extension UIColor {
    
    var alpha: CGFloat {
        var alpha: CGFloat = 1
        getRed(nil, green: nil, blue: nil, alpha: &alpha)
        return alpha
    }
    
    var components: [Float] {
        var r: CGFloat = 1
        var g: CGFloat = 1
        var b: CGFloat = 1
        var a: CGFloat = 1
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        return [r,g,b,a].map { Float($0) }
    }
    
    var premultipliedComponents: [Float] {
        let components = self.components
        let a = components[3]
        let r = components[0] * a
        let g = components[1] * a
        let b = components[2] * a
        
        return [r,g,b,a]
    }
    
}
