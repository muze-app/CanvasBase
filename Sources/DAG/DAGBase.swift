//
//  DAG.swift
//  muze
//
//  Created by Greg Fajen on 9/2/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation
import MuzePrelude

public class DAGBase<Collection: NodeCollection> {
    
    public typealias Node = GenericNode<Collection>
    public typealias Snapshot = InternalDirectSnapshot<Collection>
    
    public final let key: CommitKey
    
    public var store: DAGStore<Collection> { die }
    public var depth: Int { die }
    var level: Int { die }
    var maxLevel: Int { die }
    
    init(_ key: CommitKey = .init()) {
        self.key = key
    }
    
    func parent(at level: Int) -> DAGBase? { die }
    
    // MARK: - Subgraphs
    
    public var allSubgraphKeys: Set<SubgraphKey> { die }

    public final func subgraph(for key: SubgraphKey) -> Subgraph<Collection> {
        return Subgraph(key: key, graph: self)
    }
    
    public func subgraphData(for key: SubgraphKey) -> SubgraphData? {
        subgraphData(for: key, level: level)
    }
    
    public func subgraphData(for key: SubgraphKey, level: Int) -> SubgraphData? {
        die
    }
    
    public final var allSubgraphs: [Subgraph<Collection>] {
        allSubgraphKeys.map { subgraph(for: $0) }
    }
    
    // MARK: - Nodes
    
    //    func node(for key: NodeKey) -> Node { }
    func type(for key: NodeKey) -> Collection? { die }
    
    // PRECONDITION: node must exist in graph or will crash
    func node(for key: NodeKey) -> Node {
        guard let type = type(for: key) else { die }
        
        return type.node(for: key, graph: self)
    }
    
    public func finalKey(for subgraph: SubgraphKey) -> NodeKey? { die }
    
    public final func finalNode(for subgraph: SubgraphKey) -> Node? {
        guard let key = finalKey(for: subgraph) else { return nil }
        return node(for: key)
    }
    
    public func metaKey(for subgraph: SubgraphKey) -> NodeKey? { die }
    
    public final func metaNode(for subgraph: SubgraphKey) -> Node? {
        guard let key = metaKey(for: subgraph) else { return nil }
        return node(for: key)
    }
    
    // MARK: - Payloads

//    func payloadAllocation(for key: NodeKey, level: Int) -> PayloadBufferAllocation? { }
    public func payloadPointer(for key: NodeKey, level: Int) -> UnsafeMutableRawPointer? { die }
    public func payload<T>(for key: NodeKey, of type: T.Type) -> T? { die }

    var die: Never { fatalError() }
    
    // MARK: - Edges
    
    public func edgeMap(for key: NodeKey, level: Int) -> [Int: NodeKey]? { die }
    
    public final func input(for parent: NodeKey, index: Int) -> NodeKey? {
        return edgeMap(for: parent, level: level)?[index]
    }
    
    public final func inputNode(for parent: NodeKey, index: Int) -> Node? {
        guard let key = input(for: parent, index: index) else { return nil }
        return node(for: key)
    }
    
    func reverseEdges(for key: NodeKey) -> Bag<NodeKey>? { die }
    func revData(for key: NodeKey) -> NodeRevData? { die }
//    func setRevData(_ data: NodeRevData, for key: NodeKey) { die }

    // MARK: Modification
    
    var snapshotToModify: DAGBase { self }
    
//    @inlinable
    public final func modify(_ block: (MutableDAG<Collection>)->()) -> Snapshot {
        return modify(as: nil, level: level, block)
    }
    
    @inlinable
    public final func modify(level: Int, _ block: (MutableDAG<Collection>)->()) -> Snapshot {
        return modify(as: nil, level: level, block)
    }
    
//    @inlinable
    public final func modify(as key: CommitKey?, level: Int, _ block: (MutableDAG<Collection>)->()) -> Snapshot {
        let snapshot = snapshotToModify
        
        //        modLock?.lock()
        let pred: DAGBase = snapshot
        let result = InternalDirectSnapshot(predecessor: pred, store: store, level: level, key: key ?? CommitKey())
        block(result)
        //        modLock?.unlock()
        
        if self.level == level, !key.exists, !result.hasChanges, let me = snapshot as? InternalDirectSnapshot {
            return me
        } else {
            result.becomeImmutable()
            return result
        }
        
    }
    
