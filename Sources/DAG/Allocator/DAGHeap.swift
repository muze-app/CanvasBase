//
//  FileMappedHeap.swift
//  muze
//
//  Created by Greg Fajen on 8/14/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation
import MuzePrelude

class DAGHeap: Heap {
    
    required init?(layout: HeapLayout, queue: DispatchQueue) {
        super.init(layout: layout,
                   address: malloc(layout.heapSize),
                   queue: queue)
    }
    
    deinit { Darwin.free(address) }
    
}
