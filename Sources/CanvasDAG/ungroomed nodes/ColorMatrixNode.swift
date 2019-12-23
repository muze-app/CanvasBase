//
//  ColorMatrixNode.swift
//  muze
//
//  Created by Greg Fajen on 6/19/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation

//struct ColorMatrixPayload: NodePayload {
//    
//    var matrix: DMatrix3x3
//    var sRGB: Bool
//    
//    init(matrix: DMatrix3x3 = .identity, sRGB: Bool = false) {
//        self.matrix = matrix
//        self.sRGB = sRGB
//    }
//    
//}
//
//final class ColorMatrixNode: INode<ColorMatrixPayload> {
//    
//    init(_ key: NodeKey = NodeKey(), graph: DAG, payload: ColorMatrixPayload? = nil) {
//        super.init(key, graph: graph, payload: payload, nodeType: .colorMatrix)
//    }
//    
//    var matrix: DMatrix3x3 {
//        get { return payload.matrix }
//        set { payload.matrix = newValue }
//    }
//    
//    var sRGB: Bool {
//        get { return payload.sRGB }
//        set { payload.sRGB = newValue }
//    }
//    
//    var pipeline: MetalPipeline {
//        return sRGB ? .sRGBMatrixPipeline : .matrixPipeline
//    }
//    
//    override public func renderPayload(for options: RenderOptions) -> RenderPayload? {
//        guard let input = input?.renderPayload(for: options) else { return nil }
//        
//        if sRGB {
//        let intermediate = RenderIntermediate(identifier: "Color Matrix",
//                                              options: options,
//                                              extent: renderExtent)
//        
//        intermediate << RenderPassDescriptor(identifier: "Color Matrix",
//                                             pipeline: pipeline,
//                                             fragmentBuffers: [matrix],
//                                             input: input)
//        
//        return intermediate.payload
//        } else {
//            return .colorMatrix(input, matrix)
//        }
//    }
//    
//    override var calculatedRenderExtent: RenderExtent {
//        return input?.renderExtent ?? .nothing
//    }
//    
//    override var isInvisible: Bool {
//        return input?.isInvisible ?? true
//    }
//    
//    override var possibleOptimizations: [OptFunc] {
//        return [removeInvisibles]
//    }
//    
//}
