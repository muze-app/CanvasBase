//
//  MaskedColorNode.swift
//  CanvasBase
//
//  Created by Greg Fajen on 12/26/19.
//

import DAG
import MuzeMetal

public struct MaskedColorPayload: NodePayload {
    var a: RenderColor2
    var b: MaskMode
    init(_ a: RenderColor2, _ b: MaskMode) { self.a = a; self.b = b }
}

public final class MaskedColorNode: InputNode<MaskedColorPayload> {
    
    public init(_ key: NodeKey = NodeKey(),
                graph: Graph,
                payload: MaskedColorPayload? = nil) {
        super.init(key, graph: graph, payload: payload, nodeType: .maskedColor)
    }
    
    final var mask: Node? {
        get { return input }
        set { input = newValue }
    }
    
    final var mode: MaskMode {
        get { return payload.b }
        set { payload.b = newValue }
    }
    
    final var color: RenderColor2 {
        get { return payload.a }
        set { payload.a = newValue }
    }
    
    final var colorTexture: MetalTexture { return MetalSolidColorTexture(color).texture }
    
//    final override func renderPayload(for options: RenderOptions) -> RenderPayload? {
//        guard let mask = self.mask?.renderPayload(for: options) else {
//            return nil
//        }
//
//        let colorBuffer = color
//
//        let masked = RenderIntermediate(identifier: "\(self)", options: options, extent: renderExtent)
//        masked << RenderPassDescriptor(identifier: "Mask",
//                                       pipeline: pipeline,
//                                       fragmentBuffers: [colorBuffer],
//                                       inputs: [mask])
//
//        return masked.payload
//    }
//
//    final override var calculatedRenderExtent: RenderExtent {
//        return mask?.renderExtent ?? .infinite
//    }
    
    final var pipeline: MetalPipeline {
        switch mode {
            case .blackIsTransparent: return .maskColorPipeline
            case .whiteIsTransparent: return .inverseMaskColorPipeline
        }
    }
    
//    override var possibleOptimizations: [OptFunc] {
//        return [removeInvisibles]
//    }
    
    override public var isInvisible: Bool {
        return input?.isInvisible ?? true
    }
    
}
