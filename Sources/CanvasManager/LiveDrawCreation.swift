//
//  LiveDrawCreation.swift
//  muze
//
//  Created by Greg Fajen on 5/31/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import MuzePrelude
import MuzeMetal

class LiveDrawCreation: DrawingCreation {
    
    var stroke: BrushStroke?
    var texture: MetalTexture?
    var interpolator: DabInterpolator?
    var realizer: DabRealizer?
    
    var shouldClear = true
 
    func startStroke(dab: AbstractDab, point: CGPoint) {
        let spacing: CGFloat
        let format: MTLPixelFormat
        
        if CGFloat.screenWidth == 320 {
            spacing = 0.1
            format = .rgba8Unorm_srgb
        } else {
            spacing = 0.05
            format = .rgba16Float
        }
        
        stroke = BrushStroke(defaultDab: dab, spacing: spacing)
        interpolator = DabInterpolator(stroke: stroke!)
        realizer = DabRealizer(interpolator: interpolator!)
        
        texture = MetalHeapManager.shared.makeTexture(canvasManager.currentMetadata.size,
                                                      format,
                                                      type: .longTerm)
        
        texture?.clear()
        
        modify { subgraph in
            let graph = subgraph.graph
            
            let blend = BlendNode(graph: graph, payload: .init(.normal, 1))
            blend.source = ImageNode(texture: texture!, graph: graph)
            blend.destination = subgraph.finalNode
            
            subgraph.finalNode = blend
        }
    }
    
    func cleanupStroke() {
        stroke = nil
        texture = nil
    }
    
    func draw(texture: MetalTexture?) {
        guard let dabs = realizer?.getDabs(), dabs.count > 0, let t = texture else { return }
        
        let vertexBuffer = dabs.flatMap { $0.components }
        
        let transform = self.transform(for: t)
        
        let width = Float(self.texture!.size.width)
        let height = Float(self.texture!.size.height)
        let sizeBuffer = [width, height]
        
        let clearColor = shouldClear ? UIColor.clear : nil
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

extension MetalTexture {
    
    var width: Int { return Int(size.width) }
    var height: Int { return Int(size.height) }
    
}
