//
//  RenderSurface.swift
//  muze
//
//  Created by Greg on 2/10/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import UIKit
import Metal
import MuzePrelude

class RenderSurface: AutoHash, MetalPassTarget {
    
    var size: CGSize
    var pixelFormat: MTLPixelFormat {
        didSet {
            assert(!_texture.exists)
//            if !UIDevice.current.isX {
//                assert(pixelFormat != .bgra10_xr_srgb)
//            }
        }
    }
    
    var canAlias: Bool = true
    
    var identifier: String?
    
    var fence: MTLFence? {
        return texture?.fence
    }
    
    var _texture: MetalTexture?
    var texture: MetalTexture? { return _texture }
    
    init(size: CGSize, pixelFormat: MTLPixelFormat, identifier: String? = nil) {
        self.size = size
        self.pixelFormat = pixelFormat
        self.identifier = identifier
    }
    
    var needsToAllocateTexture: Bool { return !_texture.exists }
    func allocateTextureIfNeeded() {
        guard needsToAllocateTexture else { return }
        _texture = MetalHeapManager.shared.makeTexture(size, pixelFormat, type: .render)!
        _texture?.identifier = identifier
    }
    
    var timeStamp: TimeInterval? {
        get { return _texture?.timeStamp }
        set { _texture?.timeStamp = newValue }
    }
    
}
