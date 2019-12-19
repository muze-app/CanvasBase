//
//  ImportSnapshot.swift
//  muze
//
//  Created by Greg Fajen on 10/3/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation

class ImportSnapshot {
    
    let predecessor: DAG
    let imported: DAGSnapshot
    
    let key = CommitKey()
    
    init(predecessor: DAG, imported: DAG) {
        self.predecessor = predecessor
        self.imported = imported.externalReference
    }
    
}

extension ImportSnapshot: DAG {
    
    var depth: Int {
        return 1 + max(predecessor.depth, imported.depth)
    }
    
    var store: DAGStore? {
        return predecessor.store
    }
    
    func parent(at level: Int) -> DAG? {
        return nil
    }
    
    // we import whatever level into the current level of the predecessor
    var level: Int { return predecessor.level }
    var maxLevel: Int { return predecessor.maxLevel }
    
    var allSubgraphKeys: Set<SubgraphKey> {
        return predecessor.allSubgraphKeys + imported.allSubgraphKeys
    }
    
    func subgraphData(for key: SubgraphKey, level: Int) -> SubgraphData? {
        return predecessor.subgraphData(for: key, level: level)
            ??    imported.subgraphData(for: key, level: imported.level)
    }
    
    func finalKey(for subgraphKey: SubgraphKey) -> NodeKey? {
        return subgraphData(for: subgraphKey, level: level)?.finalKey
    }
    
    func metaKey(for subgraphKey: SubgraphKey) -> NodeKey? {
        return subgraphData(for: subgraphKey, level: level)?.metaKey
    }
    
    func type(for key: NodeKey) -> DNodeType? {
        return predecessor.type(for: key) ?? imported.type(for: key)
    }
    
    func payloadPointer(for key: NodeKey, level: Int) -> UnsafeMutableRawPointer? {
        return predecessor.payloadPointer(for: key, level: level)
            ??    imported.payloadPointer(for: key, level: imported.level)
    }
    
    func payloadAllocation(for key: NodeKey, level: Int) -> PayloadBufferAllocation?  {
        return predecessor.payloadAllocation(for: key, level: level)
            ??    imported.payloadAllocation(for: key, level: imported.level)
    }
    
    func edgeMap(for key: NodeKey, level: Int) -> [Int : NodeKey]? {
        return predecessor.edgeMap(for: key, level: level) ?? imported.edgeMap(for: key, level: imported.level)
    }
    
    func reverseEdges(for key: NodeKey) -> Bag<NodeKey>? {
        return predecessor.reverseEdges(for: key) ?? imported.reverseEdges(for: key)
    }
    
    func revData(for key: NodeKey) -> NodeRevData? {
        return predecessor.revData(for: key) ?? imported.revData(for: key)
    }
    
    func setRevData(_ data: NodeRevData, for key: NodeKey) {
        fatalError()
    }
    
    var modLock: NSRecursiveLock? {
        return predecessor.modLock
    }
    
    var snapshotToModify: DAG {
        return self
    }
    
    func contains(allocations: Set<PayloadBufferAllocation>) -> Bool {
        if predecessor.contains(allocations: allocations) { return true }
        if    imported.contains(allocations: allocations) { return true }
        
        return false
    }
    
//    func contains(textures: Set<MetalTexture>) -> Bool {
//        if predecessor.contains(textures: textures) { return true }
//        if    imported.contains(textures: textures) { return true }
//        
//        return false
//    }
    
}
