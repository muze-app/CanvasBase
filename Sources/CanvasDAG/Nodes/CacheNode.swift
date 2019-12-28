//
//  CacheNode.swift
//  muze
//
//  Created by Greg Fajen on 5/21/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation
import DAG

extension NodeKey: NodePayload {
    
    var cacheKey: NodeKey {
        return with("cache")
    }
    
}

public class CacheNode: InputNode<NodeKey> {

//    var cachedPayload: RenderPayload? = nil
//    var cachedHash: Int = 0

    override public var cost: Int { 1 }
    
    var store: DAGStore<CanvasNodeCollection> {
        return graph.store
    }
    
//    var cacheStore: CacheStore { return store.cacheStore }
    
    weak var cacheStore: CacheAndOptimizer?

    var originalKey: NodeKey {
        get { return payload }
        set { payload = newValue }
    }
    
    init(_ graph: MutableCanvasGraph,
         _ optimizer: CacheAndOptimizer,
         original: CanvasNode,
         optimized: CanvasNode) {
        self.cacheStore = optimizer
        
        super.init(original.key.cacheKey,
                   graph: graph,
                   payload: original.key,
                   nodeType: .cache)
        
        graph.setInput(for: key, index: 0, to: optimized.key)
    }

//    init(node: CanvasNode) {
//        super.init(node.key.cacheKey,
//                   graph: node.graph,
//                   payload: node.key,
//                   nodeType: .cache)
//    }

    init(_ key: NodeKey = NodeKey(), graph: CanvasGraph) {
        super.init(key, graph: graph, payload: nil, nodeType: .cache)
    }

    override public var calculatedRenderExtent: RenderExtent {
        input?.renderExtent ?? .nothing
    }

    var cachingEnabled: Bool { return true }

    override public func renderPayload(for options: RenderOptions) -> RenderPayload? {
        guard let input = input else { return nil }
//        if cachingEnabled, let payload = cacheStore.lookup(key: key, hash: input.contentHash) {
//            return payload
//        }

        let payload = input.renderPayload(for: options)

//        if let intermediate = payload?.intermediate, !intermediate.isCache {
//            intermediate.canAlias = false
//            intermediate.isCache = true
//
//            cacheStore.store(payload!, for: key, hash: inputHash)
//        }

        return payload
    }

//    @available(*, deprecated)
//    func finalize() {
//        cacheStore.finalize()
//    }

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

//    override var debugDescription: String {
//        guard let input = input else { return "CacheNode (no input!?!?)" }
//
//        if let cachePayload = cacheStore.lookup(key: key, hash: input.contentHash) {
//            if cachePayload.isPass {
//                return "CacheNode (with unrendered payload)"
//            } else {
//                return "CacheNode (with rendered payload)"
//            }
//
//        } else {
//            return "CacheNode (no payload)"
//        }
//    }


}
