//
//  MetalHeapSeries.swift
//  muze
//
//  Created by Greg Fajen on 5/14/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation
import Metal
import MuzePrelude

class MetalHeapSeries: MetalAllocator {
    
    let heapSize: Int
    let type: HeapType
    
    init(type: HeapType, heapSize: Int = 24000000) {
        self.heapSize = heapSize
        self.type = type
    }
    
    var heaps: [MetalHeap] = []
    
    var usedSize: Int { return heaps.usedSize }
    var allocatedSize: Int { return heaps.allocatedSize }
    
    func _makeTexture(for descriptor: MTLTextureDescriptor) -> MetalTexture? {
        if let t = heaps._makeTexture(for: descriptor) { return t }
        
        let (tSize, _) = descriptor.sizeAndAlign
        let h = MetalHeap(type: type, size: max(tSize, heapSize))
        heaps.append(h)
        
        let t = h._makeTexture(for: descriptor)!
        _purgeEmptyHeaps(heapSize)
        return t
    }
    
    var sortedHeaps: (empty: [MetalHeap], sorted: [MetalHeap]) {
        let (empty, nonempty) = heaps.discriminate { $0.heapIsEmpty }
        let sorted = nonempty.sorted { $0.usedSize < $1.usedSize }
        return (empty, sorted)
    }
    
    @discardableResult
    func defragment(from series: [MetalHeapSeries],
                    policy: DefragmentPolicy = .allocateIfNeeded) -> Bool {
        var r = false
        queue.sync { r = _defragment(from: series, policy: policy) }
        return r
    }
    
    @discardableResult
    func _defragment(from series: [MetalHeapSeries], policy: DefragmentPolicy) -> Bool {
        dispatchPrecondition(condition: .onQueue(queue))
        
//        if let heap = emptyHeap {
//            assert(heap.heapIsEmpty)
//            heaps.append(heap)
//        }
        
//        if heapIsEmpty { return true }
        
        let series = series.filter { $0 !== self }
        
        var (emptyHeaps, fragmentedHeaps) = sortedHeaps
        
//        print("sorted heaps:")
//        print("    empty:")
//        for heap in emptyHeaps {
//            print("        \(heap)")
//        }
//        print("    fragmented:")
//        for heap in fragmentedHeaps {
//            print("        \(heap)")
//        }
//        print("    all:")
//        for heap in heaps {
//            print("        \(heap)")
//        }
        
        if emptyHeaps.count == 0 {
            if !_ensureEmptyHeap(&emptyHeaps, &fragmentedHeaps, policy) {
                return false
            }
        }
        
//        print("after ensure empty heap:")
//        print("    empty:")
//        for heap in emptyHeaps {
//            print("        \(heap)")
//        }
//        print("    fragmented:")
//        for heap in fragmentedHeaps {
//            print("        \(heap)")
//        }
//        print("    all:")
//        for heap in heaps {
//            print("        \(heap)")
//        }
        
        var defragmentedHeaps = emptyHeaps
        var fullHeaps = [MetalHeap]()
        
        for heap in fragmentedHeaps {
            autoreleasepool {
                if heap.usedSize == heap.allocatedSize {
                    //                print("moving \(heap) to defrag")
                    fullHeaps.append(heap)
                } else {
                    for texture in heap.textures.sortedBySize {
//                        print("    moving texture of size \(texture.memorySize)")
                        if !texture.isAliasable, !texture.isInUseByRenderer {
                            if !defragmentedHeaps._move(texture: texture) {
                                // should be rare, but could happen if a texture is too large to fit into defragged heaps
                                // for now, we'll just pretend it doesn't happen, since we'll still be mostly defragged
                                //                    continue
                            }
                        }
                    }
                    
                    defragmentedHeaps.append(heap)
                    
                    let oldCount = fullHeaps.count + defragmentedHeaps.count
                    
                    let (full, notFull) = (fullHeaps + defragmentedHeaps).discriminate { $0.maxAvailableSize < 16 }
                    fullHeaps = full
                    defragmentedHeaps = notFull
                    
//                    print("\(full.count) + \(notFull.count) = \(oldCount)")
                    assert(fullHeaps.count + defragmentedHeaps.count == oldCount)
                    
                    //            assert(heap.isEmpty)
                    //            print("moving \(heap) to defrag")
                }
            }
        }
        
        for heapSeries in series {
            for heap in heapSeries.heaps {
                autoreleasepool {
                    for texture in heap.textures.sortedBySize {
                        if !texture.isAliasable, !texture.isInUseByRenderer {
                            if !defragmentedHeaps._move(texture: texture) {
                                // here we should consider allocating some more heaps
                            }
                        }
                    }
                }
                
                let oldCount = fullHeaps.count + defragmentedHeaps.count
                
                let (full, notFull) = (fullHeaps + defragmentedHeaps).discriminate { $0.maxAvailableSize < 16 }
                fullHeaps = full
                defragmentedHeaps = notFull
                
//                print("\(full.count) + \(notFull.count) = \(oldCount)")
                assert(fullHeaps.count + defragmentedHeaps.count == oldCount)
            }
            
            heapSeries._purgeEmptyHeaps(0)
        }
        
//        print("old heap count: \(heaps.count)")
//        print("new heap count: \(defragmentedHeaps.count + fullHeaps.count) (\(defragmentedHeaps.count) + \(fullHeaps.count))")
        
        defragmentedHeaps.append(contentsOf: fullHeaps)
        
        assert(heaps.count == defragmentedHeaps.count)
        heaps = defragmentedHeaps
        return true
    }
    
