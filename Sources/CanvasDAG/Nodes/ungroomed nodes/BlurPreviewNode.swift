//
//  BlurPreviewNode.swift
//  muze
//
//  Created by Greg Fajen on 6/1/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation
import Metal
import MetalPerformanceShaders

//struct BlurPreviewPayload: NodePayload, Animatable {
//    
//    var sigma: Float {
//        didSet {
//            print("sigma = \(sigma) (\(Int(round(sigma))))")
//            print(" ")
//        }
//    }
////    var mode: MaskMode
//    
//    init(_ sigma: Float = 0) {
//        self.sigma = sigma
////        self.mode = mode
//    }
//    
//    func blend(with other: BlurPreviewPayload, _ t: Float) -> BlurPreviewPayload {
//        return .init(sigma.blend(with: other.sigma, t))
//    }
//    
//}
//
//class BlurPreviewNode: PNode<BlurPreviewPayload> {
//    
//    init(_ key: NodeKey = NodeKey(), graph: DAG, payload: BlurPreviewPayload? = nil) {
//        super.init(key, graph: graph, payload: payload, nodeType: .blurPreview)
//    }
//    
////    var kernel: MPSImageGaussianBlur?
//    
//    func updateKernel() -> MPSImageGaussianBlur {
////        if let kernel = kernel, kernel.sigma == sigma { return }
//        return MPSImageGaussianBlur(device: MetalDevice.device, sigma: sigma)
//    }
//    
//    var mask: DNode? {
//        get { return nodeInputs[1] }
//        set { nodeInputs[1] = newValue }
//    }
//    
//    var input: DNode? {
//        get { return nodeInputs[0] }
//        set { nodeInputs[0] = newValue }
//    }
//    
////    var mode: MaskMode {
////        get { return payload.mode }
////        set { payload.mode = newValue }
////    }
//    
//    var sigma: Float {
//        get { return payload.sigma }
//        set { payload.sigma = newValue }
//    }
//    
//    var primaryInput: DNode? {
//        get { return input }
//        set { input = newValue }
//    }
//    
//    override public func renderPayload(for options: RenderOptions) -> RenderPayload? {
//        guard let input = self.input?.renderPayload(for: options)?.normalized(for: options) else { return nil }
//       let kernel = updateKernel()
//        
//        input.intermediate?.canAlias = false
//        
//        let intermediate = RenderIntermediate(identifier: "blur", options: options, extent: input.extent)
//        intermediate << SpecialRenderPass(input: input, kernel: kernel)
//        intermediate.canAlias = false
//        
//        guard !maskIsInvisible, let mask = self.mask?.renderPayload(for: options) else { return intermediate.payload }
//        
//        let mixed = RenderIntermediate(identifier: "Mix", options: options, extent: input.extent)
//        mixed << RenderPassDescriptor(identifier: "Mix",
//                                       pipeline: .mixPipeline,
//                                       inputs: [input, intermediate.payload, mask])
//
//        return mixed.payload
//    }
//    
//    override var calculatedRenderExtent: RenderExtent {
//        return input?.renderExtent ?? .nothing
//    }
//    
//    var maskIsInvisible: Bool {
//        guard let mask = mask else { return true }
////        if let mask = mask as? SolidColorNode {
////            if mask.color.r == 1 {
////                return true
////            }
////        }
//        
//        return false
//    }
//    
//    override var isInvisible: Bool {
//        return input?.isInvisible ?? true
//    }
//    
//    override var isIdentity: Bool {
//        return sigma <= 0.001
//    }
//    
//    override var possibleOptimizations: [OptFunc] {
//        return [removeIdentity, removeInvisibles]
//    }
//    
//}
//
//extension RenderPayload {
//    
//    func normalized(for options: RenderOptions, force: Bool = false) -> RenderPayload {
//        if !force,
//            let (intermediate, transform) = intermediateAndTransform,
//            transform ~= .identity,
//            intermediate.size == options.size! {
//            return self
//        }
//        
//        let extent = BasicExtent(size: options.size!)
//        
//        let draw = RenderIntermediate(identifier: "normalize", options: options, extent: .basic(extent))
//        draw << RenderPassDescriptor(identifier: "normalize", pipeline: .drawPipeline2, input: self)
//        
//        draw.canAlias = false
//    
//        return draw.payload
//    }
//    
//}
