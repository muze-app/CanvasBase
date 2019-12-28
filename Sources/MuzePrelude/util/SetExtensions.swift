//
//  File.swift
//  
//
//  Created by Greg Fajen on 12/19/19.
//

import Foundation

public extension Set {
    
    static func + (lhs: Set<Element>, rhs: Set<Element>) -> Set<Element> {
        return lhs.union(rhs)
    }
    
    init(_ e: Element?) {
        if let e = e {
            self = Set([e])
        } else {
            self = Set()
        }
    }
    
}
