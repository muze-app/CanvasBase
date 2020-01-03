//
//  CacheNode.swift
//  muze
//
//  Created by Greg Fajen on 5/21/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation
import DAG

extension NodeKey {
    
    var cacheKey: NodeKey {
        return with("cache")
    }
    
}

public struct CachePayload: NodePayload {
    
    let originalKey: NodeKey
    let originalHash: Int
    let optimizedHash: Int
    let cache: CacheAndOptimizer
    
    init(_ key: NodeKey, _ originalHash: Int, _ optimizedHash: Int, _ cache: CacheAndOptimizer) {
        originalKey = key
        self.originalHash = originalHash
        self.optimizedHash = optimizedHash
        self.cache = cache
    }
    
}

public class CacheNode: InputNode<CachePayload> {
    
    var cachingEnabled: Bool { true }
    override public var cost: Int { 1 }
    
    var originalKey: NodeKey { payload.originalKey }
    var cache: CacheAndOptimizer { payload.cache }
    var store: DAGStore<CanvasNodeCollection> { graph.store }

    init(_ graph: MutableCanvasGraph,
         _ optimizer: CacheAndOptimizer,
         original: CanvasNode,
         optimized: CanvasNode) {
        let payload = CachePayload(original.key, original.contentHash, optimized.contentHash, optimizer)
        
        super.init(original.key.cacheKey,
                   graph: graph,
                   payload: payload,
                   nodeType: .cache)
        
        graph.setInput(for: key, index: 0, to: optimized.key)
    }

    init(_ key: NodeKey = NodeKey(), graph: CanvasGraph) {
        super.init(key, graph: graph, payload: nil, nodeType: .cache)
    }

    override public var calculatedRenderExtent: RenderExtent {
        input?.renderExtent ?? .nothing
    }

    override public func renderPayload(for options: RenderOptions) -> RenderPayload? {
        if let payload = cachedPayload { return payload }
        
        guard let payload = input?.renderPayload(for: options) else {
            return nil
        }

        if cachingEnabled,
            let intermediate = payload.intermediate,
            !intermediate.isCache {
            
            intermediate.canAlias = false
            intermediate.isCache = true
            
            let iextent = input!.calculatedRenderExtent
            let pextent = payload.extent
            
            print("iextent: \(iextent)")
            print("pextent: \(pextent)")

            cache.store(payload, for: self, extent: pextent)
        }

        return payload
    }
    
    var cachedPayload: RenderPayload? {
        guard cachingEnabled else { return nil }
        return cache.lookup(self)
    }

    var inputHash: Int {
        guard let input = input else { return Int.max }

        return input.contentHash
    }

//    override var possibleOptimizations: [OptFunc] {
//        return []
//    }

//    override var className: String {
//        return debugDescription
//    }

    override public var debugDescription: String {
        return "CacheNode \(key)"
//        guard input.exists else { return "CacheNode (no input!?!?)" }
//
//        if let payload = cachedPayload {
//            if payload.isPass {
//                return "CacheNode (with unrendered payload)"
//            } else {
//                return "CacheNode (with rendered payload)"
//            }
//        } else {
//            return "CacheNode (no payload)"
//        }
    }

}

public class CacheBlocker: InputNode<One> {
    
    override public var calculatedCacheable: Bool { false }
    
    override public func renderPayload(for options: RenderOptions) -> RenderPayload? {
        return input?.renderPayload(for: options)
    }
    
    override public var calculatedRenderExtent: RenderExtent {
        return input?.renderExtent ?? .nothing
    }
    
    override public var calculatedUserExtent: UserExtent {
        return input?.userExtent ?? .nothing
    }
    
    public init(_ key: NodeKey = NodeKey(), graph: Graph) {
        super.init(key, graph: graph, payload: .one, nodeType: .blocker)
    }
    
}
