//
//  CacheAndOptimizer.swift
//  CanvasBase
//
//  Created by Greg Fajen on 12/26/19.
//

import Foundation
import DAG

struct CacheEntry: Hashable {
    let originalKey: NodeKey
    let originalHash: Int
}

public class CacheAndOptimizer {
    
    public typealias Graph = DAGBase<CanvasNodeCollection>
    public typealias Node = GenericNode<CanvasNodeCollection>
    
    public let subgraphKey: SubgraphKey
    
    public init(_ subgraphKey: SubgraphKey) {
        self.subgraphKey = subgraphKey
    }
    
    var entries = [NodeKey:CacheEntry]()
    var cacheDict = ThreadSafeDict<NodeKey,DAGCache>()
    
    // MARK: MARCH
    
    public func march(_ graph: Graph) -> Graph {
        let initial = graph
        var graph = graph
        var map1 = [NodeKey:NodeKey]()

//        print("BEFORE:")
//        graph.subgraph(for: subgraphKey).finalNode?.log()

        var added = Set<NodeKey>()
        graph = insertPreExistingCaches(graph, added: &added)
        graph = optimize(graph, &map1)
        
        let unused = Set(entries.keys).subtracting(added)
        entries = entries.filter { !unused.contains($0.key) }

        let map2 = map1.mapValues { initial.node(for: $0) }
        graph = placeNewCaches(graph, map2, initial)
        pruneOldCaches()

//        print("AFTER:")
//        graph.subgraph(for: subgraphKey).finalNode?.log()
        
//        let e =  graph.subgraph(for: subgraphKey).finalNode?.calculatedRenderExtent ?? .nothing
//        print("extent: \(e)")
        
        return graph
    }
    
    func insertPreExistingCaches(_ graph: Graph, added: inout Set<NodeKey>) -> Graph {
        return graph.addingCacheNodes(to: subgraphKey,
                                      optimizer: self,
                                      for: Array(entries.values),
                                      added: &added)
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
    
    func placeNewCaches(_ graph: Graph, _ map: [NodeKey:CanvasNode], _ og: Graph) -> Graph {
        var addedNodes = Set<CacheEntry>()
        
        let graph = graph.addingNewCacheNodes(to: subgraphKey,
                                              optimizer: self,
                                              map: map,
                                              og: og,
                                              addedNodes: &addedNodes)
        
//        print("NEW CACHE NODES:")
        for n in addedNodes {
//            print("\(n.key)")
            entries[n.originalKey] = n
        }
        
        return graph
    }

    func pruneOldCaches() {
        
    }
    
    // MARK: Load and Store
    
    private func cache(for key: NodeKey) -> DAGCache {
        if let cache = cacheDict[key] { return cache }
        
        let cache = DAGCache(key)
        cacheDict[key] = cache
        return cache
    }
    
    public func store(_ payload: RenderPayload,
                      for cacheNode: CacheNode,
                      extent: RenderExtent) {
//        print("STORE")
//        print("cache node: \(cacheNode.key)")
//        print("original key: \(cacheNode.payload.originalKey)")
//        print("original hash: \(cacheNode.payload.originalHash)")
        store(payload, for: cacheNode.originalKey,
              hash: cacheNode.payload.originalHash, extent: extent)
    }
    
    func store(_ payload: RenderPayload,
               for key: NodeKey,
               hash: Int,
               extent: RenderExtent) {
        
        let cache = self.cache(for: key)
        
        cache.hash = hash
        cache.payload = payload
        cache.extent = extent
        
//        print("stored \(hash) for \(key)")
    }
    
    public func lookup(_ cacheNode: CacheNode) -> RenderPayload? {
//        print("LOOKUP")
//        print("cache node: \(cacheNode.key)")
//        print("original key: \(cacheNode.payload.originalKey)")
//        print("original hash: \(cacheNode.payload.originalHash)")
        let payload = lookup(key: cacheNode.originalKey, hash: cacheNode.payload.originalHash)
        
//        if let pExtent = payload?.extent {
//            let cache = self.cache(for: cacheNode.originalKey)
//            let cExtent = cache.extent
//
////            print("cExtent: \(cExtent)")
////            print("pExtent: \(pExtent)")
////            print(" ")
//        }
        
        return payload
    }
    
    func lookup(key: NodeKey, hash: Int) -> RenderPayload? {
        let cache = self.cache(for: key)
        
//        if !cache.hash.exists { return nil }
        
        if cache.hash == hash {
//            print("found it!")
            return cache.payload
        }

//        print("found hash \(cache.hash), looking for \(hash)")
        return nil
    }
    
    public func finalize() {
        for cache in cacheDict.values {
            cache.finalize()
        }
    }
    
}

extension CacheAndOptimizer: AutoHash {
    
    public static func == (lhs: CacheAndOptimizer, rhs: CacheAndOptimizer) -> Bool {
        lhs === rhs
    }
    
}

class DAGCache {
    
    let key: NodeKey
    
    var hash: Int? /*{
        didSet {
            if let old = oldValue, old != hash {
                print("changed!")
            }
        }
    }*/
    var payload: RenderPayload?
    
    var extent: RenderExtent = .nothing
    
    init(_ key: NodeKey) {
        self.key = key
    }
    
    func finalize() {
        if let p = payload, p.isPass {
            payload = p.withoutPass
        }
    }
    
}
