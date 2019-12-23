//
//  FileMappedHeapManager.swift
//  muze
//
//  Created by Greg Fajen on 8/15/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation
import muze_prelude

class FileMappedHeapManager {
    
    static let shared = FileMappedHeapManager()
    
    let main = FileMappedHeapSet(heapSize: 16 * 1024 * 1024)
    let nano = FileMappedHeapSet(heapSize: HeapLayout.pageSize, chunkSize: 256)
//    let node = FileMappedHeapSet(heapSize: FileMappedHeapSet.pageSize * 4, chunkSize: 64)
    
    enum Set {
        case main, nano//, node
    }
    
    func set(for set: Set) -> FileMappedHeapSet {
        switch set {
            case .main: return main
            case .nano: return nano
//            case .node: return node
        }
    }
    
    var used: MemorySize {
        return main.used + nano.used
    }
    
    var allocated: MemorySize {
        return main.allocated + nano.allocated
    }
    
    func tempCheckSize() {
        print("IMAGE HEAP: \(used) / \(allocated)")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.tempCheckSize()
        }
    }
    
}
