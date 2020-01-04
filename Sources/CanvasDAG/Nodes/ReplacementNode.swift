//
//  ReplacementNode.swift
//  CanvasBase
//
//  Created by Greg Fajen on 1/2/20.
//

import MuzeMetal

public struct ReplacementPayload: NodePayload, CustomDebugStringConvertible {
    
    public var texture: MetalTexture
    public var transform: AffineTransform
    public var contentHash: Int
    
    public init(_ a: MetalTexture,
                _ b: AffineTransform = .identity,
                _ c: Int) {
        self.texture = a
        self.transform = b
        self.contentHash = c
    }
    
    public func transformed(by transform: AffineTransform) -> ReplacementPayload {
        return .init(texture, self.transform * transform, contentHash)
    }
    
    public var debugDescription: String {
        let textureString = texture.identifier ?? texture.pointerString
        let transformString = "\(transform.cg.asFloats)"
        return "Replacement(\(textureString), \(transformString), \(contentHash))"
    }
    
}

public class ReplacementNode: GeneratorNode<ReplacementPayload> {
    
    override public var contentHash: Int { payload.contentHash }
    
    override public var cost: Int { 1 }

    public init(_ key: NodeKey,
                _ contentHash: Int,
                _ graph: MutableGraph,
                _ texture: MetalTexture,
                _ transform: AffineTransform) {
        let payload = ReplacementPayload(texture, transform, contentHash)
        
        print("REPLACING \(key) WITH REPLACEMENT")
        
        graph.setType(.replacement, for: key)
        graph.setPayload(payload, for: key, force: true)
        graph.setEdgeMap([:], for: key)
        
        super.init(key, graph: graph, payload: nil, nodeType: .replacement)
        
        graph.store.replacedNodes.append(key)
    }
    
    init(_ key: NodeKey,
         graph: Graph) {
        super.init(key, graph: graph, payload: nil, nodeType: .replacement)
    }
    
    var texture: MetalTexture {
        get { payload.texture }
        set { payload.texture = newValue }
    }
    
    var transform: AffineTransform {
        get { payload.transform }
        set { payload.transform = newValue }
    }
    
    override public func renderPayload(for options: RenderOptions) -> RenderPayload? {
        texture.identifier = texture.identifier ?? "Replacement"
        
        let t: RenderPayload = .texture(texture)
//        let m: RenderPayload = colorMatrixIsIdentity ? t : .colorMatrix(t, colorMatrix)
        
        return .cropAndTransform(t, texture.size, transform)
    }
    
    override public var calculatedRenderExtent: RenderExtent {
        return .basic(BasicExtent(size: texture.size, transform: transform))
    }
    
    override public var calculatedUserExtent: UserExtent {
        return .photo & renderExtent
    }
    
}
