//
//  FileMappedHeap.swift
//  muze
//
//  Created by Greg Fajen on 8/14/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation

extension String {
    
    var fileSystemRepresentation: UnsafePointer<Int8> {
        return (self as NSString).fileSystemRepresentation
    }
    
}

struct HeapLayout {
    
    static let pageSize = FileMappedHeap.pageSize
    static let defaultChunkSize = pageSize / 4
    
    let heapSize: Int
    let chunkSize: Int
    
    init(heapSize: Int, chunkSize: Int = HeapLayout.defaultChunkSize) {
        let pageSize   = FileMappedHeap.pageSize
        self.heapSize  = heapSize.lowestMultiple(of: pageSize)
        self.chunkSize = chunkSize.lowestPowerOfTwo
        
        #if MZE_DEBUG
        _ = chunkCount
        #endif
    }
    
    func chunkCount(for length: Int) -> Int {
        let size = length.lowestMultiple(of: chunkSize)
        let chunkCount = size / chunkSize
        return chunkCount
    }
    
    var chunkCount: Int {
        let (q, r) = heapSize.quotientAndRemainder(dividingBy: chunkSize)
        assert(r == 0)
        return q
    }
    
}

class FileMappedHeap: CustomDebugStringConvertible {
    
    static let pageSize: Int = sysconf(_SC_PAGESIZE)
    var pageSize: Int { return FileMappedHeap.pageSize }
    
    let path: URL
    let fileDescriptor: Int32
    let address: UnsafeMutableRawPointer
    let layout: HeapLayout
    let queue: DispatchQueue
    
    var heapSize: Int { return layout.heapSize }
    var chunkSize: Int { return layout.chunkSize }
    var chunkCount: Int { return layout.chunkCount }
    
    typealias ChunkRange = Range<Int>
    var freeChunks: [ChunkRange]
    var usedChunks: [ChunkRange] = []
    
    init?(layout: HeapLayout, queue: DispatchQueue) {
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
    
    var used: MemorySize {
        let chunks = usedChunks.reduce(into: 0) { $0 += $1.length }
        let size = layout.chunkSize * chunks
        return MemorySize(size)
    }
    
    var allocated: MemorySize {
        return MemorySize(layout.heapSize)
    }
    
    var debugDescription: String {
        return "Chunk(\(MemorySize(layout.heapSize)), \(address))"
    }
    
    func pointer(forChunk index: Int) -> UnsafeMutableRawPointer {
        return address.advanced(by: index * chunkSize)
    }
    
    func chunkIndex(for pointer: UnsafeMutableRawPointer) -> Int? {
        let d: Int = pointer - address
        let (q, r) = d.quotientAndRemainder(dividingBy: chunkSize)
        return (r == 0) ? q : nil
    }
    
    func contains(_ pointer: UnsafeMutableRawPointer) -> Bool {
        let d: Int = pointer - address
        if d < 0 { return false }
        if d > heapSize { return false }
        return true
    }
    
    // MARK: Alloc
    
    func alloc(_ size: Int) -> UnsafeMutableRawPointer? {
        var result: UnsafeMutableRawPointer?
        queue.sync {
            result = _alloc(size)
        }
        return result
    }
    
    func _alloc(_ size: Int) -> UnsafeMutableRawPointer? {
//        print("heap alloc \(MemorySize(size))")
//        print("    address: \(address)")
        
        let chunksNeeded = layout.chunkCount(for: size)
        guard let chunkRange = smallestChunkRange(forCount: chunksNeeded) else { return nil }
        guard let index = freeChunks.firstIndex(of: chunkRange) else { fatalError() }
        
        let start = chunkRange.startIndex
        let usedRange = start..<(start+chunksNeeded)
        let freeRange = (start+chunksNeeded)..<chunkRange.upperBound

        if freeRange.length == 0 {
            freeChunks.remove(at: index)
        } else {
            freeChunks[index] = freeRange
        }
        
//        print("    used range: \(usedRange)")
//        print("    free range: \(freeRange)")
        
        usedChunks.append(usedRange)
        
        let p = pointer(forChunk: start)
//        print("    pointer: \(p)")
        assert(contains(p))
        
        return p
    }
    
    func smallestChunkRange(forCount count: Int) -> ChunkRange? {
        let availableChunks = freeChunks.filter { $0.length >= count }
        return (availableChunks.sorted { $0.length < $1.length }).first
    }
    
    // MARK: Free
    
    func free(_ pointer: UnsafeMutableRawPointer) {
        queue.sync { _free(pointer) }
    }
    
    func _free(_ pointer: UnsafeMutableRawPointer) {
        let chunkIndex = self.chunkIndex(for: pointer)
        guard let rangeIndex = usedChunks.firstIndex(where: { $0.startIndex == chunkIndex }) else { fatalError() }
        
        let range = usedChunks.remove(at: rangeIndex)
        freeChunks.append(range)
        
        _coalesceFreeChunks()
    }
    
    // MARK: Sorting and Coalescing
    
    func _sortFreeChunks() {
        freeChunks.sort { $0.startIndex < $1.startIndex }
    }
    
    func _coalesceFreeChunks() {
        _sortFreeChunks()
        
        var newFreeChunks = [ChunkRange]()
        var last: ChunkRange?
        for chunk in freeChunks {
            if let last = last, last.upperBound == chunk.lowerBound {
                newFreeChunks.removeLast()
                newFreeChunks.append(.init(uncheckedBounds: (lower: last.lowerBound, upper: chunk.upperBound)))
            } else {
                newFreeChunks.append(chunk)
            }
            
            last = chunk
        }
        
        freeChunks = newFreeChunks
    }
    
}

extension Int {
    
    func lowestMultiple(of n: Int) -> Int {
        let (q, r) = quotientAndRemainder(dividingBy: n)
        return n * ((r == 0) ? q : q+1)
    }
    
    var lowestPowerOfTwo: Int {
        let me = UInt64(self)
        var result = UInt64(1)
        
        while result < me {
            result = result << 1
        }
    
        return Int(result)
    }
    
}
