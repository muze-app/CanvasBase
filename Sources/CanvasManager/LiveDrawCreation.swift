//
//  LiveDrawCreation.swift
//  muze
//
//  Created by Greg Fajen on 5/31/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import MuzePrelude
import MuzeMetal
import Metal

public class LiveDrawCreation: DrawingCreation {
    
    public var imageKey: NodeKey?
    public var stroke: BrushStroke?
    public var texture: MetalTexture?
    public var interpolator: DabInterpolator?
    public var realizer: DabRealizer?
    
    public var shouldClear = true
 
    public func startStroke(dab: AbstractDab, point: CGPoint) {
        let spacing: CGFloat
        let format: MTLPixelFormat
        
        #if os(iOS)
        if CGFloat.screenWidth == 320 {
            spacing = 0.1
            format = .rgba8Unorm_srgb
        } else {
            spacing = 0.05
            format = .rgba16Float
        }
        #else
        spacing = 0.05
        format = .rgba16Float
        #endif
        
        imageKey = NodeKey()
        let canvasSize = canvasManager.currentMetadata.size
        
        stroke = BrushStroke(defaultDab: dab, spacing: spacing)
        interpolator = DabInterpolator(stroke: stroke!)
        realizer = DabRealizer(interpolator: interpolator!)
        
        texture = MetalHeapManager.shared.makeTexture(canvasSize,
                                                      format,
                                                      type: .longTerm)
        
        texture?.clear()
        
        startSubtransaction("stroke")
        
        modify("startStroke") { subgraph in
            let graph = subgraph.graph

            let image = ImageNode(imageKey!, texture: texture!, graph: graph)
            image.status = .hidden
            
            let blend = BlendNode(graph: graph, payload: .init(.normal, 1))
            blend.source = image
            blend.destination = subgraph.finalNode
            
            subgraph.finalNode = blend
        }
    }
    
    public func cleanupStroke() {
        stroke = nil
        texture = nil
        imageKey = nil
    }
    
    public func draw(texture: MetalTexture?) {
        guard let dabs = realizer?.getDabs(), dabs.count > 0, let t = texture else { return }
        
        let vertexBuffer = dabs.flatMap { $0.components }
        
        let transform = self.transform(for: t)
        
        let width = Float(self.texture!.size.width)
        let height = Float(self.texture!.size.height)
        let sizeBuffer = [width, height]
        
        let clearColor = shouldClear ? Color.clear : nil
        shouldClear = false
        
        let pass = MetalPass(pipeline: .liveDrawPipeline,
                             drawable: self.texture!,
                             primitive: .triangle,
                             vertexCount: dabs.count * 6,
                             clearColor: clearColor,
                             vertexBuffers: [vertexBuffer, sizeBuffer],
                             fragmentBuffers: [transform, t.colorSpace!.matrix(to: .working)],
                             fragmentTextures: [t._texture])
        
        pass.commit()
    }
    
    public func strokeWillSucceed() {
        modify("strokeWillSucceed") { subgraph in
            let node = ImageNode(imageKey!, graph: subgraph.graph)
            node.status = .doNotCache
        }
    }
    
//    public func strokeFinished() {
//
//    }
    
    public func commitStroke() {
        modify("strokeFinished") { subgraph in
            let node = ImageNode(imageKey!, graph: subgraph.graph)
            node.status = .normal
        }
        
        commmitSubtransaction()
        cleanupStroke()
    }
    
    public func cancelStroke() {
        cancelSubtransaction()
        cleanupStroke()
    }
    
}

//class LiveDrawAction: PushInputNodeAction<BlendPayload,Bool,BlendNode> {
//    
//    init(_ texture: MetalTexture, initial layer: Layer, initial canvas: Canvas) {
//        fatalError()
//        let image = ImageNode.init(texture, .identity)
//        let blend = BlendNode.init(mode: .normal, alpha: 1)
//        blend.source = image
//
//        super.init(blend, initial: layer, initial: canvas)
//    }
//    
//}

public extension MetalTexture {
    
    var width: Int { return Int(size.width) }
    var height: Int { return Int(size.height) }
    
}
