//
//  TransformNode.swift
//  muze
//
//  Created by Greg Fajen on 5/19/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

//import Foundation
import MuzePrelude
import DAG

//typealias AffineTransform = MuzePrelude.AffineTransform

extension AffineTransform: NodePayload {
    
    public func transformed(by transform: AffineTransform) -> AffineTransform {
        return self * transform
    }
    
}

public class TransformNode: InputNode<AffineTransform> {
    
    public init(_ key: NodeKey = NodeKey(), graph: Graph, payload: AffineTransform? = nil) {
        super.init(key, graph: graph, payload: payload, nodeType: .transform)
    }
    
    public var transform: AffineTransform {
        get { return payload }
        set { payload = newValue }
    }
    
    override public func renderPayload(for options: RenderOptions) -> RenderPayload? {
        guard let input = self.input?.renderPayload(for: options) else { return nil }
        return .transforming(input, transform)
    }
    
    override public var calculatedRenderExtent: RenderExtent {
        guard let extent = input?.renderExtent else { return .nothing }
        return extent.transformed(by: transform)
    }
    
    override public var calculatedUserExtent: UserExtent {
        guard let extent = input?.userExtent else { return .nothing }
        return extent.transformed(by: transform)
    }
    
    override public var isInvisible: Bool {
        return input?.isInvisible ?? true
    }
    
    override public var isIdentity: Bool {
        return transform ~= .identity
    }
    
//    override var possibleOptimizations: [OptFunc] {
//        return [removeIdentity, removeInvisibles, pushThrough, coalesce]
//    }
//
//    var pushThrough: OptFunc { return { PushTransformThroughCompOpt($0) } }
//    var coalesce: OptFunc { return { TransformCoalesce($0) } }
    
}

class TransformCoalesce: CoalescingOptimization<AffineTransform,TransformNode> {
    
    required init?(_ source: Node) { super.init(source as! TransformNode, coalescingFunction: { $1 * $0 }) }
    
}

final class PushTransformThroughCompOpt: Optimization {
    
    var transformNode: TransformNode? {
        return left as? TransformNode
    }
    
    var compositeNode: CompositeNode? {
        return transformNode?.input as? CompositeNode
    }
    
    override var isValid: Bool {
        return compositeNode.exists
    }
    
    override func setupTarget(graph: MutableGraph) {
        let oldTransform = transformNode!
        let oldComposite = compositeNode!
        
        let payload = oldTransform.payload
        
        let result = CompositeNode(graph: graph, payload: [])
        result.pairs = oldComposite.pairs.map { (alpha, input) -> (Float,Node?) in
            let transform = TransformNode(graph: graph, payload: payload)
            transform.input = input
            return (alpha, transform)
        }
        
        right = result
    }
    
}