    // MARK: - UNSORTED
    
//    var modLock: NSRecursiveLock? { die }
//    func  alias(_ block: (MutableDAG)->()) -> InternalDirectSnapshot { die } // use carefully!
//    func modify(_ block: (MutableDAG)->()) -> InternalDirectSnapshot { die }
//    func modify(level: Int, _ block: (MutableDAG)->()) -> InternalDirectSnapshot { die }
//    func modify(as key: CommitKey?, level: Int, _ block: (MutableDAG)->()) -> InternalDirectSnapshot { die }
//    func importing(_ other: DAG) -> ImportSnapshot { die }
//
//
//    func contains(allocations: Set<PayloadBufferAllocation>) -> Bool { die }
//    func contains(textures: Set<MetalTexture>) -> Bool
    
//}

//protocol MutableDAG: DAG {
//
//    func setType(_ type: DNodeType, for key: NodeKey)
//    func setPayload<T: NodePayload>(_ payload: T, for key: NodeKey)
//    func setEdgeMap(_ edgeMap: [Int:NodeKey], for key: NodeKey)
//    func setInput(for parent: NodeKey, index: Int, to child: NodeKey?)
//
//    func setFinalKey(_ key: NodeKey?, for subgraph: SubgraphKey)
//    func setFinalNode(_ node: Node?, for subgraph: SubgraphKey)
//    func setMetaKey(_ key: NodeKey?, for subgraph: SubgraphKey)
//    func setMetaNode(_ node: Node?, for subgraph: SubgraphKey)
//
//    func setReverseEdges(_ bag: Bag<NodeKey>, for key: NodeKey)
//
//}
    
//    func payload<T>(for key: NodeKey, of type: T.Type) -> T? {
//        guard let raw = payloadPointer(for: key, level: level) else { return nil }
//        let pointer = raw.assumingMemoryBound(to: T.self)
//        return pointer.pointee
//    }
     
    func  alias(_ block: (MutableDAG<Collection>)->()) -> Snapshot {
        return modify(as: self.key, level: level, block)
    }
    
    func optimizing(subgraph: SubgraphKey, throughCacheNodes: Bool = false) -> Snapshot {
        return modify { _ in
//            let subgraph = graph.subgraph(for: subgraph)
//            subgraph.finalNode = subgraph.finalNode?.optimize(throughCacheNodes: throughCacheNodes)
        }
        
//        return self as! InternalDirectSnapshot
        
//        let optimized = modify { (graph) in
//            graph.finalNode = graph.finalNode?.optimize(throughCacheNodes: throughCacheNodes)
//        }
        
//        for (parent, edgeMap) in optimized.edgeMaps {
//            print("PARENT: \(parent)")
//            for (i, child) in edgeMap {
//                print("    \(i) = \(child)")
//            }
//        }
        
//        print("ORIGINAL")
//        finalNode?.log()
//        print("OPTIMIZED")
//        optimized.finalNode?.log()

//        return optimized.flattened
    }
    
    func reference(for mode: DAGSnapshot<Collection>.Mode) -> DAGSnapshot<Collection> {
        die
//        let store = self.store!
//        if let self = self as? InternalDirectSnapshot {
//            if !store.commit(for: key).exists { store.commit(self) }
//        } else {
//            assert( store.commit(for: key).exists )
//        }
//
//        return DAGSnapshot(store: store, key: key, mode)
    }
    
    var internalReference: DAGSnapshot<Collection> {
        return reference(for: .internalReference)
    }
    
    var externalReference: DAGSnapshot<Collection> {
        return reference(for: .externalReference)
    }
    
    var isCommitted: Bool {
        return (store.commit(for: key)).exists
    }
    
    func importing(_ other: DAGBase) -> ImportSnapshot<Collection> {
        return ImportSnapshot(predecessor: self, imported: other)
    }
    
}
