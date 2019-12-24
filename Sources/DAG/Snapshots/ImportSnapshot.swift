//
//  ImportSnapshot.swift
//  muze
//
//  Created by Greg Fajen on 10/3/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation
import MuzePrelude

class ImportSnapshot<Collection: NodeCollection>: DAGBase<Collection> {
    
    typealias Graph = DAGBase<Collection>
    
    let predecessor: Graph
    let imported: DAGSnapshot<Collection>
    
    init(predecessor: Graph, imported: Graph) {
        self.predecessor = predecessor
        self.imported = imported.externalReference
        super.init()
    }
    
    override var depth: Int { 1 + max(predecessor.depth, imported.depth) }
    
    override var store: DAGStore<Collection> { predecessor.store }
    
    override func parent(at level: Int) -> Graph? { nil }
    
    // we import whatever level into the current level of the predecessor
    override var level: Int { return predecessor.level }
    override var maxLevel: Int { return predecessor.maxLevel }
    
    override var allSubgraphKeys: Set<SubgraphKey> {
        return predecessor.allSubgraphKeys + imported.allSubgraphKeys
    }
    
    override func subgraphData(for key: SubgraphKey, level: Int) -> SubgraphData? {
        return predecessor.subgraphData(for: key, level: level)
            ??    imported.subgraphData(for: key, level: imported.level)
    }
    
    override func finalKey(for subgraphKey: SubgraphKey) -> NodeKey? {
        return subgraphData(for: subgraphKey, level: level)?.finalKey
    }
    
    override func metaKey(for subgraphKey: SubgraphKey) -> NodeKey? {
        return subgraphData(for: subgraphKey, level: level)?.metaKey
    }
    
   override func type(for key: NodeKey) -> Collection? {
        return predecessor.type(for: key) ?? imported.type(for: key)
    }
    
    override func payloadPointer(for key: NodeKey, level: Int) -> UnsafeMutableRawPointer? {
//        die
        return predecessor.payloadPointer(for: key, level: level)
            ??    imported.payloadPointer(for: key, level: imported.level)
    }
    
    func payloadAllocation(for key: NodeKey, level: Int) -> PayloadBufferAllocation? {
        die
//        return predecessor.payloadAllocation(for: key, level: level)
//            ??    imported.payloadAllocation(for: key, level: imported.level)
    }
    
    override func edgeMap(for key: NodeKey, level: Int) -> [Int : NodeKey]? {
        return predecessor.edgeMap(for: key, level: level) ?? imported.edgeMap(for: key, level: imported.level)
    }
    
    override func reverseEdges(for key: NodeKey) -> Bag<NodeKey>? {
        return predecessor.reverseEdges(for: key) ?? imported.reverseEdges(for: key)
    }
    
    override func revData(for key: NodeKey) -> NodeRevData? {
        return predecessor.revData(for: key) ?? imported.revData(for: key)
    }
    
    func setRevData(_ data: NodeRevData, for key: NodeKey) {
        die
//        fatalError()
    }
    
    var modLock: NSRecursiveLock? {
        die
//        return predecessor.modLock
    }
    
    func contains(allocations: Set<PayloadBufferAllocation>) -> Bool {
        die
//        if predecessor.contains(allocations: allocations) { return true }
//        if    imported.contains(allocations: allocations) { return true }
//
//        return false
    }
    
//    func contains(textures: Set<MetalTexture>) -> Bool {
//        if predecessor.contains(textures: textures) { return true }
//        if    imported.contains(textures: textures) { return true }
//        
//        return false
//    }
    
}
