//
//  BrushNode.swift
//  muze
//
//  Created by Greg Fajen on 5/19/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import MuzeMetal

public struct BrushNodePayload: NodePayload {
    
    public let texture: MetalTexture
    public let brushContext: BrushContext
    public let transform: AffineTransform
    
    public var i = 0
    public var status = Status.hidden
    
    public enum Status {
        case hidden, visible, done
    }
    
    public init(defaultDab: AbstractDab, canvasSize: CGSize, spacing: CGFloat = BrushStroke.defaultSpacing) {
        texture = MetalHeapManager.shared.makeTexture(canvasSize, .r8Unorm, type: .longTerm)!
        texture.colorSpace = .working
    
        brushContext = BrushContext(defaultDab: defaultDab.with(color: .white), spacing: spacing)
        transform = .identity
    }
    
    public var stroke: BrushStroke { return brushContext.stroke }
    public var interpolator: DabInterpolator { return brushContext.interpolator }
    public var realizer: DabRealizer { return brushContext.realizer }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(texture.pointerString)
        hasher.combine(transform)
        hasher.combine(i)
        hasher.combine(status)
    }
    
    private init(_ d: MetalTexture, _ c: BrushContext, _ t: AffineTransform, _ i: Int, _ s: Status) {
        texture = d
        brushContext = c
        transform = t
        status = s
        self.i = i
    }
    
    public func transformed(by transform: AffineTransform) -> BrushNodePayload {
        return BrushNodePayload(texture,
                                brushContext,
                                self.transform * transform,
                                i,
                                status)
    }
    
}

public class BrushNode: GeneratorNode<BrushNodePayload> {
    
    override public var calculatedCacheable: Bool { status == .done }
    
    public convenience init(_ key: NodeKey = NodeKey(),
                            graph: Graph,
                            defaultDab: AbstractDab,
                            canvasSize: CGSize) {
        let payload = BrushNodePayload(defaultDab: defaultDab, canvasSize: canvasSize)
        self.init(key, graph: graph, payload: payload)
    }
    
    public init(_ key: NodeKey = NodeKey(),
                graph: Graph,
                payload: BrushNodePayload? = nil) {
        super.init(key, graph: graph, payload: payload, nodeType: .brush)
    }
    
    public var texture: MetalTexture { return payload.texture }
    public var transform: AffineTransform { return payload.transform }
    
    public var stroke: BrushStroke { return payload.stroke }
    public var realizer: DabRealizer { return payload.realizer }
    
    public var i: Int {
        get { payload.i }
        set { payload.i = newValue }
    }
    
    public var status: BrushNodePayload.Status {
        get { payload.status }
        set { payload.status = newValue }
    }
    
    override public func renderPayload(for options: RenderOptions) -> RenderPayload? {
        guard status != .hidden else { return nil }
        
        texture.identifier = texture.identifier ?? "Brush"
        
        let t: RenderPayload = .texture(texture)
        return .cropAndTransform(t, texture.size, transform)
    }
    
    override public var calculatedRenderExtent: RenderExtent {
        return .basic(.init(size: texture.size, transform: transform))
    }
    
    override public var calculatedUserExtent: UserExtent {
        return .brush & renderExtent
    }
    
    public func draw() {
        let dabs = realizer.getDabs()
        if dabs.count == 0 { return }
        
        let vertexBuffer = dabs.flatMap { $0.components }
        
        let drawable = payload.texture
        
        let width = Float(drawable.width)
        let height = Float(drawable.height)
        let sizeBuffer = [width, height]
        
        let pass = MetalPass(pipeline: .brushPipeline,
                             drawable: drawable,
                             primitive: .triangle,
                             vertexCount: dabs.count * 6,
                             vertexBuffers: [vertexBuffer, sizeBuffer])
        
        pass.commit()
        
        i += 1
    }
    
//    var possibleOptimizations: [OptFunc] {
//        return [brushToImage]
//    }
    
//    var brushToImage: OptFunc { return { BrushToImageOpt($0) } }
    
    override public var isInvisible: Bool { status != .hidden }
    
//    override var cacheable: Bool {
//        return readyToShow
//    }
    
}

class BrushToImageOpt: Optimization {
    
    var brushNode: BrushNode? {
        return left as? BrushNode
    }
    
    override var isValid: Bool {
        return left is BrushNode
    }
    
    override func setupTarget(graph: MutableGraph) {
        let brushNode = self.brushNode!
        let graph = brushNode.graph
        
        if brushNode.status != .hidden {
            right = ImageNode(texture: brushNode.texture, transform: brushNode.transform, graph: graph)
        } else {
            right = nil
        }
    }
    
}
