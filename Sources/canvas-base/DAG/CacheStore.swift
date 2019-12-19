//
//  CacheStore.swift
//  muze
//
//  Created by Greg Fajen on 9/20/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

//import Foundation
//
//class DAGCache {
//
//    let key: NodeKey
//
//    var hash: Int?
//    var payload: RenderPayload?
//
//    init(_ key: NodeKey) {
//        self.key = key
//    }
//
//    func finalize() {
//        if let p = payload, p.isPass {
//            payload = p.withoutPass
//        }
//    }
//
//}
//
//class CacheStore {
//
//    var cacheDict = ThreadSafeDict<NodeKey,DAGCache>()
//
//    private func cache(for key: NodeKey) -> DAGCache {
//        if let cache = cacheDict[key] { return cache }
//
//        let cache = DAGCache(key)
//        cacheDict[key] = cache
//        return cache
//    }
//
//    func lookup(key: NodeKey, hash: Int) -> RenderPayload? {
//        let cache = self.cache(for: key)
//
//        if cache.hash == hash {
//            return cache.payload
//        }
//
//        return nil
//    }
//
//    func store(_ payload: RenderPayload, for key: NodeKey, hash: Int) {
//        let cache = self.cache(for: key)
//
//        cache.hash = hash
//        cache.payload = payload
//    }
//
//    func finalize() {
//        for cache in cacheDict.values {
//            cache.finalize()
//        }
//    }
//
//}
