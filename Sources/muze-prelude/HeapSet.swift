//
//  File.swift
//  
//
//  Created by Greg Fajen on 12/20/19.
//

import Foundation

open class HeapSet<Element: Heap> {
    
    public typealias Heap = Element
    
//    static let pageSize = HeapLayout.pageSize
    let layout: HeapLayout
    let queue = DispatchQueue(label: "HeapSet")
    
    var heaps: [Heap] = []
    
    public init(layout: HeapLayout) {
        self.layout = layout
    }
    
    public convenience init(heapSize: Int, chunkSize: Int = HeapLayout.defaultChunkSize) {
        self.init(layout: .init(heapSize: heapSize, chunkSize: chunkSize))
    }
    
    public func newHeap() -> Heap? {
        guard let heap = Heap(layout: layout, queue: queue) else {
            return nil
        }
        
        queue.sync {
            heaps.append(heap)
        }
        
        return heap
    }
    
    public func deleteHeap(_ heap: Heap) {
        queue.sync {
            heaps.removeAll { $0 === heap }
        }
    }
    
    func _newHeap() -> Heap? {
        guard let heap = Heap(layout: layout, queue: queue) else {
            return nil
        }
        
        heaps.append(heap)
        return heap
    }
    
    func _deleteHeap(_ heap: Heap) {
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
            
            if let heap = Heap(layout: newLayout, queue: queue) {
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
    
    public var used: MemorySize {
        return heaps.reduce(MemorySize(0)) { return $0 + $1.used }
    }
    
    public var allocated: MemorySize {
        return heaps.reduce(MemorySize(0)) { return $0 + $1.allocated }
    }
    
}
