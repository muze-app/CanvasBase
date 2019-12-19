//
//  File.swift
//  
//
//  Created by Greg Fajen on 12/19/19.
//

import Foundation

extension Set {
    
    static func + (lhs: Set<Element>, rhs: Set<Element>) -> Set<Element> {
        return lhs.union(rhs)
    }
    
}
