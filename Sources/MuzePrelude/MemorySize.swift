//
//  MemorySize.swift
//  
//
//  Created by Greg Fajen on 12/19/19.
//

import UIKit

public struct MemorySize: Equatable, ExpressibleByIntegerLiteral, Comparable, CustomDebugStringConvertible {
    
    let size: Int
    
    public init(_ size: Int) { self.size = size }
    public init<T: BinaryInteger>(_ size: T) { self.size = Int(size) }
    public init<T: BinaryFloatingPoint>(_ size: T) { self.size = Int(size) }
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
