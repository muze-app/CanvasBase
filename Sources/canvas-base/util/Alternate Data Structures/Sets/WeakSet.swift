//
//  WeakSet.swift
//  muze
//
//  Created by Greg on 1/25/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation

final class WeakSet<Element: AnyObject & Hashable>: AltSet {
    
    let table = NSHashTable<Element>.weakObjects()
    
    init() { }
    
    func insert(_ element: Element) {
        table.add(element)
    }
    
    func remove(_ element: Element) {
        table.remove(element)
    }
    
    func removeAll(where predicate: (Element) -> Bool) {
        for element in self {
            if predicate(element) {
                table.remove(element)
            }
        }
    }
    
    func contains(_ element: Element) -> Bool {
        return table.contains(element)
    }
    
    var count: Int {
        return table.allObjects.count
    }
    
    typealias IteratorType = IndexingIterator<[Element]>
    
    func makeIterator() -> IteratorType {
        return table.allObjects.makeIterator()
    }
    
}
