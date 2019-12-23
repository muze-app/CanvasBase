//
//  PayloadBufferSet.swift
//  muze
//
//  Created by Greg Fajen on 9/1/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation
import muze_prelude

class PayloadBufferAllocation {
    
    let buffer: PayloadBuffer
    let pointer: UnsafeMutableRawPointer
    let deallocate: ()->()
    
    init(buffer: PayloadBuffer, pointer: UnsafeMutableRawPointer, deallocate: @escaping ()->()) {
        self.buffer = buffer
        self.pointer = pointer
        self.deallocate = deallocate
    }
    
    deinit {
//        print("deallocating payload buffer allocation")
        deallocate()
    }
    
}

class PayloadBufferSet: HeapSet<DAGHeap> {
    
    init() {
        super.init(layout: .init(heapSize: HeapLayout.pageSize * 4, chunkSize: 64))
    }
    
    var buffers = WeakSet<PayloadBuffer>()
    
    func new<T>(_ s: T) -> PayloadBufferAllocation? {
        for buffer in buffers {
            if let allocation = buffer.new(s) {
                return allocation
            }
        }
        
        guard let buffer = PayloadBuffer(bufferSet: self) else { return nil }
        buffers.insert(buffer)
        
        guard let allocation = buffer.new(s) else {
            let size = MemoryLayout<T>.size
            if size > buffer.heap.heapSize {
                fatalError("Massive payload of size \(size) doesn't fit!")
            } else {
                fatalError("Unable to allocate memory somehow")
            }
        }
        
        return allocation
    }
    
}
