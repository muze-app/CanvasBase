//
//  InputNode.swift
//  muze
//
//  Created by Greg Fajen on 5/17/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation

typealias AbstractInputKey = Hashable

//class InputNode<PayloadType: NodePayload, InputKey: AbstractInputKey>: PayloadNode<PayloadType> {
//
//    required init(_ payload: PayloadType, _ key: Key = Key(), _ graph: NodeGraph? = nil) {
//        super.init(payload, key, graph)
//    }
//
//    // MANDATORY for subclasses
//    var allKeys: [InputKey] { fatalError() }
//    func forInput(_ key: InputKey, _ mutate: (inout Node?)->()) { fatalError() }
//    var primaryInput: Node? {
//        get { fatalError() }
//        set { fatalError() }
//    }
//
//    final func input(for key: InputKey) -> InputType? {
//        var x: InputType? = nil
//        forInput(key) { x = $0 }
//        return x
//    }
//
//    final func set(input: InputType?, for key: InputKey) {
//        forInput(key) { $0 = input }
//    }
//
//    final func forEachInput(_ mutate: (inout Node?)->()) {
//        for key in allKeys {
//            forInput(key, mutate)
//        }
//    }
//
////    final override func addingCacheNodes(_ keysToCache: [NodeKey]) -> Node? {
////        if let cacheNode = self as? CacheNode {
////            return cacheNode.input?.addingCacheNodes(keysToCache + [key])
////        }
////
////        forEachInput {
////            $0 = $0?.addingCacheNodes(keysToCache)
////        }
////
////        return super.addingCacheNodes(keysToCache)
////    }
//
//    override var linearized: [Node] {
//        if let more = primaryInput?.linearized {
//            return [self] + more
//        } else {
//            return [self]
//        }
//    }
//
//    final override func _purgingUnneededCaches(isBehindCache: Bool) -> Node? {
//        fatalError()
////        if let self = self as? CacheNode {
////            if isBehindCache {
////                return self.input
////            }
////
////            let hasPayload = true
////            self.input = self.input?._purgingUnneededCaches(isBehindCache: hasPayload)
////            return self
////        }
////
////        forEachInput {
////            $0 = $0?._purgingUnneededCaches(isBehindCache: isBehindCache)
////        }
////
////        return self
//    }
//
//    // MARK: Inputs
//
//
//    final override var inputs: [InputType] {
//        return allKeys.compactMap { input(for: $0) }
//    }
//
//    subscript(key: InputKey) -> InputType? {
//        get { return input(for: key) }
//        set { set(input: newValue, for: key) }
//    }
//
////    final override public func transform(by transform: AffineTransform) {
////        payload = payload.transformed(by: transform)
////        for input in inputs {
////            input.transform(by: transform)
////        }
////    }
//
//    // MARK: Hashing
//
//    final override func hash(into hasher: inout Hasher, includeKeys: Bool) {
//        hasher.combine(nodeType)
//
//        if includeKeys {
//            hasher.combine(key)
//        }
//
//        hasher.combine(payload)
//
//        for inputKey in allKeys {
//            hasher.combine(inputKey)
//
//            if let node = self[inputKey] {
////                hasher.combine(node)
//                node.hash(into: &hasher, includeKeys: includeKeys)
//            }
//        }
//    }
//
//    // MARK: Updating
//
//    final override func update(from node: Node) {
////        print("update from \(node)")
////        guard graph.exists else { fatalError() }
////
////        let node = node as! InputNode<PayloadType,InputKey>
////        assert(node.key == key)
////
////        payload = node.payload
////
////        for inputKey in allKeys {
////            update(inputFor: inputKey, from: node[inputKey])
////        }
////
////        resetRenderExtent()
//    }
//
//    final func update(inputFor inputKey: InputKey, from node: Node?) {
////        print("update input \(inputKey) with \(String(describing: node))")
////        guard let node = node else {
////            set(input: nil, for: inputKey)
////            resetRenderExtent()
////            return
////        }
////
////        guard let graph = graph else { fatalError() }
////
////        if let cache = self as? CacheNode, let existing = graph.cacheNodes[key] {
////            cache.cachedPayload = existing.cachedPayload
////            cache.cachedHash = existing.cachedHash
////
////            let node = node as! CacheNode
////            node.cachedPayload = cache.cachedPayload
////            node.cachedHash = cache.cachedHash
////
////            graph.cacheNodes[key] = cache
////        }
////
////        if let existing = input(for: inputKey), existing.key == node.key {
////            existing.update(from: node)
////        } else if let existing = graph[node.key] {
////            existing.update(from: node)
////            set(input: existing, for: inputKey)
////        } else {
////            let newNode = Node.create(from: node, graph: graph)
////            graph.add(node: newNode)
////            newNode.update(from: node)
////            set(input: newNode, for: inputKey)
////        }
//    }
//
//    // MARK: Optimizing
//
////    final override func optimizeInputs() {
////        forEachInput {
////            $0 = $0?.optimize()
////        }
////
////    }
//
//    final override func replace(_ keyToReplace: NodeKey, with replacement: Node) {
//        for inputKey in allKeys {
//            if let input = self[inputKey] {
//                if input.key == keyToReplace {
//                    self[inputKey] = replacement
//                } else {
//                    input.replace(keyToReplace, with: replacement)
//                }
//            }
//        }
//    }
//
//}

// MARK: Unary Input Node

//class UnaryInputNode<PayloadType: NodePayload>: InputNode<PayloadType, One> {
//
//    var input: Node?
//
//    final override var allKeys: [One] {
//        return [.one]
//    }
//
//    final override func forInput(_ key: One, _ mutating: (inout Node?) -> ()) {
//        mutating(&input)
//    }
//
//
//
////    final override func set(input node: InputType?, for key: One) {
////        self.input = node
////    }
////
////    final override func input(for key: One) -> InputType? {
////        return input
////    }
//
//    final override var primaryInput: Node? {
//        get { return self[.one] }
//        set { self[.one] = newValue }
//    }
//
//    override var userExtent: UserExtent {
//        return input?.userExtent ?? .nothing
//    }
//
//}

// MARK: Binary Input Node

//class BinaryInputNode<PayloadType: NodePayload>: InputNode<PayloadType, Bool> {
//
//    final override var allKeys: [Bool] { return [true, false] }
//
////    final override func input(for key: Bool) -> InputType? {
////        switch key {
////        case true: return inputT
////        case false: return inputF
////        }
////    }
////
////    final override func set(input node: InputType?, for key: Bool) {
////        switch key {
////        case true: self.inputT = node
////        case false: self.inputF = node
////        }
////    }
//
//    final override func forInput(_ key: Bool, _ mutate: (inout Node?) -> ()) {
//        switch key {
//        case true: mutate(&inputT)
//        case false: mutate(&inputF)
//        }
//    }
//
//    var inputT: Node?
//    var inputF: Node?
//
//}

extension Dictionary {

    init(_ keys: Set<Key>, _ map: (Key) -> Value) {
        self.init(uniqueKeysWithValues: keys.map { ($0, map($0)) })
    }

    init(_ keys: [Key], _ map: (Key) -> Value) {
        self.init(Set(keys), map)
    }

}
