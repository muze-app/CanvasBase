//
//  LayerMetaNode.swift
//  CanvasDAG
//
//  Created by Greg Fajen on 12/27/19.
//

import Foundation

public typealias LayerKey = Key<LayerMetaNode>

public class LayerMetaNode: PayloadNode<LayerMetadata> {
    
    public init(_ key: NodeKey = NodeKey(), graph: Graph, payload: LayerMetadata? = nil) {
        super.init(key, graph: graph, payload: payload, nodeType: .layerMeta)
    }
    
}

public struct LayerMetadata: NodePayload {
    
    public init() { }
    
    public var blendMode: BlendMode = .normal
    public var alpha: Float = 1
    public var isHidden = false
    
    public var blendPayload: BlendPayload { .init(blendMode, alpha) }
    
}
