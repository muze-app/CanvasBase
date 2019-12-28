//
//  Snapshot.swift
//  muze
//
//  Created by Greg Fajen on 9/2/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation
import MuzePrelude

typealias SnapshotKey = CommitKey

public class DAGSnapshot<Collection: NodeCollection>: DAGBase<Collection> {
    
    enum Mode { case internalReference, externalReference }
    let mode: Mode
    
    var _store: DAGStore<Collection>
    override public var store: DAGStore<Collection> { _store }
    
    init(store: DAGStore<Collection>, key: SnapshotKey, _ mode: Mode) {
        self.mode = mode
        self._store = store
        
        super.init(key)

        store.retain(commitFor: key, mode: mode)
        assert(isCommitted)
    }
    
    deinit {
//        let key = self.key
//        let mode = self.mode
//        if let store = store {
//            DispatchQueue.global().async {
                store.release(commitFor: key, mode: mode)
//            }
//        }
    }
    
    public var internalSnapshot: InternalDirectSnapshot<Collection> {
        if let commit = store.commit(for: key) {
            return commit
        } else {
            print("WTF")
            fatalError()
        }
    }
    
    override var snapshotToModify: DAGBase<Collection> { return internalSnapshot }
    
    override public var depth: Int {
        internalSnapshot.depth
    }
    
    override public func type(for key: NodeKey) -> Collection? {
        internalSnapshot.type(for: key)
    }
    
    override public var allSubgraphKeys: Set<SubgraphKey> {
        internalSnapshot.allSubgraphKeys
    }
    
    override public func subgraphData(for key: SubgraphKey) -> SubgraphData? {
        internalSnapshot.subgraphData(for: key)
    }
    
    override public func finalKey(for subgraph: SubgraphKey) -> NodeKey? {
        internalSnapshot.finalKey(for: subgraph)
    }
    
    override public func metaKey(for subgraph: SubgraphKey) -> NodeKey? {
        internalSnapshot.metaKey(for: subgraph)
    }
    
    var modLock: NSRecursiveLock? {
        store.lock
    }
    
    override public func payloadAllocation(for key: NodeKey) -> PayloadBufferAllocation? {
        internalSnapshot.payloadAllocation(for: key)
    }
    
    override public func edgeMap(for key: NodeKey) -> [Int : NodeKey]? {
        internalSnapshot.edgeMap(for: key)
    }
    
    override func reverseEdges(for key: NodeKey) -> Bag<NodeKey>? {
        internalSnapshot.reverseEdges(for: key)
    }
    
    override func revData(for key: NodeKey) -> NodeRevData? {
        internalSnapshot.revData(for: key)
    }
    
    func setRevData(_ data: NodeRevData, for key: NodeKey) {
        internalSnapshot.setRevData(data, for: key)
    }
    
    func contains(allocations: Set<PayloadBufferAllocation>) -> Bool {
        internalSnapshot.contains(allocations: allocations)
    }
    
//    func contains(textures: Set<MetalTexture>) -> Bool {
//        return internalSnapshot.contains(textures: textures)
//    }
    
}
