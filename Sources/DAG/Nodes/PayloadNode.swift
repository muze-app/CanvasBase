//
//  File.swift
//  
//
//  Created by Greg Fajen on 12/19/19.
//

import Foundation
import MuzePrelude

// MARK: Payload Node

public typealias AffineTransform = MuzePrelude.AffineTransform

public protocol NodePayload: Hashable {
    
//    func transformed(by transform: AffineTransform) -> Self
    
}

//extension NodePayload {
//    
//    public func transformed(by transform: AffineTransform) -> Self {
//        return self
//    }
//    
//}

open class PayloadNode<Collection: NodeCollection, PayloadType: NodePayload>: GenericNode<Collection> {
    
    public var payload: PayloadType {
        get { graph.payload(for: key, of: PayloadType.self)! }
        set { (graph as! MutableDAG).setPayload(newValue, for: key) }
    }
    
    public init(_ key: NodeKey = NodeKey(), graph: Graph, payload: PayloadType? = nil, nodeType: Collection? = nil) {
        if !graph.type(for: key).exists, let graph = graph as? MutableDAG {
            guard let payload = payload else { fatalError("Must provide initial payload when inserting node into graph") }
            guard let nodeType = nodeType else { fatalError("Must provide node type when inserting node into graph") }
            graph.setType(nodeType, for: key)
            graph.setPayload(payload, for: key)
            graph.setEdgeMap([:], for: key)
            graph.setReverseEdges(.init(), for: key)
        }
        
        super.init(key, graph: graph)
        
        assert(graph.payload(for: key, of: PayloadType.self).exists)
    }
    
    override open var debugDescription: String {
        return String("\(Swift.type(of: self)) (\(key)) = \(payload)")
    }
    
    override final func equalPayload(to other: Node) -> Bool {
        if let other = other as? PayloadNode<Collection, PayloadType> {
            return other.payload == payload
        } else {
            return false
        }
    }
    
    //    override var inputCount: Int { return edgeMap.count }
    
    // better differentiate between this and inputs var
     
    //    final override func addingCacheNodes(_ keysToCache: [NodeKey]) -> DNode? {
    //        if let cacheNode = self as? CacheNode {
    //            return cacheNode.input?.addingCacheNodes(keysToCache + [key])
    //        }
    //
    //        for i in edgeMap.keys {
    //            self[i] = self[i]?.addingCacheNodes(keysToCache)
    //        }
    //
    //        guard keysToCache.contains(key) else { return self }
    //
    //        let cacheNode = CacheNode(node: self)
    //        cacheNode.input = self
    //
    //        return cacheNode
    //    }
    
    @discardableResult
    override public func add(to graph: MutableGraph, useFreshKeys: Bool) -> NodeKey {
        let newKey = super.add(to: graph, useFreshKeys: useFreshKeys)
        graph.setPayload(payload, for: newKey)
        return newKey
    }
    
    override public func add(diffTo graph: MutableGraph, parent: Graph) {
        super.add(diffTo: graph, parent: parent)
        
        let source = self.graph
        if let sourcePayload = source.payload(for: key, of: PayloadType.self),
            parent.payload(for: key, of: PayloadType.self) != sourcePayload {
            graph.setPayload(sourcePayload, for: key)
        }
    }
    
    public subscript(i: Int) -> Node? {
        get {
            guard let inputKey = graph.input(for: key, index: i) else { return nil }
            return graph.node(for: inputKey)
        }
        
        set { (graph as! MutableDAG).setInput(for: key, index: i, to: newValue?.key) }
    }
    
    /*
    final override var renderExtent: RenderExtent {
        return calculatedRenderExtent
        //        var data = dag.revData(for: key) ?? NodeRevData()
        //        if let e = data.renderExtent { return e }
        //
        //        data.renderExtent = calculatedRenderExtent
        //        dag.setRevData(data, for: key)
        //
        //        return data.renderExtent!
    }
    
    final override var userExtent: UserExtent {
        return calculatedUserExtent
        //        var data = dag.revData(for: key) ?? NodeRevData()
        //        if let e = data.userExtent { return e }
        //
        //        data.userExtent = calculatedUserExtent
        //        dag.setRevData(data, for: key)
        //
        //        return data.userExtent!
    }*/
    
    override open var contentHash: Int {
        return calculatedContentHash
        //        var data = dag.revData(for: key) ?? NodeRevData()
        //        if let h = data.hash { return h }
        //
        //        data.hash = calculatedContentHash
        //        dag.setRevData(data, for: key)
        //
        //        return data.hash!
    }
    
    var calculatedContentHash: Int {
        var hasher = Hasher()
        hash(into: &hasher, includeKeys: false)
        return hasher.finalize()
    }
    
    override public final func hash(into hasher: inout Hasher, includeKeys: Bool) {
        if includeKeys {
            hasher.combine(key)
        }
        
        hasher.combine(payload)
        
        for (i, key) in sortedEdges {
            hasher.combine(i)
            let node = graph.node(for: key)
            hasher.combine(node.contentHash)
        }
    }
    
}
