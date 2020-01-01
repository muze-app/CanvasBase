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
    
    init(_ key: CommitKey = .init()) {
        self.key = key
    }
    
    var payloadBuffers: PayloadBufferSet? { nil }
    
    public func preconditionNotForbidden(_ key: NodeKey) {
        if forbiddenKeys.contains(key) {
            fatalError()
        }
    }
    
    func preconditionReading() {
        store.preconditionReading()
    }
    
    func preconditionWriting() {
        store.preconditionWriting()
    }
    
    // MARK: - Subgraphs
    
    public var allSubgraphKeys: Set<SubgraphKey> { die }

    public final func subgraph(for key: SubgraphKey) -> Subgraph<Collection> {
        return Subgraph(key: key, graph: self)
    }
    
    public func subgraphData(for key: SubgraphKey) -> SubgraphData? {
        die
    }
    
    public final var allSubgraphs: [Subgraph<Collection>] {
        allSubgraphKeys.map { subgraph(for: $0) }
    }
    
    public final var importantSubgraphs: [Subgraph<Collection>] {
        allSubgraphKeys.filter { !excludedSubgraphKeys.contains($0) } .map { subgraph(for: $0) }
    }
    
    public final var excludedSubgraphKeys: Set<SubgraphKey> {
        store.excludedSubgraphKeys
    }
    
    // MARK: - Nodes
    
    public var forbiddenKeys: Set<NodeKey> { die }
    
    //    func node(for key: NodeKey) -> Node { }
    public func type(for key: NodeKey) -> Collection? { die }
    
    // PRECONDITION: node must exist in graph or will crash
    public func node(for key: NodeKey) -> Node {
        preconditionReading()
        
        guard let type = type(for: key) else {
            print("missing node for \(key)")
            die
        }
        
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

    public func payloadAllocation(for key: NodeKey) -> PayloadBufferAllocation? {
        die
    }
    
    public final func payloadPointer(for key: NodeKey) -> UnsafeMutableRawPointer? {
        payloadAllocation(for: key)?.pointer
    }
    
    public final func payload<T>(for key: NodeKey, of type: T.Type) -> T? {
        preconditionNotForbidden(key)
        return payloadPointer(for: key)?.assumingMemoryBound(to: T.self).pointee
    }

    var die: Never { fatalError() }
    
    // MARK: - Edges
    
    public func edgeMap(for key: NodeKey) -> [Int: NodeKey]? { die }
    
    public final func input(for parent: NodeKey, index: Int) -> NodeKey? {
        return edgeMap(for: parent)?[index]
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
//    public final func modify(_ block: (MutableDAG<Collection>)->()) -> Snapshot {
//        return modify(as: nil, block)
//    }
    
    @inlinable
    public final func modify(_ block: (MutableDAG<Collection>)->()) -> Snapshot {
        return modify(as: nil, block)
    }
    
//    @inlinable
    public final func modify(as key: CommitKey?,
                             _ block: (MutableDAG<Collection>)->()) -> Snapshot {
        store.write {
            let snapshot = snapshotToModify
            
            let result = InternalDirectSnapshot(predecessor: snapshot,
                                                store: store,
                                                key: key ?? CommitKey())
            block(result)
            
            if !key.exists, !result.hasChanges, let me = snapshot as? InternalDirectSnapshot {
                return me
            } else {
                result.becomeImmutable()
                return result
            }
        }
    }
    
    // MARK: - UNSORTED
    
    public func alias(_ block: (MutableDAG<Collection>)->()) -> Snapshot {
        return modify(as: self.key, block)
    }
    
    func reference(for mode: DAGSnapshot<Collection>.Mode) -> DAGSnapshot<Collection> {
        if let self = self as? InternalDirectSnapshot {
            if !store.commit(for: key).exists { store.commit(self) }
        } else {
            assert( store.commit(for: key).exists )
        }

        return DAGSnapshot(store: store, key: key, mode)
    }
    
    public var internalReference: DAGSnapshot<Collection> {
        reference(for: .internalReference)
    }
    
    public var externalReference: DAGSnapshot<Collection> {
        reference(for: .externalReference)
    }
    
    public var isCommitted: Bool {
        (store.commit(for: key)).exists
    }
    
    public func importing(_ other: DAGBase) -> ImportSnapshot<Collection> {
        ImportSnapshot(predecessor: self, imported: other)
    }
    
    public func contains(allocations: Set<PayloadBufferAllocation>) -> Bool { die }
    
}

public extension DAGBase {
    
    var pointerString: String {
        let unsafe = Unmanaged.passUnretained(self).toOpaque()
        return "\(unsafe)"
    }
    
    func verify() {
        let allNodes = self.allNodes
        for key in allNodes where !type(for: key).exists {
            print("MISSING KEY: \(key)")
            fatalError()
        }
    }
    
    var allNodes: Set<NodeKey> {
        Set( allSubgraphs.flatMap { $0.finalNode?.allKeys ?? Set() } )
    }
    
}
