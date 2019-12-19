//
//  File.swift
//  
//
//  Created by Greg Fajen on 12/19/19.
//

import Foundation

protocol AutoHash: class, Hashable { }
extension AutoHash {
    
    public var hashValue: Int {
        let unsafe = Unmanaged.passUnretained(self).toOpaque()
        return unsafe.hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(hashValue)
    }
    
    public static func == (rhs: Self, lhs: Self) -> Bool {
        return rhs === lhs
    }
    
}
