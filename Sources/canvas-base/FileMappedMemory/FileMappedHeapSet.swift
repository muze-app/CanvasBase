//
//  FileMappedHeapSet.swift
//  muze
//
//  Created by Greg Fajen on 8/14/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation

class FileMappedHeapSet {
    
    static let pageSize = FileMappedHeap.pageSize
    let layout: HeapLayout
    let queue = DispatchQueue(label: "HeapSet")
    
    var heaps: [FileMappedHeap] = []
    
    init(layout: HeapLayout) {
        self.layout = layout
    }
    
    convenience init(heapSize: Int, chunkSize: Int = HeapLayout.defaultChunkSize) {
        self.init(layout: .init(heapSize: heapSize, chunkSize: chunkSize))
    }
    
    func newHeap() -> FileMappedHeap? {
        guard let heap = FileMappedHeap(layout: layout, queue: queue) else {
            return nil
        }
        
        queue.sync {
            heaps.append(heap)
        }
        
        return heap
    }
    
    func deleteHeap(_ heap: FileMappedHeap) {
        queue.sync {
            heaps.removeAll { $0 === heap }
        }
    }
    
    func _newHeap() -> FileMappedHeap? {
        guard let heap = FileMappedHeap(layout: layout, queue: queue) else {
            return nil
        }
        
        heaps.append(heap)
        return heap
    }
    
    func _deleteHeap(_ heap: FileMappedHeap) {
        heaps.removeAll { $0 === heap }
    }
    
    func alloc(_ size: Int) -> UnsafeMutableRawPointer? {
//        print("heap set alloc \(MemorySize(size))")
        
        var pointer: UnsafeMutableRawPointer?
        queue.sync {
            for heap in heaps {
                if let p = heap._alloc(size) {
                    pointer = p
                    return
                }
            }
            
            // pointer is still nil
            let newLayout: HeapLayout
            if size > layout.heapSize {
                newLayout = HeapLayout(heapSize: size, chunkSize: layout.chunkSize)
            } else {
                newLayout = layout
            }
            
            if let heap = FileMappedHeap(layout: newLayout, queue: queue) {
                pointer = heap._alloc(size)!
                heaps.append(heap)
            }
        }
        
        return pointer
    }
    
    func free(_ pointer: UnsafeMutableRawPointer) {
        queue.sync {
            for heap in heaps {
                if heap.contains(pointer) {
                    heap._free(pointer)
                    return
                }
            }
        }
    }
    
    var used: MemorySize {
        return heaps.reduce(MemorySize(0)) { return $0 + $1.used }
    }
    
    var allocated: MemorySize {
        return heaps.reduce(MemorySize(0)) { return $0 + $1.allocated }
    }
    
}
