//
//  Snapshot.swift
//  muze
//
//  Created by Greg Fajen on 9/2/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation

typealias SnapshotKey = CommitKey

class DAGSnapshot: DAG {
    
    
    enum Mode { case internalReference, externalReference }
    let mode: Mode
    
    var _store: DAGStore
    override var store: DAGStore { _store }
    
    init(store: DAGStore, key: SnapshotKey, _ mode: Mode) {
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
    
    var internalSnapshot: InternalDirectSnapshot {
        if let commit = store.commit(for: key) {
            return commit
        } else {
            print("WTF")
            fatalError()
        }
    }
    
    var snapshotToModify: DAG { return internalSnapshot }
    
    override var depth: Int {
        return internalSnapshot.depth
    }
    
    override func type(for key: NodeKey) -> DNodeType? {
        return internalSnapshot.type(for: key)
    }
    
    override var level: Int {
        return internalSnapshot.level
    }
    
    override var maxLevel: Int {
        return internalSnapshot.maxLevel
    }
    
    override func parent(at level: Int) -> DAG? {
        return internalSnapshot.parent(at: level)
    }
    
    override var allSubgraphKeys: Set<SubgraphKey> {
        return internalSnapshot.allSubgraphKeys
    }
    
    func subgraphData(for key: SubgraphKey, level: Int) -> SubgraphData? {
        die
//        return internalSnapshot.subgraphData(for: key, level: level)
    }
    
    override func finalKey(for subgraph: SubgraphKey) -> NodeKey? {
        return internalSnapshot.finalKey(for: subgraph)
    }
    
    override func metaKey(for subgraph: SubgraphKey) -> NodeKey? {
        return internalSnapshot.metaKey(for: subgraph)
    }
    
    var modLock: NSRecursiveLock? {
        return store.lock
    }
    
    func payloadAllocation(for key: NodeKey, level: Int) -> PayloadBufferAllocation? {
        return internalSnapshot.payloadAllocation(for: key, level: level)
    }
    
    func payloadPointer(for key: NodeKey, level: Int) -> UnsafeMutableRawPointer? {
        return internalSnapshot.payloadPointer(for: key, level: level)
    }
    
    override func edgeMap(for key: NodeKey, level: Int) -> [Int : NodeKey]? {
        return internalSnapshot.edgeMap(for: key, level: level)
    }
    
    override func reverseEdges(for key: NodeKey) -> Bag<NodeKey>? {
        return internalSnapshot.reverseEdges(for: key)
    }
    
    func revData(for key: NodeKey) -> NodeRevData? {
        return internalSnapshot.revData(for: key)
    }
    
    func setRevData(_ data: NodeRevData, for key: NodeKey) {
        internalSnapshot.setRevData(data, for: key)
    }
    
    func contains(allocations: Set<PayloadBufferAllocation>) -> Bool {
        return internalSnapshot.contains(allocations: allocations)
    }
    
//    func contains(textures: Set<MetalTexture>) -> Bool {
//        return internalSnapshot.contains(textures: textures)
//    }
    
}
