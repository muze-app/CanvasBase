//
//  Permutations.swift
//  muze
//
//  Created by Greg on 1/18/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation

public struct Permutations<Element: Hashable> {
    
    public let removes: [RemovePermutation<Element>]
    public let moves:   [MovePermutation<Element>]
    public let inserts: [InsertPermutation<Element>]
    
    public init(from initial: [Element], to target: [Element], log: Bool = false) {
        precondition(!initial.containsDuplicates)
        precondition(!target.containsDuplicates)
        
        let intersection = initial.intersection(target)
        let removed = initial - intersection
        let inserted = target - intersection
        
        var current = initial
        
        var removes = [RemovePermutation<Element>]()
        for element in removed.sorted(using: initial).reversed() {
            let index = current.index(of: element)!
            
            let remove = RemovePermutation<Element>(element: element, oldIndex: index)
            remove.apply(to: &current, log: log)
            
            removes.append(remove)
        }
        
        var moves = [MovePermutation<Element>]()
        let targetBeforeInsertions = intersection.sorted(using: target)
        for element in targetBeforeInsertions.reversed() {
            let oldIndex = current.index(of: element)!
            let newIndex = targetBeforeInsertions.index(of: element)!
            if oldIndex == newIndex { continue }
            
            let move = MovePermutation<Element>(element: element, oldIndex: oldIndex, newIndex: newIndex)
            move.apply(to: &current, log: log)
            
            moves.append(move)
        }
        
        var inserts = [InsertPermutation<Element>]()
        for element in inserted.sorted(using: target) {
            let index = target.index(of: element)!
            
            let insert = InsertPermutation<Element>(element: element, newIndex: index)
            insert.apply(to: &current, log: log)
            
            inserts.append(insert)
        }
        
        self.removes = removes
        self.moves   = moves
        self.inserts = inserts
    }
    
    func apply(to original: [Element], log: Bool = false) -> [Element] {
        var rows = original
        
        for permutation in removes {
            permutation.apply(to: &rows, log: log)
        }
        
        for permutation in moves {
            permutation.apply(to: &rows, log: log)
        }
        
        for permutation in inserts {
            permutation.apply(to: &rows, log: log)
        }
        
        return rows
    }
    
    private static func test() {
        for _ in (0..<100) {
            testOnce()
        }
        print("success!")
        print(" ")
    }
    
    private static func testOnce() {
        
        let removeCount = 6
        let intersectionCount = 12
        let insertCount = 6
        
        let intersection = Array<Int>.random(length: intersectionCount)
        
        var original = intersection
        for _ in 0..<removeCount {
            let index = Int(arc4random_uniform(UInt32(original.count-1)))
            original.insert(Int.random, at: index)
        }
        
        var target = intersection
        for _ in 0..<insertCount {
            let index = Int(arc4random_uniform(UInt32(target.count-1)))
            target.insert(Int.random, at: index)
        }
        
        original = Array(Set(original))
        target = Array(Set(target))
        
        original.randomize()
        target.randomize()
        
        let permutations = Permutations<Int>(from: original, to: target)
        
        print("Original: \(original)")
        print("Target: \(target)")
        
        let result = permutations.apply(to: original)
        
        print("Target: \(target)")
        print("Result: \(target)")
        
        
        assert(result == target)
        print(" ")
    }
    
}

protocol Permutation {
    
    associatedtype Element
    
    func apply(to array: inout [Element], log: Bool)
    
}

extension Permutation where Element: Hashable {
    
    func apply(to array: inout [Element]) {
        apply(to: &array, log: false)
    }
    
}

public struct InsertPermutation<Element: Hashable>: Permutation {
    
    public let element: Element
    public let newIndex: Int
    
    func apply(to array: inout[Element], log: Bool) {
        if log { print("insert \(element) at \(newIndex)") }
        array.insert(element, at: newIndex)
    }
    
}

public struct RemovePermutation<Element: Hashable>: Permutation {
    
    public let element: Element
    public let oldIndex: Int
    
    func apply(to array: inout [Element], log: Bool) {
        if log { print("remove \(element) at \(oldIndex)") }
        array.remove(at: oldIndex)
    }
    
}

public struct MovePermutation<Element: Hashable>: Permutation {
    
    public let element: Element
    public let oldIndex: Int
    public let newIndex: Int
    
    func apply(to array: inout [Element], log: Bool) {
        if log { print("move \(element) from \(oldIndex) to \(newIndex)") }
        array.remove(at: oldIndex)
        array.insert(element, at: newIndex)
    }
    
}

public extension Array where Element: Hashable {
    
    func intersection(_ other: Array<Element>) -> Set<Element> {
        return Set(self).intersection(other)
    }
    
    static func -(lhs: Array<Element>, rhs: Array<Element>) -> Set<Element> {
        return Set(lhs).subtracting(rhs)
    }
    
    static func -(lhs: Array<Element>, rhs: Set<Element>) -> Set<Element> {
        return Set(lhs).subtracting(rhs)
    }
    
    func index(of element: Element) -> Int? {
        return firstIndex { $0 == element }
    }
    
    mutating func removeRandom() -> Element {
        let index: Int = Int(arc4random_uniform(UInt32(count-1)))
        return remove(at: index)
    }
    
    var randomized: Array<Element> {
        var copy = self
        var result: Array<Element> = []
        
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
    func sorted(using order: Array<Element>) -> Array<Element> {
        let result = order.filter { self.contains($0) }
        //        assert(result.count == count)
        return result
    }
    
}

public protocol Randomizable {
    
    static var random: Self { get }
    
}

extension Int: Randomizable {
    
    public static var random: Int {
        return Int(arc4random_uniform(100))
    }
    
}

extension Array where Element: Randomizable {
    
    static func random(length: Int) -> Array {
        return (0..<length).map { _ in
            return Element.random
        }
    }
    
}
