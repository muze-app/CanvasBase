//
//  BlendNode.swift
//  muze
//
//  Created by Greg Fajen on 5/17/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation
import MuzePrelude
import MuzeMetal
import DAG

public struct BlendPayload: NodePayload {
    
    var mode: BlendMode
    var alpha: Float
    
    public init(_ mode: BlendMode, _ alpha: Float) {
        self.mode = mode
        self.alpha = alpha
    }
}

public final class BlendNode: PayloadNode<BlendPayload> {
    
    public init(_ key: NodeKey = NodeKey(), graph: Graph, payload: BlendPayload? = nil) {
        super.init(key, graph: graph, payload: payload, nodeType: .blend)
    }
    
//    public override var worthCaching: Bool { return true }
    
    public var blendMode: BlendMode {
        get { return payload.mode }
        set { payload.mode = newValue }
    }
    
    public var alpha: Float {
        get { return payload.alpha }
        set { payload.alpha = newValue }
    }
    
    public var source: Node? {
        get { return nodeInputs[0] }
        set { nodeInputs[0] = newValue }
    }
    
    public var destination: Node? {
        get { return nodeInputs[1] }
        set { nodeInputs[1] = newValue }
    }
    
    public var primaryInput: Node? {
        get { return destination }
        set { destination = newValue }
    }
    
    override public var calculatedRenderExtent: RenderExtent {
        guard let se = source?.renderExtent else { return destination?.renderExtent ?? .nothing }
        guard let de = destination?.renderExtent else { return se }

        return se.union(with: de)
    }

    override public var calculatedUserExtent: UserExtent {
        guard let se = source?.userExtent else { return destination?.userExtent ?? .nothing }
        guard let de = destination?.userExtent else { return se }

        return se.union(with: de)
    }

    override public func renderPayload(for options: RenderOptions) -> RenderPayload? {
        guard alpha > 0 else {
            return destination?.renderPayload(for: options)
        }

        let dstLoadO = destination?.renderPayload(for: options)
        guard let srcLoad = source?.renderPayload(for: options) else {
            return dstLoadO
        }

        guard let dstLoad = dstLoadO else {
            return composite(source: srcLoad, destination: nil, options: options)
        }

        if blendMode == .normal {
//            #warning("this'll be optimized away soon")
            return composite(source: srcLoad, destination: dstLoad, options: options)
        }

        return blend(source: srcLoad,
                     destination: dstLoad,
                     options: options)
    }
    
    // MARK: Blend
    
    public func blend(source: RenderPayload, destination: RenderPayload, options: RenderOptions) -> RenderPayload {

        let composite = RenderIntermediate(identifier: "Blend \(blendMode)", options: options, extent: renderExtent)

        composite << RenderPassDescriptor(identifier: "Blend \(blendMode)",
            pipeline: blendMode.pipeline,
            inputs: [.alpha(source, alpha), destination])

        return composite.payload
    }
    
    // MARK: Composite
    
    public func composite(source: RenderPayload, destination: RenderPayload?, options: RenderOptions) -> RenderPayload {
        let composite = RenderIntermediate(identifier: "Blend", options: options, extent: renderExtent)

        if let destination = destination {
            composite << RenderPassDescriptor(identifier: "Destination",
                                              pipeline: .drawPipeline2,
                                              input: destination)
        }

        composite << RenderPassDescriptor(identifier: "Source",
                                          pipeline: .drawPipeline2,
                                          input: .alpha(source, alpha))

        return composite.payload
    }
    
    var sourceIsInvisible: Bool {
        return alpha == 0 || (source?.isInvisible ?? true)
    }
    
    var destinationIsInvisible: Bool {
        return destination?.isInvisible ?? true
    }
    
    override public var isInvisible: Bool {
        return sourceIsInvisible && destinationIsInvisible
    }

}

final class BlendCleanUpOpt: Optimization {

    var blendNode: BlendNode? {
        return left as? BlendNode
    }

//    func nodeIsInvisible(_ node: Node?) -> Bool {
//        return node?.isInvisible ?? true
//    }

    override var isValid: Bool {
        guard let blendNode = self.blendNode else { return false }
        return blendNode.sourceIsInvisible ^ blendNode.destinationIsInvisible
    }

    override func setupTarget(graph: MutableGraph) {
        let blendNode = self.blendNode!

        if blendNode.sourceIsInvisible {
            right = blendNode.destination
        } else {
            let alpha = AlphaNode(graph: graph, payload: blendNode.alpha)
            alpha.input = blendNode.source

            right = alpha
        }
    }

}

final class BlendToCompOpt: Optimization {

    var blendNode: BlendNode? {
        return left as? BlendNode
    }

    override var isValid: Bool {
        if let node = blendNode,
               node.blendMode == .normal,
              !node.sourceIsInvisible,
              !node.destinationIsInvisible {
            return true
        }

        return false
    }

    override func setupTarget(graph: MutableGraph) {
        let blendNode = self.blendNode!

        let composite = CompositeNode(graph: graph, payload: [])
        composite.pairs = [(blendNode.alpha, blendNode.source!),
                           (1,               blendNode.destination!)]

        right = composite
    }

}

extension Bool {
    
    static func ^ (l: Bool, r: Bool) -> Bool {
        return l != r
    }
    
}
