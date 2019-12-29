//
//  Node.swift
//  muze
//
//  Created by Greg Fajen on 5/17/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation
import MuzePrelude

public typealias NodeKey = Key<GenericNode<MockNodeCollection>>

// temp - for optimizing memory layout / size
final class XNode<Collection: NodeCollection> {
    
    var key: NodeKey
    var graph: InternalDirectSnapshot<Collection>
    
    init(key: NodeKey = NodeKey(), graph: DAGBase<Collection>) {
        self.key = key
        self.graph = graph as! InternalDirectSnapshot<Collection>
    }
    
}

open class GenericNode<Collection: NodeCollection>: Hashable, CustomDebugStringConvertible {
    
    public typealias Node = GenericNode<Collection>
    public typealias Graph = DAGBase<Collection>
    public typealias MutableGraph = MutableDAG<Collection>
    
    public typealias Key = NodeKey
    public var key: Key
    public var graph: Graph
    
    public var type: Collection { graph.type(for: key)! }
    
    public var contentHash: Int { fatalError() }
    
    public init(_ key: Key = .init(), graph: DAGBase<Collection>) {
        self.key = key
        self.graph = graph
    }
    
    // MARK: - Edges
    
    @discardableResult
    public func add(to graph: MutableDAG<Collection>, useFreshKeys: Bool) -> NodeKey {
        let source = self.graph
        
        var newEdgeMap = [Int:NodeKey]()
        
        for (i, oldKey) in edgeMap {
            let node = source.node(for: oldKey)
            let newKey = node.add(to: graph, useFreshKeys: useFreshKeys)
            newEdgeMap[i] = newKey
        }
        
        let newKey = useFreshKeys ? NodeKey() : key
        
        graph.setType(type, for: newKey)
        graph.setEdgeMap(newEdgeMap, for: newKey)
        
        let rev = source.reverseEdges(for: key) ?? Bag<NodeKey>()
        graph.setReverseEdges(rev, for: newKey)
        
        let data = source.revData(for: key) ?? NodeRevData()
        graph.setRevData(data, for: key)
        
        return newKey
    }
    
    public func add(diffTo graph: MutableGraph, parent: Graph) {
        let source = graph
        
        for (_, key) in edgeMap {
            let node = source.node(for: key)
            node.add(diffTo: graph, parent: parent)
        }
        
        if let sourceType = source.type(for: key), parent.type(for: key) != sourceType {
            graph.setType(sourceType, for: key)
        }
        
        if let sourceEdgeMap = source.edgeMap(for: key), parent.edgeMap(for: key) != sourceEdgeMap {
            graph.setEdgeMap(sourceEdgeMap, for: key)
        }
        
        let rev = source.reverseEdges(for: key) ?? Bag<NodeKey>()
        graph.setReverseEdges(rev, for: key)
        
        let data = source.revData(for: key) ?? NodeRevData()
        graph.setRevData(data, for: key)
    }
    
    public final var edgeMap: [Int:NodeKey] {
        graph.edgeMap(for: key) ?? [:]
    }
    
    public final var sortedEdges: [(Int, NodeKey)] {
        edgeMap.sorted { $0.key < $1.key }
    }
    
    public final var inputs: [GenericNode] {
        sortedEdges.map { graph.node(for: $0.1) }
    }
    
    public final var inputCount: Int { edgeMap.count }

    // MARK: - Logging
    
    var linearized: [GenericNode] {
        return [self]
    }
    
    public var className: String {
        return "\(Swift.type(of: self))"
    }
    
    open var debugDescription: String {
        return "\(className) (\(key))"
    }
    
    public func log(with indentation: String = "") {
        print("\(indentation)\(self) (\(key))")
        
        for input in inputs {
            input.log(with: "\t" + indentation)
        }
    }

    // MARK: - Hashing and Equality
    
