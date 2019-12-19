//
//  Bag.swift
//  muze
//
//  Created by Greg Fajen on 9/2/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation

struct Bag<Element: Hashable>: Equatable {
    
    init() { }
    
    private var dict: [Element:Int] = [:]
    
    var asSet: Set<Element> {
        return Set(dict.keys)
    }
    
    func contains(_ element: Element) -> Bool {
        let count = dict[element] ?? 0
        return count > 0
    }
    
    func count(for element: Element) -> Int {
        return dict[element] ?? 0
    }
    
    mutating func insert(_ element: Element) {
        let count = dict[element] ?? 0
        dict[element] = count + 1
    }
    
    mutating func remove(_ element: Element) {
        guard let count = dict[element] else { return }
        
        if count - 1 <= 0 {
            dict.removeValue(forKey: element)
        } else {
            dict[element] = count-1
        }
    }
    
    var asArray: [Element] {
        return dict.flatMap { Array(repeating: $0.key, count: $0.value) }
    }
    
    static func == (l: Bag<Element>, r: Bag<Element>) -> Bool {
        return l.dict == r.dict
    }
    
    static func + (l: Bag<Element>, r: Element) -> Bag<Element> {
        var copy = l
        copy.insert(r)
        return copy
    }
    
    static func - (l: Bag<Element>, r: Element) -> Bag<Element> {
        var copy = l
        copy.remove(r)
        return copy
    }
    
}

extension Set {
    
    init(_ bag: Bag<Element>) {
        self = bag.asSet
    }
    
}
