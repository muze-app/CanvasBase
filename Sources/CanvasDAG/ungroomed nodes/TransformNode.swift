//
//  TransformNode.swift
//  muze
//
//  Created by Greg Fajen on 5/19/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation
import muze_prelude
import DAG

extension AffineTransform: NodePayload {
    
    public func transformed(by transform: AffineTransform) -> AffineTransform {
        return self * transform
    }
    
}

//final class TransformNode: INode<AffineTransform> {
//    
//    init(_ key: NodeKey = NodeKey(), graph: DAG, payload: AffineTransform? = nil) {
//        super.init(key, graph: graph, payload: payload, nodeType: .transform)
//    }
//    
//    var transform: AffineTransform {
//        get { return payload }
//        set { payload = newValue }
//    }
//    
//    override func renderPayload(for options: RenderOptions) -> RenderPayload? {
//        guard let input = self.input?.renderPayload(for: options) else { return nil }
//        return .transforming(input, transform)
//    }
//    
//    override var calculatedRenderExtent: RenderExtent {
//        guard let extent = input?.renderExtent else { return .nothing }
//        return extent.transformed(by: transform)
//    }
//    
//    override var calculatedUserExtent: UserExtent {
//        guard let extent = input?.userExtent else { return .nothing }
//        return extent.transformed(by: transform)
//    }
//    
//    override var isInvisible: Bool {
//        return input?.isInvisible ?? true
//    }
//    
//    override var isIdentity: Bool {
//        return transform ~= .identity
//    }
//    
//    override var possibleOptimizations: [OptFunc] {
//        return [removeIdentity, removeInvisibles, pushThrough, coalesce]
//    }
//    
//    var pushThrough: OptFunc { return { PushTransformThroughCompOpt($0) } }
//    var coalesce: OptFunc { return { TransformCoalesce($0) } }
//    
//}
//
//class TransformCoalesce: CoalescingOptimization<AffineTransform,TransformNode> {
//    
//    required init?(_ source: Node) { super.init(source as! TransformNode, coalescingFunction: { $1 * $0 }) }
//    
//}
//
//
//final class PushTransformThroughCompOpt: Optimization {
//    
//    var transformNode: TransformNode? {
//        return left as? TransformNode
//    }
//    
//    var compositeNode: CompositeNode? {
//        return transformNode?.input as? CompositeNode
//    }
//    
//    override var isValid: Bool {
//        return compositeNode.exists
//    }
//    
//    override func setupTarget(graph: MutableDAG) {
//        let oldTransform = transformNode!
//        let oldComposite = compositeNode!
//        
//        let payload = oldTransform.payload
//        
//        let result = CompositeNode(graph: graph, payload: [])
//        result.pairs = oldComposite.pairs.map { (alpha, input) -> (Float,DNode?) in
//            let transform = TransformNode(graph: graph, payload: payload)
//            transform.input = input
//            return (alpha, transform)
//        }
//        
//        right = result
//    }
//    
//}
