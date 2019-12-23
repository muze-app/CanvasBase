//
//  FileMappedHeap.swift
//  muze
//
//  Created by Greg Fajen on 8/14/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation
import muze_prelude

class FileMappedHeap: Heap {
    
    let path: URL
    let fileDescriptor: Int32
    
    required init?(layout: HeapLayout, queue: DispatchQueue) {
        fatalError()
//        let uuid = UUID().uuidString
//        let path = AssetManager.shared.heapDirectory.appendingPathComponent(uuid)
//        let fd = open(path.path.fileSystemRepresentation, O_RDWR | O_CREAT, 0666)
//
//        guard fd >= 0 else {
//            print("unable to create file")
//            return nil
//        }
//
//        ftruncate(fd, off_t(layout.heapSize))
//
//        let protections: Int32 = PROT_READ | PROT_WRITE
//        let flags: Int32 = MAP_FILE | MAP_SHARED
//
//        guard let r = mmap(nil, layout.heapSize, protections, flags, fd, 0), r != MAP_FAILED else {
//            print("FAILED!")
//            print("Failed to map chunk. errno=\(errno)")
//            return nil
//        }
//
////        print("SUCCESS")
////        print("result: \(String(describing: r))")
//
//        self.path = path
//        self.fileDescriptor = fd
//        self.layout = layout
//        self.address = r
//        self.queue = queue
//
//        freeChunks = [0..<layout.chunkCount]
    }
    
    deinit {
//        print("deinit heap")
        munmap(address, layout.heapSize)
        close(fileDescriptor)
        
        do {
            try FileManager.default.removeItem(at: path)
        } catch _ { }
    }
    
}
