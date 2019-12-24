//
//  MetalSolidColorTexture.swift
//  muze
//
//  Created by Greg on 2/8/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import UIKit
import Metal
import MuzePrelude

struct MetalSolidColorTexture {
    
    var texture: MetalTexture
    var color: RenderColor2 {
        didSet {
            if color != oldValue {
                texture = MetalSolidColorTexture.texture(for: color)
            }
        }
    }
    
    init(_ color: RenderColor2) {
        texture = MetalSolidColorTexture.texture(for: color)
        self.color = color
    }
    
    static var textures = ThreadSafeDict<RenderColor2, MetalTexture>()
    
    static func texture(for color: RenderColor2) -> MetalTexture {
        if let texture = textures[color] {
            return texture
        }
        
        let heap = MetalHeapManager.shared
        let color = color.converted(to: .working)
        
        let texture = heap.makeTexture(size: CGSize(1), data: color.floats, bytesPerRow: 16)!
        texture.colorSpace = .working
        
        textures[color] = texture
        
        return texture
    }
    
}

extension MetalSolidColorTexture: Equatable {
    
    static func == (lhs: MetalSolidColorTexture, rhs: MetalSolidColorTexture) -> Bool {
        return lhs.color == rhs.color
    }
    
}

extension MTLTexture {
    
    var bytesPerSample: Int {
        return pixelFormat.bytesPerPixel
    }
    
    var memorySize: MemorySize {
        let size = width * height * bytesPerSample // approximate
        return MemorySize(size)
    }
    
    var memoryHash: MemoryHash {
        return [hashValue:memorySize]
    }
    
}
