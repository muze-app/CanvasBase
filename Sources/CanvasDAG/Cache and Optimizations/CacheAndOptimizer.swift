//
//  CacheAndOptimizer.swift
//  CanvasBase
//
//  Created by Greg Fajen on 12/26/19.
//

import Foundation
import DAG

struct CacheEntry: Hashable {
    let key: NodeKey
    let contentHash: Int
//    let
}

public class CacheAndOptimizer {
    
    public typealias Graph = DAGBase<CanvasNodeCollection>
    public typealias Node = GenericNode<CanvasNodeCollection>
    
    public let subgraphKey: SubgraphKey
    
    public init(_ subgraphKey: SubgraphKey) {
        self.subgraphKey = subgraphKey
    }
    
    var entries = [NodeKey:CacheEntry]()
    
    public func march(_ graph: Graph) -> Graph {
        let initial = graph
        var graph = graph
        var map1 = [NodeKey:NodeKey]()
        
        print("BEFORE:")
        graph.subgraph(for: subgraphKey).finalNode?.log()
        
        graph = insertPreExistingCaches(graph)
        graph = optimize(graph, &map1)
        
        let map2 = map1.mapValues { initial.node(for: $0) }
        graph = placeNewCaches(graph, map2)
        pruneOldCaches()
        
        print("AFTER:")
        graph.subgraph(for: subgraphKey).finalNode?.log()
        
        return graph
    }
    
    func insertPreExistingCaches(_ graph: Graph) -> Graph {
        return graph.addingCacheNodes(to: subgraphKey,
                                      optimizer: self,
                                      for: Array(entries.values))
    }
    
    func optimize(_ graph: Graph, _ map: inout [NodeKey:NodeKey]) -> Graph {
        let graph = graph.optimizing(subgraph: subgraphKey,
                                     throughCacheNodes: false,
                                     map: &map)
        
//        print("MAP:")
//        for (k, v) in map {
//            print("\(k) <- \(v)")
//        }
        
        return graph
    }
    
    func placeNewCaches(_ graph: Graph, _ map: [NodeKey:CanvasNode]) -> Graph {
        var addedNodes = Set<CacheEntry>()
        
        let graph = graph.addingNewCacheNodes(to: subgraphKey,
                                              optimizer: self,
                                              map: map,
                                              addedNodes: &addedNodes)
        
//        print("NEW CACHE NODES:")
        for n in addedNodes {
//            print("\(n.key)")
            entries[n.key] = n
        }
        
        return graph
    }

    func pruneOldCaches() {
        
    }
    
}
