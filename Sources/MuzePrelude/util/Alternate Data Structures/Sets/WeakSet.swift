//
//  WeakSet.swift
//  muze
//
//  Created by Greg on 1/25/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation

public final class WeakSet<Element: AnyObject & Hashable>: AltSet {
    
    let table = NSHashTable<Element>.weakObjects()
    
    public init() { }
    
    public func insert(_ element: Element) {
        table.add(element)
    }
    
    public func remove(_ element: Element) {
        table.remove(element)
    }
    
    public func removeAll(where predicate: (Element) -> Bool) {
        for element in self {
            if predicate(element) {
                table.remove(element)
            }
        }
    }
    
    public func contains(_ element: Element) -> Bool {
        return table.contains(element)
    }
    
    public var count: Int {
        return table.allObjects.count
    }
    
    public typealias IteratorType = IndexingIterator<[Element]>
    
    public func makeIterator() -> IteratorType {
        return table.allObjects.makeIterator()
    }
    
}
