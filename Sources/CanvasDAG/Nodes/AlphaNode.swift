//
//  AlphaNode.swift
//  muze
//
//  Created by Greg Fajen on 5/17/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation
import DAG

public class AlphaNode: InputNode<Float> {
    
    public init(_ key: NodeKey = NodeKey(), graph: Graph, payload: Float? = nil) {
        super.init(key, graph: graph, payload: payload, nodeType: .alpha)
    }
    
    var alpha: Float {
        get { return payload }
        set { payload = newValue }
    }
    
    override public func renderPayload(for options: RenderOptions) -> RenderPayload? {
        guard alpha > 0, let payload = input?.renderPayload(for: options) else { return nil }
        return .alpha(payload, alpha)
    }

    override public var calculatedRenderExtent: RenderExtent {
        guard alpha > 0 else { return .nothing }
        return input?.renderExtent ?? .nothing
    }
    
    override public var isInvisible: Bool {
        if alpha > 0, !(input?.isInvisible ?? true) {
            return false
        } else {
            return true
        }
    }
    
    override public var isIdentity: Bool { alpha == 1 }
    
}

class AlphaCoalesce: CoalescingOptimization<Float,AlphaNode> {

    required init?(_ source: Node) { super.init(source as! AlphaNode, coalescingFunction: (*)) }

}

extension Float: NodePayload {
    
}
