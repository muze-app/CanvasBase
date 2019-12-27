//
//  MetalHeap.swift
//  muze
//
//  Created by Greg Fajen on 5/14/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

//import UIKit
import Metal
import MuzePrelude

public class MetalHeap: MetalAllocator {
    
    let heap: MTLHeap
    let heapDescriptor: MTLHeapDescriptor
    let type: HeapType
    
    init(type: HeapType, size: Int) {
        let descriptor = MTLHeapDescriptor()
        descriptor.size = size
        descriptor.storageMode = .shared
        
        print("allocating heap of size \(MemorySize(size))")
        let velocity = MetalHeapManager.shared._allocated(MemorySize(size))
        print("    velocity: \(MemorySize(velocity))/sec")
        
        if velocity > 500000000 {
            print("woah")
        }
        
        heap = MetalDevice.device.makeHeap(descriptor: descriptor)!
        heapDescriptor = descriptor
        
        self.type = type
    }
    
    convenience init(type: HeapType, itemSize: Int, count: Int) {
        self.init(type: type, size: itemSize * count)
    }
    
    deinit {
        print("bye!")
    }
    
    func _makeTexture(for descriptor: MTLTextureDescriptor) -> MetalTexture? {
        dispatchPrecondition(condition: .onQueue(queue))
        
        let hSM = heapDescriptor.storageMode
        let tSM = descriptor.storageMode
        
        if hSM != tSM {
            fatalError("storage mode mismatch")
        }
        
//        if !UIDevice.current.isX {
//            assert(descriptor.pixelFormat != .bgra10_xr_srgb)
//        }
        
        guard let tex = heap.makeTexture(descriptor: descriptor) else { return nil }
        let texture = MetalTexture(tex, heap: self)
        
//        print("make texture \(MemorySize(descriptor.sizeAndAlign.size)) (\(descriptor.pixelFormat))")
        
        texture.bytesNeeded = descriptor.sizeAndAlign.size
        texture.heap = self
        remember(texture)
        
        assert(texture._texture.usage.contains(.renderTarget))
        assert(texture._texture.usage.contains(.shaderRead))
        assert(texture._texture.usage.contains(.shaderWrite))
        
        return texture
    }
    
    var textures = WeakSet<MetalTexture>()
    
    func remember(_ texture: MetalTexture) {
        textures.insert(texture)
    }
    
    func forget(_ texture: MetalTexture) {
        textures.remove(texture)
    }
    
    var usedSize: Int {
        return heap.usedSize
    }
    
    var usedSizeFromTextures: Int {
        return textures.reduce(into: 0) { $0 += $1.bytesNeeded }
    }
    
    var usedSizeFromHeap: Int {
        return heap.usedSize
    }
    
    var allocatedSize: Int {
        return heap.currentAllocatedSize
    }
    
    func maxAvailableSize(with alignment: Int) -> Int {
        return heap.maxAvailableSize(alignment: alignment)
    }
    
    var maxAvailableSize: Int {
        return self.maxAvailableSize(with: 0)
    }
    
    func _move(texture: MetalTexture) -> Bool {
        dispatchPrecondition(condition: .onQueue(queue))
        assert(texture.heap !== self)
        
        let descriptor = makeTextureDescriptor(texture.size, texture.pixelFormat, texture.usage)
        guard let target = _makeTexture(for: descriptor) else {
//            let (size, align) = descriptor.sizeAndAlign
//            let max = maxAvailableSize(with: align)
//            print("   can't fit texture of size \(MemorySize(size)) into \(MemorySize(max))")
            return false
        }
        
        texture.blit(to: target)
        
//        let oldHeap = texture.heap
        
        let old = texture._texture
        texture.heap?.forget(texture)
        
        texture._texture = target._texture
        texture.heap = self
        
        remember(texture)
        forget(target)
        
        if old.isAliasable() {
            old.makeAliasable()
        }
        
//        print("moved texture from \(String(describing: oldHeap)) to \(self)")
//        print("    oldHeap textures remaining: \(oldHeap?.textures.count ?? 0)")
        
        return true
    }
    
}

extension MTLTextureDescriptor {
    
    var sizeAndAlign: (size: Int, align: Int) {
        let v = MetalDevice.device.heapTextureSizeAndAlign(descriptor: self)
        return (v.size, v.align)
    }
    
    var expectedSize: Int {
        return width * height * pixelFormat.bytesPerPixel
    }
    
}

public extension MTLPixelFormat {
    
    var bytesPerPixel: Int {
        switch self {
            // 8-bit
            case .r8Unorm: return 1
                
            // 16-bit
                
            // 32-bit
            case .rgba8Unorm, .bgra8Unorm, .rgba8Unorm_srgb, .bgra8Unorm_srgb: return 4
                
            // 64-bit
            case .rgba16Float: return 8
            case .rgba16Unorm: return 8
            case .bgra10_xr, .bgra10_xr_srgb: return 8
                
            // 128-bit
            case .rgba32Float: return 16
                
            default:
                fatalError("not yet implemented for \(self)")
        }
    }
    
}
