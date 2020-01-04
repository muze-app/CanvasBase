//
//  PayloadBufferSet.swift
//  muze
//
//  Created by Greg Fajen on 9/1/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation
import MuzePrelude

public class PayloadBufferAllocation<Collection: NodeCollection> {
    
    let type: Collection
    let buffer: PayloadBuffer<Collection>
    let pointer: UnsafeMutableRawPointer
    let deallocate: ()->()
    
    init(type: Collection, buffer: PayloadBuffer<Collection>, pointer: UnsafeMutableRawPointer, deallocate: @escaping ()->()) {
        self.type = type
        self.buffer = buffer
        self.pointer = pointer
        self.deallocate = deallocate
    }
    
    deinit {
//        print("deallocating payload buffer allocation")
        deallocate()
    }
    
}

// possibly deprecate soon if we continue to use Swift's allocator
// left in for now in case this has better performance
class PayloadBufferSet<Collection: NodeCollection>: HeapSet<DAGHeap> {
    
    init() {
        super.init(layout: .init(heapSize: HeapLayout.pageSize * 4,
                                 chunkSize: 64))
    }
    
    var buffers = WeakSet<PayloadBuffer<Collection>>()
    
    func new<T>(_ s: T, type: Collection) -> PayloadBufferAllocation<Collection>? {
        for buffer in buffers {
            if let allocation = buffer.new(s, type: type) {
                return allocation
            }
        }
        
        guard let buffer = PayloadBuffer<Collection>(bufferSet: self) else { return nil }
        buffers.insert(buffer)
        
        guard let allocation = buffer.new(s, type: type) else {
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
