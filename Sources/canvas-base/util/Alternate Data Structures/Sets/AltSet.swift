//
//  AltSet.swift
//  muze
//
//  Created by Greg Fajen on 10/10/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation

protocol AltSet: Sequence, ExpressibleByArrayLiteral where Element: Hashable {
    
    init()
    
    func insert(_ element: Element)
    func remove(_ element: Element)
    func removeAll(where predicate: (Element) -> Bool)
    
    func contains(_ element: Element) -> Bool
    
    var count: Int { get }
    
}

extension AltSet {
    
    init(arrayLiteral elements: Element...) {
        self.init()
        
        for e in elements {
            insert(e)
        }
    }
    
    init(_ array: [Element]) {
        self.init()
        for e in array {
            insert(e)
        }
    }
    
}

