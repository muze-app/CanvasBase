//
//  AlphaNode.swift
//  muze
//
//  Created by Greg Fajen on 5/17/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation

//final class AlphaNode: INode<Float> {
//    
//    init(_ key: NodeKey = NodeKey(), graph: DAG, payload: Float? = nil) {
//        super.init(key, graph: graph, payload: payload, nodeType: .alpha)
//    }
//    
//    var alpha: Float {
//        get { return payload }
//        set { payload = newValue }
//    }
//    
//    override public func renderPayload(for options: RenderOptions) -> RenderPayload? {
//        guard alpha > 0, let payload = input?.renderPayload(for: options) else { return nil }
//        return .alpha(payload, alpha)
//    }
//    
//    override var calculatedRenderExtent: RenderExtent {
//        guard alpha > 0 else { return .nothing }
//        return input?.renderExtent ?? .nothing
//    }
//    
//    override var isInvisible: Bool {
//        if payload > 0, !(input?.isInvisible ?? true) {
//            return false
//        } else {
//            return true
//        }
//    }
//    
//    override var isIdentity: Bool {
//        return alpha == 1
//    }
//    
//    override var possibleOptimizations: [OptFunc] {
//        return [removeInvisibles, removeIdentity, alphaCoalesce]
//    }
//    
//    var alphaCoalesce: OptFunc { return { AlphaCoalesce($0) } }
//    
//}
//
//
//class AlphaCoalesce: CoalescingOptimization<Float,AlphaNode> {
//
//    required init?(_ source: Node) { super.init(source as! AlphaNode, coalescingFunction: (*)) }
//
//}

extension Float: NodePayload {
    
}