    public static func == (lhs: GenericNode, rhs: GenericNode) -> Bool {
        if lhs.key != rhs.key { return false }
        return lhs.equal(to: rhs, ignoringKey: false)
    }
    
    public func hash(into hasher: inout Hasher, includeKeys: Bool) {
        fatalError()
    }
    
    public final func hash(into hasher: inout Hasher) {
        hash(into: &hasher, includeKeys: true)
    }
    
    public final func equal(to other: GenericNode, ignoringKey: Bool = false) -> Bool {
        if ignoringKey || equalKey(to: other),
            equalPayload(to: other),
            equalInputs(to: other, ignoringKey: ignoringKey) {
            return true
        } else {
            return false
        }
    }
    
    public final func equalKey(to other: GenericNode) -> Bool {
        return key == other.key
    }
    
    public final func equalInputs(to other: GenericNode, ignoringKey: Bool) -> Bool {
        let ai = inputs
        let bi = other.inputs
        
        if ai.count != bi.count { return false }
        
        for (a, b) in zip(ai, bi) {
            if !a.equal(to: b, ignoringKey: ignoringKey) {
                return false
            }
        }
        
        return true
    }
    
    func equalPayload(to other: GenericNode) -> Bool {
        fatalError()
    }
    
    func payloadAs<T>() -> T? {
        return nil
    }

    // MARK: - Utilities

    func freshenKeys() {
        key = NodeKey()
        for input in inputs {
            input.freshenKeys()
        }
    }
    
    func replace(_ keyToReplace: NodeKey, with replacement: GenericNode) {
        fatalError()
    }
    
    func foreach(_ block: (GenericNode)->()) {
        for input in inputs {
            input.foreach(block)
        }
        
        block(self)
    }
    
    func contains(_ key: NodeKey) -> Bool {
        if self.key == key { return true }
        
        for input in inputs {
            if input.contains(key) {
                return true
            }
        }
        
        return false
    }
    
    func intersects(_ keys: Set<NodeKey>) -> Bool {
        if keys.contains(key) { return true }
        
        for input in inputs {
            if input.intersects(keys) {
                return true
            }
        }
        
        return false
    }
    
    func nodes(thatDoNotContain key: NodeKey) -> [NodeKey] {
        if self.key == key { return [] }
        if !contains(key) { return [key] }
        
        return inputs.flatMap { $0.nodes(thatDoNotContain: key) }
    }
    
    func nodes(thatDoNotContain keys: Set<NodeKey>) -> [NodeKey] {
        if keys.contains(key) { return [] }
        if !intersects(keys) { return [key] }
        
        return inputs.flatMap { $0.nodes(thatDoNotContain: keys) }
    }
    
    func first(where predicate: (GenericNode) -> Bool) -> GenericNode? {
        if predicate(self) { return self }
        
        for input in inputs {
            if let result = input.first(where: predicate) {
                return result
            }
        }
        
        return nil
    }
    
    func all(where predicate: (GenericNode) -> Bool) -> [GenericNode] {
        var all = inputs.flatMap { $0.all(where: predicate) }
        
        if predicate(self) { all.append(self) }
        
        return all
    }
    
    func all<U: GenericNode>(as type: U.Type) -> [U] {
        return all { $0 is U } as! [U]
    }
    
    // MARK: Payloads and Extents
    
    open func renderPayload(for options: Collection.RenderOptionsType) -> Collection.RenderPayloadType? {
        fatalError()
    }
    
    open var renderExtent: Collection.RenderExtentType { calculatedRenderExtent }
    open var calculatedRenderExtent: Collection.RenderExtentType {
        print("\(self) doesn't implement calculatedRenderExtent")
        fatalError()
    }
    
    open var userExtent: Collection.UserExtentType { calculatedUserExtent }
    open var calculatedUserExtent: Collection.UserExtentType {
        print("\(self) doesn't implement calculatedUserExtent")
        fatalError()
    }
    
    // MARK: Other
    
