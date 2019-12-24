//
//  File.swift
//  
//
//  Created by Greg Fajen on 12/20/19.
//

import Foundation

public extension String {
    
    var fileSystemRepresentation: UnsafePointer<Int8> {
        return (self as NSString).fileSystemRepresentation
    }
    
}

public struct HeapLayout {
    
    public static let pageSize: Int = sysconf(_SC_PAGESIZE)
    public static let defaultChunkSize = pageSize / 4
    
    public let heapSize: Int
    public let chunkSize: Int
    
    public init(heapSize: Int, chunkSize: Int = HeapLayout.defaultChunkSize) {
        let pageSize   = HeapLayout.pageSize
        self.heapSize  = heapSize.lowestMultiple(of: pageSize)
        self.chunkSize = chunkSize.lowestPowerOfTwo
        
        assert(chunkCount > 0)
    }
    
    public func chunkCount(for length: Int) -> Int {
        let size = length.lowestMultiple(of: chunkSize)
        let chunkCount = size / chunkSize
        return chunkCount
    }
    
    public var chunkCount: Int {
        let (q, r) = heapSize.quotientAndRemainder(dividingBy: chunkSize)
        assert(r == 0)
        return q
    }
    
}

open class Heap: CustomDebugStringConvertible {
    
    public var pageSize: Int { return HeapLayout.pageSize }
    
    public let address: UnsafeMutableRawPointer
    public let layout: HeapLayout
    public let queue: DispatchQueue
    
    public var heapSize: Int { return layout.heapSize }
    public var chunkSize: Int { return layout.chunkSize }
    public var chunkCount: Int { return layout.chunkCount }
    
    public typealias ChunkRange = Range<Int>
    var freeChunks: [ChunkRange]
    var usedChunks: [ChunkRange] = []
    
    public init(layout: HeapLayout, address: UnsafeMutableRawPointer, queue: DispatchQueue) {
        self.layout = layout
        self.address = address
        self.queue = queue
        
        freeChunks = [0..<layout.chunkCount]
    }
    
    public required init?(layout: HeapLayout, queue: DispatchQueue) {
        fatalError()
    }
    
    public var used: MemorySize {
        let chunks = usedChunks.reduce(into: 0) { $0 += $1.length }
        let size = layout.chunkSize * chunks
        return MemorySize(size)
    }
    
    public var allocated: MemorySize {
        return MemorySize(layout.heapSize)
    }
    
    public var debugDescription: String {
        return "Chunk(\(MemorySize(layout.heapSize)), \(address))"
    }
    
    public func pointer(forChunk index: Int) -> UnsafeMutableRawPointer {
        return address.advanced(by: index * chunkSize)
    }
    
    public func chunkIndex(for pointer: UnsafeMutableRawPointer) -> Int? {
        let d: Int = pointer - address
        let (q, r) = d.quotientAndRemainder(dividingBy: chunkSize)
        return (r == 0) ? q : nil
    }
    
    public func contains(_ pointer: UnsafeMutableRawPointer) -> Bool {
        let d: Int = pointer - address
        if d < 0 { return false }
        if d > heapSize { return false }
        return true
    }
    
    // MARK: Alloc
    
    public func alloc(_ size: Int) -> UnsafeMutableRawPointer? {
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
    
    public func smallestChunkRange(forCount count: Int) -> ChunkRange? {
        let availableChunks = freeChunks.filter { $0.length >= count }
        return (availableChunks.sorted { $0.length < $1.length }).first
    }
    
    // MARK: Free
    
    public func free(_ pointer: UnsafeMutableRawPointer) {
        queue.sync { _free(pointer) }
    }
    
    func _free(_ pointer: UnsafeMutableRawPointer) {
//        let chunkIndex = self.chunkIndex(for: pointer)
//        guard let rangeIndex = usedChunks.firstIndex(where: { $0.startIndex == chunkIndex }) else { fatalError() }
//        
//        let range = usedChunks.remove(at: rangeIndex)
//        freeChunks.append(range)
//        
//        _coalesceFreeChunks()
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

public extension Int {
    
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
