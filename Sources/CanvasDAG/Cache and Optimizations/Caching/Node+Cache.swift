//
//  Node+Cache.swift
//  CanvasBase
//
//  Created by Greg Fajen on 12/26/19.
//

import Foundation
import DAG

extension CanvasGraph {
    
    func addingNewCacheNodes(to subgraph: SubgraphKey,
                             optimizer: CacheAndOptimizer,
                             map: [NodeKey:CanvasNode],
                             og: CanvasGraph,
                             addedNodes: inout Set<CacheEntry>) -> CanvasGraph {
        modify {
            let subgraph = $0.subgraph(for: subgraph)
            subgraph.finalNode = subgraph.finalNode?.addingNewCacheNodes(to: $0,
                                                                         optimizer: optimizer,
                                                                         map: map,
                                                                         og: og,
                                                                         addedNodes: &addedNodes)
        }
    }
    
    func addingCacheNodes(to subgraph: SubgraphKey,
                          optimizer: CacheAndOptimizer,
                          for entries: [CacheEntry],
                          added: inout Set<NodeKey>) -> CanvasGraph {
        modify { graph in
            for entry in entries {
//                print("ENTRY: \(entry)")
                guard graph.type(for: entry.originalKey).exists else { continue }
                let original = graph.node(for: entry.originalKey)
                let cache: CacheNode = CacheNode(graph,
                                                 optimizer,
                                                 original: original,
                                                 optimized: original)
                
//                if original.contentHash != entry.originalHash {
//                    print("not a match?")
//                    original.log()
//                    print("")
//                }
                
                graph.replace(original.key, with: cache, onlyExcluded: true)
                added.insert(entry.originalKey)
                
//                guard let revEdges = graph.reverseEdges(for: original.key) else { continue }
//
////                print("rev edges: \(revEdges)")
//
//                for x in revEdges.asSet where x != cache.key {
//                    guard graph.type(for: x).exists else { continue }
//                    let node = graph.node(for: x)
//
//                    for (i, target) in node.edgeMap where target == original.key {
//                        node.nodeInputs[i] = cache
//                    }
//                }
            }
        }
    }
    
}

extension CanvasNode {
    
//    func addingCacheNodes(for entries: [CacheEntry],
//                          to graph: MutableGraph) -> CanvasNode {
//
//    }
    
    func addingNewCacheNodes(to graph: MutableGraph,
                             optimizer: CacheAndOptimizer,
                             map: [NodeKey:CanvasNode],
                             og: Graph,
                             addedNodes: inout Set<CacheEntry>) -> CanvasNode {
        if self is CacheNode { return self }
        if cost < 2 { return self }
        
        if !cacheable {
            for (i, k) in edgeMap {
                let node = graph.node(for: k)
                let cached = node.addingNewCacheNodes(to: graph,
                                                      optimizer: optimizer,
                                                      map: map,
                                                      og: og,
                                                      addedNodes: &addedNodes)
                nodeInputs[i] = cached
            }
            return self
        }
        
        let original = map[key] ?? og.node(for: key)
        
        let cacheNode = CacheNode(graph,
                                  optimizer,
                                  original: original,
                                  optimized: self)
        
        let entry = CacheEntry(originalKey: original.key, originalHash: original.contentHash)
        addedNodes.insert(entry)
        
        return cacheNode
    }
    
}
