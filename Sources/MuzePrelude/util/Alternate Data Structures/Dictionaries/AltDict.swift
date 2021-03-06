//
//  AltDict.swift
//  muze
//
//  Created by Greg Fajen on 10/8/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation

public protocol AltDict: Sequence, ExpressibleByDictionaryLiteral where Key: Hashable {
    
    associatedtype Value
    
    init()
    
    subscript(key: Key) -> Value? { get set }
    
    var pairs: [(Key, Value)] { get }
    
    var dict: [Key:Value] { get }
    var keys: [Key] { get }
    var values: [Value] { get }
    
}

extension AltDict {
    
    public init(dictionaryLiteral elements: (Key, Value)...) {
        self.init()
        for (k, v) in elements {
            self[k] = v
        }
    }
    
    public init(_ dict: [Key:Value]) {
        self.init()
        for (k, v) in dict {
            self[k] = v
        }
    }
    
    public var pairs: [(Key, Value)] {
        return keys.compactMap { (key) -> (Key, Value)? in
            if let value = self[key] {
                return (key, value)
            } else {
                return nil
            }
        }
    }
    
    public func makeIterator() -> IndexingIterator<[(Key, Value)]> {
        return pairs.makeIterator()
    }
    
}
