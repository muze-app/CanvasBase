//
//  MemoryManaged.swift
//  muze
//
//  Created by Greg on 1/24/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import UIKit

public struct MemorySize: Equatable, ExpressibleByIntegerLiteral, Comparable, CustomDebugStringConvertible {
    
    public let size: Int
    
    public init(_ size: Int) { self.size = size }
    public init<T: BinaryInteger>(_ size: T) { self.size = Int(size) }
    public init<F: BinaryFloatingPoint>(_ size: F) { self.size = Int(size) }
    public init(integerLiteral value: Int) { self.size = value }
    
    public static func + (lhs: MemorySize, rhs: MemorySize) -> MemorySize {
        return MemorySize(lhs.size + rhs.size)
    }
    
    public static func - (l: MemorySize, r: MemorySize) -> MemorySize {
        return MemorySize(l.size - r.size)
    }
    
    public static func / (lhs: MemorySize, rhs: MemorySize) -> MemorySize {
        return MemorySize(lhs.size / rhs.size)
    }
    
    public static func * (lhs: MemorySize, rhs: Float) -> MemorySize {
        return MemorySize(Float(lhs.size) * rhs)
    }
    
    public static func < (lhs: MemorySize, rhs: MemorySize) -> Bool {
        return lhs.size < rhs.size
    }
    
    public var debugDescription: String {
        var s = Double(size)
        var units = ["bytes", "KB", "MB", "GB", "TB", "PB"]
        
        while s > 1000, units.count > 1 {
            s /= 1000
            units.removeFirst()
        }
        
        let unit = units.first!
        s = round(s*10)/10
        return "\(s) \(unit)"
    }
    
}

public typealias MemoryHash = [Int:MemorySize]

public protocol MemoryManageeLeaf: MemoryManagee {
    
    var memorySize: MemorySize { get }
    
    var hashValue: Int { get }
    
}

public protocol MemoryManagee {
    
    var memoryHash: MemoryHash { get }
    
}

public extension MemoryManageeLeaf {
    
    var memoryHash: MemoryHash {
        return [hashValue:memorySize]
    }
    
}

public extension Dictionary where Key == Int, Value == MemorySize {
    
    static func + (lhs: MemoryHash, rhs: MemoryHash) -> MemoryHash {
        return lhs.merging(rhs) { (a, b) -> MemorySize in
            assert(a == b)
            return a
        }
    }
    
    static func + (lhs: MemoryHash, rhs: MemoryManageeLeaf) -> MemoryHash {
        var result = lhs
        result[rhs.hashValue] = rhs.memorySize
        return result
    }
    
    static func + (lhs: MemoryHash, rhs: MemoryManagee) -> MemoryHash {
        return lhs + rhs.memoryHash
    }
    
    static func += (lhs: inout MemoryHash, rhs: MemoryHash) {
        lhs.merge(rhs) { (a, b) -> MemorySize in
            assert(a == b)
            return a
        }
    }
    
    static func += (lhs: inout MemoryHash, rhs: MemoryManageeLeaf) {
        lhs[rhs.hashValue] = rhs.memorySize
    }
    
    static func += (lhs: inout MemoryHash, rhs: MemoryManagee) {
        lhs += rhs.memoryHash
    }
    
    init(_ leaf: MemoryManageeLeaf) {
        self = leaf.memoryHash
    }
    
    var size: MemorySize {
        return reduce(0) { $0 + $1.value }
//        return reduce(0, { (size: MemorySize, x) -> MemorySize in
//            return size + x.value
//        })
    }
    
}

//extension Array: MemoryManageeLeaf where Element : Hashable {
//
//    var memorySize: MemorySize {
//        let size = MemoryLayout<Element>.size
//        return MemorySize(size * count)
//    }
//
//}

extension Array: MemoryManagee where Element: MemoryManagee {
    
    public var memoryHash: MemoryHash {
        return reduce([:]) { $0 + $1 }
    }
    
}