    open var isIdentity: Bool { false }
    open var isInvisible: Bool { false }
    
    open var cost: Int { inputCost }
    public final var inputCost: Int {
        inputs.reduce(into: 0) { $0 += $1.cost }
    }
    
    public var nodeInputs: NodeInputs<Collection> {
        get { return NodeInputs(self) }
        set { } // ok, we be cheating a little here. the action has already happened before this gets called
    }
    
}

// MARK: - OLD
// MARK: - OLD
// MARK: - OLD
//
//@available(*, deprecated)
//class ComplicatedNode: Node {
//    
////    public var key: Key
//    public typealias Key = NodeKey
//    
////    public var inputs: [InputType] { fatalError() }
////    public var inputCount: Int { return inputs.count }
////    public typealias InputType = ComplicatedNode
//    
////    var contentHash: Int { fatalError() }
//    
////    public init(_ key: Key = Key()) {
////        super.init(key: key, graph: nil)
////    }
//    
//    var nodeType: NodeType {
//        fatalError("node type not implemented by \(className)")
//    }
//    
//    // MARK: Updating
//    
//    func update(from node: ComplicatedNode) {
//        fatalError()
//    }
//    
//    // MARK: Optimizing
//    
////    final public func optimizeOnce() -> Optimization? {
////        guard let self = self as? DNode else { return nil }
////
//////        print("Optimizing \(self)")
////        //        asNodeOrOpt.log()
////        for optimize in possibleOptimizations {
////            if let optimization = optimize(self) {
//////                print("    optimized via \(optimization)")
//////                print("    returning \(String(describing: optimization.right))")
////                return optimization
////            }
////        }
////
////        return nil
////    }
////
////    final public func optimize(throughCacheNodes: Bool) -> DNode? {
////        if !throughCacheNodes, self is CacheNode { return (self as! DNode) }
////        optimizeInputs(throughCacheNodes: throughCacheNodes)
////
////        if let self = self as? DNode {
////            guard var opt = self.optimizeOnce() else { return self }
////
////            while let right = opt.right, let next = right.optimizeOnce() {
////                opt = next
////            }
////
////            //            print("   done optimizing \(trimmedName)(\(key))")
////            //            opt.logOpt(with: "\t")
////            return opt.right
////        } else {
////            fatalError()
////        }
////    }
////
////    func optimizeInputs(throughCacheNodes: Bool) {
////        fatalError()
////    }
//    
//    var trimmedName: String.SubSequence {
//        let name = className
//        let index = name.firstIndex { $0 == "<" }
//        return name.prefix(upTo: index!)
//    }
//    
//    func addingCacheNodes(_ keysToCache: [NodeKey]) -> DNode? {
//        fatalError()
////        guard keysToCache.contains(key) else { return self as! DNode }
////
////        let cacheNode = CacheNode(node: self)
//////        graph?.cacheNodes[key] = cacheNode
////        cacheNode.input = self
////        return cacheNode
//    }
//    
////    final public func deepOptimize() -> NodeOrOpt {
//////        print("\(trimmedName)(\(key)).deepOptimize()")
////        
//////        if self is BlendNode {
//////            print("\twut")
//////        }
////        
////        
////        
////        optimizeInputs()
////        return asNodeOrOpt
////    }
//

