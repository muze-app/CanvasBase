//
//  LinkedList.swift
//  the app Itself
//
//  Created by Grant Davis on 1/12/18.
//  Copyright © 2018 MUZE LLC. All rights reserved.
//

import Foundation
import MuzeMetal

class LinkedList<Element> {
    
    class Node<Element> {
        var datum: Element
        var next: Node<Element>?
        var previous: Node<Element>?
        
        init(_ input: Element) { self.datum = input }
    }
    
    deinit {
        removeAll()
    }
    
    private var bottomNode : Node<Element>?
    private var topNode    : Node<Element>?
    private var count      : Int = 0
    
    public var nodeCount: Int { return count }
    public var bottom: Node<Element>? { return bottomNode }
    public var top: Node<Element>? { return topNode }
    
    init() {}
    init(with item: Element)             { push(item) }
//    init(with list: LinkedList<Element>) { push(list) }
//    
//    public func push(_ list: LinkedList<Element>) {
//        if list.bottomNode != nil {
//            self.topNode?.next = list.bottomNode
//            self.topNode = list.topNode
//            self.count += list.count
//            
//            if bottomNode == nil
//            { bottomNode = list.bottomNode }
//        }
//    }
    
    public func push(_ item: Element) {
        let newTopNode = Node<Element>(item)
        newTopNode.previous = topNode
        topNode?.next = newTopNode
        topNode = newTopNode
        count += 1
        
        if bottomNode == nil {
            bottomNode = newTopNode
        }
    }
    
    public func pull() -> Element? {
        guard let oldTopNode = topNode else { return nil }
        
        topNode = oldTopNode.previous
        topNode?.next = nil
        count -= 1
        
        if bottomNode === oldTopNode {
            bottomNode = nil
        }
        
        oldTopNode.next = nil
        oldTopNode.previous = nil
            
        return oldTopNode.datum
    }
    
    @discardableResult
    public func poop() -> Element? {  // :)
        guard let oldBottomNode = bottomNode else { return nil }
       
        bottomNode = oldBottomNode.next
        bottomNode?.previous = nil
        count -= 1
            
        if topNode === oldBottomNode {
            topNode = nil
        }
        
        // it turns out, you need to clean your bottom after you poop
        oldBottomNode.next = nil
        oldBottomNode.previous = nil
            
        return oldBottomNode.datum
    }
    
    public func pop(where predicate: (Element)->Bool) {
        print("popping!")
        var lastNode: Node<Element>? = nil
        var currentNode: Node<Element>? = topNode
        let originalCount = count
        
        while currentNode != nil {
            if predicate(currentNode!.datum) {
                
                guard let lastNode = lastNode else {
                    // we're still at the top node, and everything needs to go
                    removeAll()
                    break
                }
                
                var nodeToClean = lastNode.previous
                while let node = nodeToClean {
                    nodeToClean = node.previous
                    node.previous = nil
                    node.next = nil
                }
                
                lastNode.previous = nil
                bottomNode = lastNode
                updateCount()
                break
            }
            
            lastNode = currentNode
            currentNode = currentNode?.previous
        }
        
        print("    list count is now \(count) (was \(originalCount))")
    }
    
    func removeAll() {
        var nodeToClean = topNode
        while let node = nodeToClean {
            nodeToClean = node.previous
            node.previous = nil
            node.next = nil
        }
        
        topNode = nil
        bottomNode = nil
        count = 0
    }
    
    private func updateCount() {
        count = 0
        var currentNode = topNode
        while currentNode != nil {
            count += 1
            currentNode = currentNode?.previous
        }
    }
    
}

// MARK: Iteration

extension LinkedList: Sequence {
    
    func makeIterator() -> LinkedListIterator<Element> {
        return LinkedListIterator<Element>(self)
    }
    
}

struct LinkedListIterator<Element>: IteratorProtocol {
    
    var node: LinkedList<Element>.Node<Element>?
    
    init(_ list: LinkedList<Element>) {
        self.node = list.top
    }
    
    mutating func next() -> Element? {
        if let current = node {
            node = node?.previous
            return current.datum
        }
        
        return nil
    }
    
}

extension LinkedList {
    
    var lazyReversed: ReversedLinkedList<Element> {
        return ReversedLinkedList(self)
    }
    
}

// MARK: Reverse Iteration

struct ReversedLinkedList<Element>: Sequence {
    
    let list: LinkedList<Element>
    
    init(_ list: LinkedList<Element>) {
        self.list = list
    }
    
    func makeIterator() -> ReversedLinkedListIterator<Element> {
        return ReversedLinkedListIterator<Element>(self)
    }
    
}

struct ReversedLinkedListIterator<Element>: IteratorProtocol {
    
    var node: LinkedList<Element>.Node<Element>?
    
    init(_ list: ReversedLinkedList<Element>) {
        self.node = list.list.bottom
    }
    
    mutating func next() -> Element? {
        if let current = node {
            node = node?.next
            return current.datum
        }
        
        return nil
    }
    
}

// MARK: Memory

extension LinkedList: MemoryManagee where Element: MemoryManagee {
    
    var memoryHash: MemoryHash {
        var hash = MemoryHash()

        for element in self {
            hash += element.memoryHash
        }
        
        return hash
    }
    
}
