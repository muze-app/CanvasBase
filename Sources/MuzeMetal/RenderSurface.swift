//
//  RenderSurface.swift
//  muze
//
//  Created by Greg on 2/10/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

//import UIKit
import Metal
import MuzePrelude

public class RenderSurface: AutoHash, MetalPassTarget {
    
    public var size: CGSize
    public var pixelFormat: MTLPixelFormat {
        didSet {
            assert(!_texture.exists)
//            if !UIDevice.current.isX {
//                assert(pixelFormat != .bgra10_xr_srgb)
//            }
        }
    }
    
    public var canAlias: Bool = true
    
    public var identifier: String?
    
    public var fence: MTLFence? {
        return texture?.fence
    }
    
    var _texture: MetalTexture?
    public var texture: MetalTexture? { return _texture }
    
    public init(size: CGSize, pixelFormat: MTLPixelFormat, identifier: String? = nil) {
        self.size = size
        self.pixelFormat = pixelFormat
        self.identifier = identifier
    }
    
    public var needsToAllocateTexture: Bool { return !_texture.exists }
    public func allocateTextureIfNeeded() {
        guard needsToAllocateTexture else { return }
        _texture = MetalHeapManager.shared.makeTexture(size, pixelFormat, type: .render)!
        _texture?.identifier = identifier
    }
    
    public var timeStamp: TimeInterval? {
        get { return _texture?.timeStamp }
        set { _texture?.timeStamp = newValue }
    }
    
}
