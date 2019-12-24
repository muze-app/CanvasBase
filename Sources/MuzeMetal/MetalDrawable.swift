//
//  MetalDrawable.swift
//  muze
//
//  Created by Greg on 1/3/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import UIKit
import Metal

public protocol SimpleMetalDrawable: class {
    
    var _texture: MTLTexture { get }
    var texture: MetalTexture { get }
    #if !targetEnvironment(simulator)
    var drawable: CAMetalDrawable? { get }
    var pixelFormat: MTLPixelFormat { get }
    #endif
    
    var needsClear: Bool { get set }
    
    var renderPassDescriptor: MTLRenderPassDescriptor? { get }
    
}

public extension SimpleMetalDrawable {
    
    var size: CGSize { return _texture.size }
    
}

public protocol MetalDrawable: Drawable, SimpleMetalDrawable {
    
    func blit<T: MetalDrawable>(_ source: T, clear: Bool)
    
}

public extension MetalDrawable {
    
    func blit<T: MetalDrawable>(_ source: T) {
        blit(source, clear: true)
    }
    
    var renderPassDescriptor: MTLRenderPassDescriptor? {
        return nil
    }
    
    var texture: MetalTexture {
//        #warning("fix me")
        return MetalTexture(_texture)
    }
    
    var size: CGSize { return _texture.size }
    
}
