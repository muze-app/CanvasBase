//
//  MetalAllocator.swift
//  muze
//
//  Created by Greg Fajen on 5/14/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import UIKit
import Metal

protocol MetalAllocator {
    
    func _makeTexture(for descriptor: MTLTextureDescriptor) -> MetalTexture?
    func makeTexture(for descriptor: MTLTextureDescriptor) -> MetalTexture?
    func makeTexture(_ size: CGSize, _ pixelFormat: MTLPixelFormat) -> MetalTexture?
    
    var usedSize: Int { get }
    var allocatedSize: Int { get }
    
    var heapIsEmpty: Bool { get }
    
    func move(texture: MetalTexture) -> Bool
    func _move(texture: MetalTexture) -> Bool
    
    var type: HeapType { get }
    
}

extension MetalAllocator {
    
    var heapIsEmpty: Bool {
        return usedSize == 0
    }
    
    func makeTextureDescriptor(_ size: CGSize, _ pixelFormat: MTLPixelFormat, _ usage: MTLTextureUsage) -> MTLTextureDescriptor {
        let d = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: pixelFormat,
                                                        width: Int(size.width),
                                                        height: Int(size.height),
                                                        mipmapped: false)
        d.usage = usage
        
        return d
    }
    
    func makeTexture(_ size: CGSize, _ pixelFormat: MTLPixelFormat = .bgra8Unorm) -> MetalTexture? {
        let descriptor = makeTextureDescriptor(size, pixelFormat, [.renderTarget, .shaderRead, .shaderWrite])
        return makeTexture(for: descriptor)
    }
    
    var queue: DispatchQueue { return MetalHeapManager.shared.queue }
    
    func makeTexture(for descriptor: MTLTextureDescriptor) -> MetalTexture? {
        if type == .render {
            dispatchPrecondition(condition: .onQueue(RenderManager.shared.queue))
        }
        
//        dispatchPrecondition(condition: .notOnQueue(.main))
        dispatchPrecondition(condition: .notOnQueue(queue))
        
        var t: MetalTexture?
        queue.sync { t = _makeTexture(for: descriptor) }
        return t
    }
    
    func move(texture: MetalTexture) -> Bool {
        if type == .render {
            dispatchPrecondition(condition: .onQueue(RenderManager.shared.queue))
        }
        
        dispatchPrecondition(condition: .notOnQueue(queue))
        var r = false
        queue.sync { r = _move(texture: texture) }
        return r
    }
    
}

extension Array: MetalAllocator where Element : MetalAllocator {
    
    var type: HeapType {
        return first?.type ?? .longTerm
    }
    
    var usedSize: Int {
        return reduce(into: 0) { $0 += $1.usedSize }
    }
    
    var allocatedSize: Int {
        return reduce(into: 0) { $0 += $1.allocatedSize }
    }
    
    func _makeTexture(for descriptor: MTLTextureDescriptor) -> MetalTexture? {
        for heap in self {
            if let t = heap._makeTexture(for: descriptor) {
                return t
            }
        }
        
        return nil
    }
    
    func _move(texture: MetalTexture) -> Bool {
        for heap in self {
            if heap._move(texture: texture) {
                return true
            }
        }
        
        return false
    }
    
}
