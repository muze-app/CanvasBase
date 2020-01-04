//
//  PayloadBuffer.swift
//  muze
//
//  Created by Greg Fajen on 9/1/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation
import MuzePrelude

class PayloadBuffer<Collection: NodeCollection>: AutoHash {
    
    weak var bufferSet: PayloadBufferSet<Collection>?
    let heap: DAGHeap
    
    init?(bufferSet: PayloadBufferSet<Collection>) {
        guard let heap = bufferSet.newHeap() else {
            return nil
        }
        
        self.bufferSet = bufferSet
        self.heap = heap
    }
    
    func new<T>(_ s: T, type: Collection) -> PayloadBufferAllocation<Collection>? {
        
//        let count = 4
        ///     let bytesPointer = UnsafeMutableRawPointer.allocate(
        ///             byteCount: count * MemoryLayout<Int8>.stride,
        ///             alignment: MemoryLayout<Int8>.alignment)
        ///     let int8Pointer = myBytes.initializeMemory(
        ///             as: Int8.self, repeating: 0, count: count)
        ///
        ///     // After using 'int8Pointer':
        ///     int8Pointer.deallocate()
        
        let p1 = UnsafeMutableRawPointer.allocate(byteCount: MemoryLayout<T>.stride,
                                                  alignment: MemoryLayout<T>.alignment)
        
        let p2 = p1.initializeMemory(as: T.self, repeating: s, count: 1)
        
        return PayloadBufferAllocation(type: type, buffer: self, pointer: p2) {
            p2.deallocate()
        }
        
//        let size = MemoryLayout<T>.size
//        guard let r = heap.alloc(size) else { return nil }
//        let p = r.initializeMemory(as: T.self, repeating: s, count: 1)
//
//        return PayloadBufferAllocation(buffer: self, pointer: p, deallocate: {
////            print("    freeing \(p)")
//            p.deinitialize(count: 1)
//            self.heap.free(p)
//        })
    }
    
    deinit {
        bufferSet?.deleteHeap(heap)
    }
    
}