    func _ensureEmptyHeap(_ emptyHeaps: inout [MetalHeap],
                          _ fragmentedHeaps: inout [MetalHeap],
                          _ policy: DefragmentPolicy) -> Bool {
        if policy == .eagerlyAllocate {
            let h = MetalHeap(type: type, size: heapSize)
            heaps.append(h)
            emptyHeaps.append(h)
            return true
        }

        if fragmentedHeaps.count <= 1 {
            if policy == .allocateIfNeeded {
                let h = MetalHeap(type: type, size: heapSize)
                heaps.append(h)
                emptyHeaps.append(h)
                return true
            } else {
                return false
            }
        }
        
        let smallest = fragmentedHeaps.removeFirst()
        
        let i = fragmentedHeaps.firstIndex { $0 === smallest}
        assert(!i.exists)
        
        for texture in smallest.textures {
            if !fragmentedHeaps._move(texture: texture) {
                fragmentedHeaps.append(smallest)
                
                if policy == .doNotAllocate { return false }
                
                let h = MetalHeap(type: type, size: heapSize)
                heaps.append(h)
                emptyHeaps.append(h)
                return true
            }
        }
        
//        print("smallest:")
//        print("   textures: \(smallest.textures.count)")
//        print("   usedT: \(smallest.usedSizeFromTextures)")
//        print("   usedH: \(smallest.usedSizeFromHeap)")
        
//        assert(smallest.heapIsEmpty)
        emptyHeaps.append(smallest)
        return true
    }
    
    func purgeEmptyHeaps(keeping bytesToKeep: Int) {
        queue.async { self._purgeEmptyHeaps(bytesToKeep) }
    }
    
    func _purgeEmptyHeaps(_ bytesToKeep: Int) {
        var bytesToKeep = bytesToKeep
        heaps = heaps.filter {
            guard heapIsEmpty else { return true }
            guard bytesToKeep > 0 else { return false }
            
            bytesToKeep -= $0.allocatedSize
            return true
        }
    }
    
    enum DefragmentPolicy {
        case doNotAllocate, allocateIfNeeded, eagerlyAllocate
    }
    
    func _move(texture: MetalTexture) -> Bool {
        if heaps._move(texture: texture) { return true }
        
        let descriptor = makeTextureDescriptor(texture.size, texture.pixelFormat, texture.usage)
        let (tSize, _) = descriptor.sizeAndAlign
        let h = MetalHeap(type: type, size: max(tSize, heapSize))
        heaps.append(h)
        
        return h._move(texture: texture)
    }
    
}

extension Array where Element == MetalTexture {
    
    var sortedBySize: [MetalTexture] {
        return sorted { $0.memorySize > $1.memorySize }
    }
    
}

extension WeakSet where Element == MetalTexture {
    
    var sortedBySize: [MetalTexture] {
        return sorted { $0.memorySize > $1.memorySize }
    }
    
}
