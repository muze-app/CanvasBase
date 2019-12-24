//
//  UsefulStructs.swift
//  muze
//
//  Created by Greg Fajen on 5/17/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation

// MARK: Pair

public struct Pair<A, B>: CustomDebugStringConvertible {
    
    public var a: A
    public var b: B
    
    public init(_ a: A, _ b: B) {
        self.a = a
        self.b = b
    }
    
    public var debugDescription: String {
        return "(\(a),\(b))"
    }
    
}

extension Pair: Equatable where A:Equatable, B:Equatable { }
extension Pair: Hashable where A:Hashable, B:Hashable { }
