//
//  ArrayExtensions.swift
//  muze
//
//  Created by Greg Fajen on 5/19/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

#if os(macOS)
import AppKit
#else
import UIKit
#endif

public extension Array where Element: OptionalProtocol {
    
    var compact: [Element.Wrapped] {
        return compactMap { $0.asOptional }
    }
    
}

public protocol OptionalProtocol {
    
    associatedtype Wrapped
    
    var asOptional: Wrapped? { get }
    
}

extension Optional: OptionalProtocol {
    
    public var asOptional: Wrapped? { self }
    
}

public extension Optional {
    
    var array: [Wrapped] {
        if let s = self {
            return [s]
        } else {
            return []
        }
    }
    
    var exists: Bool {
        return self != nil
    }
    
}

public extension Array where Element == CGFloat {
    
    var minimum: CGFloat {
        if count == 1 { return first! }
        return reduce(CGFloat.greatestFiniteMagnitude) { Swift.min($0, $1) }
    }
    
    var maximum: CGFloat {
        if count == 1 { return first! }
        return reduce(-CGFloat.greatestFiniteMagnitude) { Swift.max($0, $1) }
    }
    
}

public extension Array where Element: Hashable {
    
    func intersection(_ other: [Element]) -> Set<Element> {
        return Set(self).intersection(other)
    }
    
    static func - (lhs: [Element], rhs: [Element]) -> Set<Element> {
        return Set(lhs).subtracting(rhs)
    }
    
    static func - (lhs: [Element], rhs: Set<Element>) -> Set<Element> {
        return Set(lhs).subtracting(rhs)
    }
    
    func index(of element: Element) -> Int? {
        return firstIndex { $0 == element }
    }
    
    mutating func removeRandom() -> Element {
        let index: Int = Int(arc4random_uniform(UInt32(count-1)))
        return remove(at: index)
    }
    
    var randomized: [Element] {
        var copy = self
        var result: [Element] = []
        
        while !copy.isEmpty {
            result.append(copy.removeRandom())
        }
        
        return result
    }
    
    mutating func randomize() {
        self = randomized
    }
    
    var containsDuplicates: Bool {
        return count != Set(self).count
    }
    
}

public extension Set {
    
    // assumes that order contains every element in self
    // also assumes array contains no duplicates
    func sorted(using order: [Element]) -> [Element] {
        let result = order.filter { self.contains($0) }
        //        assert(result.count == count)
        return result
    }
    
}

public extension Array {
    
    @available(*, deprecated)
    func filter2(_ isIncluded: (Element) -> Bool) -> (included: [Element], excluded: [Element]) {
        discriminate(isIncluded)
    }
    
    func discriminate(_ isIncluded: (Element) -> Bool) -> (included: [Element], excluded: [Element]) {
        var included = [Element]()
        var excluded = [Element]()
        
        for element in self {
            if isIncluded(element) {
                included.append(element)
            } else {
                excluded.append(element)
            }
        }
        
        return (included, excluded)
    }
    
}
