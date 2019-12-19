//
//  PayloadBuffer.swift
//  muze
//
//  Created by Greg Fajen on 9/1/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation

class PayloadBuffer: AutoHash {
    
    weak var bufferSet: PayloadBufferSet?
    let heap: FileMappedHeap
    
    init?(bufferSet: PayloadBufferSet) {
        guard let heap = bufferSet._newHeap() else {
            return nil
        }
        
        self.bufferSet = bufferSet
        self.heap = heap
    }
    
    func new<T>(_ s: T) -> PayloadBufferAllocation? {
        let size = MemoryLayout<T>.size
        guard let r = heap.alloc(size) else { return nil }
        let p = r.initializeMemory(as: T.self, repeating: s, count: 1)
        
        return PayloadBufferAllocation(buffer: self, pointer: p, deallocate: {
//            print("    freeing \(p)")
            p.deinitialize(count: 1)
            self.heap.free(p)
        })
    }
    
    deinit {
        bufferSet?.deleteHeap(heap)
    }
    
}
