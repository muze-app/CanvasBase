//
//  MaskSeriesNode.swift
//  muze
//
//  Created by Greg Fajen on 5/20/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import MuzeMetal

public final class MaskSeriesNode: ListNode<MaskMode> {

    init(_ key: NodeKey = NodeKey(),
         graph: CanvasGraph,
         payload: [MaskMode]? = nil) {
        super.init(key, graph: graph, payload: payload, nodeType: .maskSeries)
    }

//    override var calculatedRenderExtent: RenderExtent {
//        return inputs.reduce(.nothing) { $0.union(with: $1.renderExtent) }
//    }
//
//    override var calculatedUserExtent: UserExtent {
//        return inputs.reduce(.nothing) { $0.union(with: $1.userExtent) }
//    }
//
//    override func renderPayload(for options: RenderOptions) -> RenderPayload? {
//        let intermediate = RenderIntermediate(identifier: "Mask Series",
//                                              options: options,
//                                              extent: renderExtent,
//                                              pixelFormat: .r8Unorm)
//
//        for (mode, input) in pairs {
//            guard let mask = input?.renderPayload(for: options) else { continue }
//            intermediate << RenderPassDescriptor(identifier: "Mask Series Pass",
//                                                 pipeline: pipeline(for: mode),
//                                                 inputs: [mask])
//        }
//
//        intermediate.passes.first?.clearColor = .white
//
//        return intermediate.payload
//    }

    func pipeline(for mode: MaskMode) -> MetalPipeline {
        switch mode {
            case .blackIsTransparent: return .combineMaskPipeline
            case .whiteIsTransparent: return .inverseCombineMaskPipeline
        }
    }

}