//    
////    public var possibleOptimizations: [OptFunc] { return [] }
////
////    final var removeIdentity: OptFunc { return { RemoveIdentityOptimization($0) } }
////    final var removeInvisibles: OptFunc { return { RemoveInvisibleOptimization($0) } }
//    
//    // MARK: Rendering
//    
//    var cacheable: Bool { return true }
//    var worthCaching: Bool { return false }
////    final var notWorthCaching: Bool { return !worthCaching }
//    
////    public func renderPayload(for options: RenderOptions) -> RenderPayload? {
////        fatalError("\(self) doesn't implement renderPayload(for: options)")
////    }
//    
//    var renderExtent: RenderExtent { fatalError() }
//    var calculatedRenderExtent: RenderExtent {
//        fatalError("\(self) doesn't implement calculatedRenderExtent")
//    }
//    
//    var userExtent: UserExtent { fatalError() }
//    var calculatedUserExtent: UserExtent {
//        fatalError("\(self) doesn't implement userExtent")
//    }
//    
//   
//    
//    // MARK: Logging
//    
// 
//    
//    // MARK: Optimizing / Graph Rewriting
//    
////    public func checkOptimizations() -> NodeOrOpt {
////        // subclasses must also call this on their inputs
////        return .n(self as! OptimizedNode)
////    }
//    
//    // MARK: Misc
//    
//  
//    
//    func updateGeneratedInput() {
//        
//    }
//    
//    // MARK: Properties (to be overwritten)
//    
//    public var isInvisible: Bool { return false }
//    
//    public var isIdentity: Bool { return false }
//    
////    public func transform(by transform: AffineTransform) {
////        fatalError()
////    }
//    
//    // MARK: Duplication
//    
//    // don't use in OptimizedU
// /*   func copy(in nonsense: Any? = nil) -> Node {
//        let graph = NodeGraph()
//        graph.update(with: self, setRoot: true)
//        return graph.root!
//    }
//    
//    // don't use in OptimizedU
//    func duplicate(in nonsense: Any? = nil)  -> Node {
//        let graph = NodeGraph()
//        graph.update(with: self, setRoot: true)
//        
//        let result = graph.root!
//        result.freshenKeys()
//        return result
//    }*/
//    
//    // don't use in OptimizedU
////    func freshenKeys() {
////        key = NodeKey()
////        for input in inputs {
////            input.freshenKeys()
////        }
////    }
//    
////    var optimizedCopy: OptimizedNode {
////        let context = RenderContext();
////        return context.update(with: self, setRoot: true, optimize: true)
////    }
////    
////    func optimizedCopy<U>(in U: U.Type) -> Node {
////        return optimizedCopy.copy(in: U)
////    }
//    
//    
//    
//    
////    var cachedNodeKeys: [NodeKey] {
////        let cacheNodes = all(as: CacheNode.self)
////        return cacheNodes.map { $0.originalKey }
////    }
////
////    var isCacheNode: Bool {
////        return self is CacheNode
////    }
//    
////    func purgingUnneededCaches() -> ComplicatedNode? {
////        return _purgingUnneededCaches(isBehindCache: false)
////    }
////    
////    func _purgingUnneededCaches(isBehindCache: Bool) -> ComplicatedNode? {
////        fatalError()
////    }
////    
////    var uncacheableNodes: [NodeKey] {
////        if !cacheable { return [key] }
////        return inputs.flatMap { $0.uncacheableNodes }
////    }
////    
////    // temporary, to deal with asynchronicity of AssetManager
////    // not really a good idea to do it this way long term
////    var isWaitingOnAssetManager: Bool {
////        fatalError()
////    }
//    
//}

//extension Node {
//
//    @available(*, deprecated)
//    public func optimize(deep: Bool, shallow: Bool) -> OptimizedNode {
//        return optimize()
//    }
//
//}

//@available(*, deprecated)
//class PayloadNode<PayloadType: NodePayload>: Node {
//
//    final public var payload: PayloadType
//
//    public required init(_ payload: PayloadType, _ key: Key = Key(), _ graph: NodeGraph? = nil) {
//        self.payload = payload
//        super.init(key, graph)
//    }
//
//    final override func payloadAs<T>() -> T? {
//        return payload as? T
//    }
//
//    override var debugDescription: String {
//        return "\(className)(\(payload))"
//    }
//
//    final override func equalPayload(to other: Node) -> Bool {
//        if let other = other as? PayloadNode<PayloadType> {
//            return other.payload == payload
//        } else {
//            return false
//        }
//    }
//
//}
