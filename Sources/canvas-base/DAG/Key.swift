//
//  Key.swift
//  muze
//
//  Created by Greg Fajen on 9/3/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation

typealias CommitKey = Key<DAGSnapshot>

struct Key<Universe>: Hashable, CustomDebugStringConvertible {
    
    let value: UInt64
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }
    
    init(_ value: UInt64) { self.value = value }
    init() { self.value = UInt64(arc4random()) }
    
    var debugDescription: String {
        return String(String(value, radix: 16, uppercase: true).prefix(8))
    }
    
    func with(_ string: String) -> Key<Universe> {
        var hasher = Hasher()
        hasher.combine(value)
        hasher.combine(string)
        
        return Key<Universe>(UInt64(coercing: hasher.finalize()))
    }
    
}

extension UInt64 {
    
    init(coercing i: Int) {
        let ipointer = UnsafeMutablePointer<Int64>.allocate(capacity: 1)
        ipointer.pointee = Int64(i)
        
        let xpointer = UnsafeMutableRawPointer(ipointer)
        
        let upointer = xpointer.assumingMemoryBound(to: UInt64.self)
        self = upointer.pointee
    }
    
}

extension Int {
    
    init(coercing u: UInt64) {
        let upointer = UnsafeMutablePointer<UInt64>.allocate(capacity: 1)
        upointer.pointee = u
        
        let xpointer = UnsafeMutableRawPointer(upointer)
        
        let ipointer = xpointer.assumingMemoryBound(to: Int64.self)
        self = Int(ipointer.pointee)
    }
    
}
