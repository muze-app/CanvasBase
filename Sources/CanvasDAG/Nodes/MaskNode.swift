//
//  MaskNode.swift
//  muze
//
//  Created by Greg Fajen on 5/17/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import MuzeMetal

public enum MaskMode: Hashable { case blackIsTransparent, whiteIsTransparent }
extension MaskMode: NodePayload { }

final class MaskNode: PayloadNode<MaskMode> {

    var isResultOfMaskToSeriesOptimization = false

//    override var worthCaching: Bool { return true }

    init(_ key: NodeKey = NodeKey(),
         graph: CanvasGraph,
         payload: MaskMode? = nil) {
        super.init(key, graph: graph, payload: payload, nodeType: .mask)
    }

    var mask: Node? {
        get { return nodeInputs[1] }
        set { nodeInputs[1] = newValue }
    }

    var input: Node? {
        get { return nodeInputs[0] }
        set { nodeInputs[0] = newValue }
    }

    var mode: MaskMode {
        get { return payload }
        set { payload = newValue }
    }

//    override public func renderPayload(for options: RenderOptions) -> RenderPayload? {
//        guard let input = self.input?.renderPayload(for: options) else { return nil }
//        guard let mask  =  self.mask?.renderPayload(for: options) else { return input }
//
//        let masked = RenderIntermediate(identifier: "Mask", options: options, extent: renderExtent)
//        masked << RenderPassDescriptor(identifier: "Mask",
//            pipeline: pipeline,
//            inputs: [input, mask])
//
//        return masked.payload
//    }
//
//    override var calculatedRenderExtent: RenderExtent {
//        guard let ie = input?.renderExtent, ie != .infinite else {
//            return mask?.renderExtent ?? .nothing
//        }
//
//        return ie
//    }
//
//    override var calculatedUserExtent: UserExtent {
//        guard let ie = input?.userExtent, ie.extent != .infinite else {
//            return mask?.userExtent ?? .nothing
//        }
//
//        return ie
//    }

    var pipeline: MetalPipeline {
        switch mode {
            case .blackIsTransparent: return .maskPipeline
            case .whiteIsTransparent: return .inverseMaskPipeline
        }
    }

    override var isInvisible: Bool { input?.isInvisible ?? true }
    override var isIdentity: Bool { mask?.isInvisible ?? true }

//    override var possibleOptimizations: [OptFunc] {
//        return [removeIdentity, removeInvisibles, maskToSeries]
//    }
//
//    let maskToSeries: OptFunc = { MaskToSeriesOpt($0) }

}

extension MaskNode {

    typealias TempType = Node // should be DNode

    var myMasks: [(MaskMode, Node?)] {
        guard let mask = self.mask else {
            return []
        }

        if let series = mask as? MaskSeriesNode {
            let pairs: [(MaskMode, Node?)] = series.pairs.map { ($0.0, $0.1) }

            if mode == .blackIsTransparent {
                return pairs
            } else {
                return pairs.map { (!$0.0, $0.1) }
            }
        }

        return [(mode, mask)]
    }

    var asMasksAndInput: ([(MaskMode, TempType?)], TempType)? {
        guard let myInput = self.input else {
            return nil
        }

        if let maskInput = myInput as? MaskNode {
            if let (masks, input) = maskInput.asMasksAndInput {
                return (myMasks + masks, input)
            } else {
                return nil
            }
        }

        return (myMasks, myInput)
    }

}

final class MaskToSeriesOpt: Optimization {

    var maskNode: MaskNode? {
        return left as? MaskNode
    }

    override var isValid: Bool {
        guard let maskNode = self.maskNode else { return false }
        if maskNode.isResultOfMaskToSeriesOptimization { return false }

        guard let (masks, _) = maskNode.asMasksAndInput else { return false }
        return masks.count > 1
    }

    override func setupTarget(graph: MutableCanvasGraph) {
        let (masks, input) = maskNode!.asMasksAndInput!

        let series = MaskSeriesNode(graph: graph, payload: [])
        series.pairs = masks.map { ($0.0, $0.1) }

        let target = MaskNode(graph: graph, payload: .blackIsTransparent)
        target.mask = series
        target.input = input
        target.isResultOfMaskToSeriesOptimization = true

        right = target
    }

}

//extension Image: CustomDebugStringConvertible {
//
//    var debugDescription: String {
//        return "Image(\(identifier))"
//    }
//
//}

extension MaskMode {

    static prefix func ! (m: MaskMode) -> MaskMode {
        switch m {
            case .whiteIsTransparent: return .blackIsTransparent
            case .blackIsTransparent: return .whiteIsTransparent
        }
    }

}
