//
//  ImportSnapshot.swift
//  muze
//
//  Created by Greg Fajen on 10/3/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation
import MuzePrelude

public class ImportSnapshot<Collection: NodeCollection>: DAGBase<Collection> {
    
    typealias Graph = DAGBase<Collection>
    
    let predecessor: Graph
    let imported: DAGSnapshot<Collection>
    
    init(predecessor: Graph, imported: Graph) {
        self.predecessor = predecessor
        self.imported = imported.externalReference
        super.init()
    }
    
    override public var depth: Int { 1 + max(predecessor.depth, imported.depth) }
    
    override public var store: DAGStore<Collection> { predecessor.store }
    
    override public var allSubgraphKeys: Set<SubgraphKey> {
        return predecessor.allSubgraphKeys + imported.allSubgraphKeys
    }
    
    override public func subgraphData(for key: SubgraphKey) -> SubgraphData? {
        return predecessor.subgraphData(for: key)
            ??    imported.subgraphData(for: key)
    }
    
    override public func finalKey(for subgraphKey: SubgraphKey) -> NodeKey? {
        return subgraphData(for: subgraphKey)?.finalKey
    }
    
    override public func metaKey(for subgraphKey: SubgraphKey) -> NodeKey? {
        return subgraphData(for: subgraphKey)?.metaKey
    }
    
    override public func type(for key: NodeKey) -> Collection? {
        return predecessor.type(for: key) ?? imported.type(for: key)
    }
    
    override public func payloadAllocation(for key: NodeKey) -> PayloadBufferAllocation? {
        return predecessor.payloadAllocation(for: key)
            ??    imported.payloadAllocation(for: key)
    }
    
    override public func edgeMap(for key: NodeKey) -> [Int : NodeKey]? {
        return predecessor.edgeMap(for: key) ?? imported.edgeMap(for: key)
    }
    
    override public func reverseEdges(for key: NodeKey) -> Bag<NodeKey>? {
        return predecessor.reverseEdges(for: key) ?? imported.reverseEdges(for: key)
    }
    
    override public func revData(for key: NodeKey) -> NodeRevData? {
        return predecessor.revData(for: key) ?? imported.revData(for: key)
    }
    
//    public func setRevData(_ data: NodeRevData, for key: NodeKey) {
//        die
////        fatalError()
//    }
    
    
    override public func contains(allocations: Set<PayloadBufferAllocation>) -> Bool {
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
