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
    
    public var readyToShow = false
    
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
    }
    
    private init(_ d: MetalTexture, _ c: BrushContext, _ t: AffineTransform) {
        texture = d
        brushContext = c
        transform = t
    }
    
    public func transformed(by transform: AffineTransform) -> BrushNodePayload {
        return BrushNodePayload(texture, brushContext, self.transform * transform)
    }
    
}

public class BrushNode: GeneratorNode<BrushNodePayload> {
    
    convenience init(_ key: NodeKey = NodeKey(),
                     graph: Graph,
                     defaultDab: AbstractDab,
                     canvasSize: CGSize) {
        let payload = BrushNodePayload(defaultDab: defaultDab, canvasSize: canvasSize)
        self.init(key, graph: graph, payload: payload)
    }
    
    init(_ key: NodeKey = NodeKey(),
         graph: Graph,
         payload: BrushNodePayload? = nil) {
        super.init(key, graph: graph, payload: payload, nodeType: .brush)
    }
    
    var texture: MetalTexture { return payload.texture }
    var transform: AffineTransform { return payload.transform }
    
    var stroke: BrushStroke { return payload.stroke }
    var realizer: DabRealizer { return payload.realizer }
    
    var readyToShow: Bool {
        get { return payload.readyToShow }
        set { payload.readyToShow = newValue }
    }
    
    override public var calculatedRenderExtent: RenderExtent {
        return .basic(.init(size: texture.size, transform: transform))
    }
    
    override public var calculatedUserExtent: UserExtent {
        return .brush & renderExtent
    }
    
    func draw() {
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
    }
    
//    var possibleOptimizations: [OptFunc] {
//        return [brushToImage]
//    }
    
//    var brushToImage: OptFunc { return { BrushToImageOpt($0) } }
    
    override public var isInvisible: Bool {
        return !readyToShow
    }
    
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
        
        // leave these 'comments' in for now please
//        if true {
//        if brushNode.readyToShow {
            right = ImageNode(texture: brushNode.texture, transform: brushNode.transform, graph: graph)
//        } else {
//            right = nil
//        }
    }
    
}
