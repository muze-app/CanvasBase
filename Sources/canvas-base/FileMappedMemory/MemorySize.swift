//
//  MemorySize.swift
//  
//
//  Created by Greg Fajen on 12/19/19.
//

import UIKit

struct MemorySize: Equatable, ExpressibleByIntegerLiteral, Comparable, CustomDebugStringConvertible {
    
    let size: Int
    
    init(_ size: Int)     { self.size = size }
    init(_ size: CGFloat) { self.size = Int(size) }
    init(_ size: Float)   { self.size = Int(size) }
    init(_ size: UInt64)  { self.size = Int(size) }
    init(integerLiteral value: Int) { self.size = value }
    
    static func +(lhs: MemorySize, rhs: MemorySize) -> MemorySize {
        return MemorySize(lhs.size + rhs.size)
    }
    
    static func -(l: MemorySize, r: MemorySize) -> MemorySize {
        return MemorySize(l.size - r.size)
    }
    
    static func /(lhs: MemorySize, rhs: MemorySize) -> MemorySize {
        return MemorySize(lhs.size / rhs.size)
    }
    
    static func *(lhs: MemorySize, rhs: Float) -> MemorySize {
        return MemorySize(Float(lhs.size) * rhs)
    }
    
    static func < (lhs: MemorySize, rhs: MemorySize) -> Bool {
        return lhs.size < rhs.size
    }
    
    var debugDescription: String {
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
