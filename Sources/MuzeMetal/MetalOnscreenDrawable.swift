//
//  MetalOnscreenDrawable.swift
//  muze
//
//  Created by Greg on 12/21/18.
//  Copyright © 2018 Ergo Sum. All rights reserved.
//

import UIKit
import Metal
import MuzePrelude

@available(*, deprecated)
final class MetalOnscreenDrawable: MetalDrawable {
    
    let width: Int
    let height: Int
    var size: CGSize {
        return CGSize(width: width, height: height)
    }
    
    required init(width: Int, height: Int) {
        self.width = width
        self.height = height
        
        setupMetalLayer()
    }
    
    static var fullscreenPool = DrawablePool<MetalOnscreenDrawable>()
    
    // MARK: Drawable Protocol
    
    var needsClear = true
    
    func clear() {
        needsClear = true
    }
    
    #if targetEnvironment(simulator)
    
    var _texture: MTLTexture {
        fatalError()
    }
    
    #else
    
    var _texture: MTLTexture {
        return currentDrawable.texture
    }
    
    var drawable: CAMetalDrawable? {
        return currentDrawable
    }
    
    var pixelFormat: MTLPixelFormat {
        return .bgra8Unorm
    }
    
    private var _currentDrawable: CAMetalDrawable?
    var currentDrawable: CAMetalDrawable {
        if let drawable = _currentDrawable {
            return drawable
        }
        
        _currentDrawable = metalLayer.nextDrawable()
        return _currentDrawable!
    }
    
    #endif
    
    // MARK: Metal Layer
    
    #if targetEnvironment(simulator)
    let metalLayer: CALayer = CALayer()
    #else
    let metalLayer: CAMetalLayer = CAMetalLayer()
    #endif
    
    func setupMetalLayer() {
        #if !targetEnvironment(simulator)
        metalLayer.device = MetalDevice.device
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = false
        metalLayer.frame = CGRect(origin: CGPoint.zero, size: size)
        metalLayer.drawableSize = size
        metalLayer.isOpaque = false
        #endif
    }
    
    // MARK: Blitting
    
    // will still clear if needsClear is set
    func blit<T: MetalDrawable>(_ source: T, clear: Bool) {
        blit(source, clear: clear, present: true)
    }
    
    // will still clear if needsClear is set
    func blit<T: MetalDrawable>(_ source: T, clear: Bool, present: Bool) {
        if source.needsClear { return }
        
        blit(source._texture, clear: clear, present: present)
    }
    
    @available(*, deprecated)
    func blit(_ texture: MTLTexture, clear: Bool, present: Bool) {
        let clearColor = clear ? UIColor.clear : nil
        
        let pass = MetalPass(pipeline: .blitPipeline,
                             drawable: self,
                             clearColor: clearColor,
                             vertexBuffers: [MetalPipeline.defaultVertexBuffer],
                             fragmentTextures: [texture])
        
        if present {
            pass.present()
        }
        
        pass.commit()
        
        if present {
            #if !targetEnvironment(simulator)
            _currentDrawable = nil
            #endif
        }
    }
    
    @available(*, deprecated)
    func draw(_ texture: MTLTexture,
              vertexBuffer: MetalBuffer = MetalPipeline.defaultVertexBuffer,
              transform: CGAffineTransform,
              alpha: Float = 1,
              clear: Bool = true,
              present: Bool = true) {
        
        let clearColor = clear ? UIColor.clear : nil
        assert(vertexBuffer.length == 48)
        
//        let alphaBuffer: MetalBuffer = [alpha]
        
//        print("onscreen draw! alpha: \(alpha). clear: \(clear).")
        
        let pass = MetalPass(pipeline: .drawPipeline,
                             drawable: self,
                             clearColor: clearColor,
                             vertexBuffers: [vertexBuffer],
//                             fragmentBuffers: [transform.buffer],
                             fragmentBuffers: [AffineTransform(transform), alpha],
                             fragmentTextures: [texture])
        
        if present {
            pass.present()
        }
        
        pass.commit()
        
        if present {
            #if !targetEnvironment(simulator)
            _currentDrawable = nil
            #endif
        }
    }

    // MARK: Other
    
    let hashValue: Int = Int(arc4random())
    
    weak var pool: DrawablePool<MetalOnscreenDrawable>?
    
}
