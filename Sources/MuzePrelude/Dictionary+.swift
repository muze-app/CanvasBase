//
//  Dictionary+.swift
//  CanvasBaseTests
//
//  Created by Greg Fajen on 12/30/19.
//

import Foundation

public extension Dictionary {
    
    init(_ keys: Set<Key>, _ map: (Key) -> Value) {
        self.init(uniqueKeysWithValues: keys.map { ($0, map($0)) })
    }
    
    init(_ keys: [Key], _ map: (Key) -> Value) {
        self.init(Set(keys), map)
    }
    
}
