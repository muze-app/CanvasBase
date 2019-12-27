//
//  GeneratorNode.swift
//  muze
//
//  Created by Greg Fajen on 5/17/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation

//@available(*, deprecated)
//class GeneratorNode<PayloadType: NodePayload>: PayloadNode<PayloadType> {
//
//    final override var inputs: [InputType] { return [] }
//
//    final override func hash(into hasher: inout Hasher, includeKeys: Bool) {
//        hasher.combine(nodeType)
//
//        if includeKeys {
//            hasher.combine(key)
//        }
//
//        hasher.combine(payload)
//    }
//
//    final override func optimizeInputs(throughCacheNodes: Bool) {
//
//    }
//
//    final override func update(from node: Node) {
////         if equal(to: node, ignoringKey: false, ignoringOptimizations: true) { return }
//        // that check is probably slower than just updating everything
////
////        let node = node as! GeneratorNode<PayloadType>
////        payload = node.payload
////
////        resetRenderExtent()
//    }
//
//    final override func replace(_ keyToReplace: NodeKey, with replacement: Node) {
//
//    }
//
////    final override public func transform(by transform: AffineTransform) {
////        payload = payload.transformed(by: transform)
////    }
//
//    final override func _purgingUnneededCaches(isBehindCache: Bool) -> Node? {
//        return self
//    }
//
//}
