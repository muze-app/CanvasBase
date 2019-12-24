//
//  Bag.swift
//  muze
//
//  Created by Greg Fajen on 9/2/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation

public struct Bag<Element: Hashable>: Equatable {
    
    public init() { }
    
    private var dict: [Element:Int] = [:]
    
    public var asSet: Set<Element> {
        return Set(dict.keys)
    }
    
    public func contains(_ element: Element) -> Bool {
        let count = dict[element] ?? 0
        return count > 0
    }
    
    public func count(for element: Element) -> Int {
        return dict[element] ?? 0
    }
    
    public mutating func insert(_ element: Element) {
        let count = dict[element] ?? 0
        dict[element] = count + 1
    }
    
    public mutating func remove(_ element: Element) {
        guard let count = dict[element] else { return }
        
        if count - 1 <= 0 {
            dict.removeValue(forKey: element)
        } else {
            dict[element] = count-1
        }
    }
    
    public var asArray: [Element] {
        return dict.flatMap { Array(repeating: $0.key, count: $0.value) }
    }
    
    public static func == (l: Bag<Element>, r: Bag<Element>) -> Bool {
        return l.dict == r.dict
    }
    
    public static func + (l: Bag<Element>, r: Element) -> Bag<Element> {
        var copy = l
        copy.insert(r)
        return copy
    }
    
    public static func - (l: Bag<Element>, r: Element) -> Bag<Element> {
        var copy = l
        copy.remove(r)
        return copy
    }
    
}

public extension Set {
    
    init(_ bag: Bag<Element>) {
        self = bag.asSet
    }
    
}
