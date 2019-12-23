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


//final class CacheNode: INode<NodeKey> {
//
////    var cachedPayload: RenderPayload? = nil
////    var cachedHash: Int = 0
//
//    var store: DAGStore {
//        let graph = dag!
//        let store = graph.store!
//        return store
//    }
//    var cacheStore: CacheStore { return store.cacheStore }
//
//    var originalKey: NodeKey {
//        get { return payload }
//        set { payload = newValue }
//    }
//
//    init(node: DNode) {
//        super.init(node.key.cacheKey, graph: node.dag!, payload: node.key, nodeType: .cache)
//    }
//
//    init(_ key: NodeKey = NodeKey(), graph: DAG) {
//        super.init(key, graph: graph, payload: nil, nodeType: .cache)
//    }
//
//    override var calculatedRenderExtent: RenderExtent {
//        return input?.renderExtent ?? .nothing
//    }
//
//    var cachingEnabled: Bool { return true }
//
//    override func renderPayload(for options: RenderOptions) -> RenderPayload? {
//        guard let input = input else { return nil }
//        if cachingEnabled, let payload = cacheStore.lookup(key: key, hash: input.contentHash) {
//            return payload
//        }
//
//        let payload = input.renderPayload(for: options)
//
//        if let intermediate = payload?.intermediate, !intermediate.isCache {
//            intermediate.canAlias = false
//            intermediate.isCache = true
//
//            cacheStore.store(payload!, for: key, hash: inputHash)
//        }
//
//        return payload
//    }
//
//    @available(*, deprecated)
//    func finalize() {
//        cacheStore.finalize()
//    }
//
//    var inputHash: Int {
//        guard let input = input else { return Int.max }
//
//        return input.contentHash
//    }
//
//    override var possibleOptimizations: [OptFunc] {
//        return []
//    }
//
//    override var className: String {
//        return debugDescription
//    }
//
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
//
////    override var cost: Int {
////        return 1
////    }
//
//}
