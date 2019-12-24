//
//  MetalPipeline.swift
//  muze
//
//  Created by Greg on 1/3/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import UIKit
import Metal
import MuzePrelude

class MetalPipeline: CustomDebugStringConvertible {
    
    let vertex: VertexFunction
    let fragment: FragmentFunction
    let blending: MetalBlendingMode
    
    var states = ThreadSafeDict<MTLPixelFormat,MTLRenderPipelineState>()
        
        //[MTLPixelFormat:MTLRenderPipelineState]()
    
    var debugDescription: String {
        return "MetalPipeline (\(vertex.name),\(fragment.name))"
    }
    
    init(vertex: VertexFunction,
         fragment: FragmentFunction,
         blending: MetalBlendingMode = .normal) {
        self.vertex = vertex
        self.fragment = fragment
        self.blending = blending
    }
    
    func pipelineState(for pixelFormat: MTLPixelFormat) -> MTLRenderPipelineState {
        if let state = states[pixelFormat] { return state }
        
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = vertex.function
        descriptor.fragmentFunction = fragment.function
        
        let colorAttachment = descriptor.colorAttachments[0]!
        colorAttachment.pixelFormat = pixelFormat
        blending.set(on: colorAttachment)
        
        let device = MetalDevice.device
        let state = try! device.makeRenderPipelineState(descriptor: descriptor)
        states[pixelFormat] = state
        return state
    }
    
    @available(*, deprecated)
    static let blitPipeline = MetalPipeline(vertex: .basic, fragment: .blit)
    
    @available(*, deprecated)
    static let drawPipeline = MetalPipeline(vertex: .basic, fragment: .draw)
    
    static let drawPipeline2 = MetalPipeline(vertex: .basic, fragment: .draw2)
    static let rawPipeline = MetalPipeline(vertex: .basic, fragment: .raw)
    static let YUVDownPipeline = MetalPipeline(vertex: .basic, fragment: .YUVDown)
    static let YUVUpPipeline = MetalPipeline(vertex: .basic, fragment: .YUVUp)
    static var reorientPipeline: MetalPipeline { return MetalPipeline(vertex: .basic, fragment: .reorient) }
    static let matrixPipeline = MetalPipeline(vertex: .basic, fragment: .colorMatrix)
    static let sRGBMatrixPipeline = MetalPipeline(vertex: .basic, fragment: .sRGBColorMatrix)
    
    static let mixPipeline = MetalPipeline(vertex: .basic, fragment: .mix)
    static let maskPipeline = MetalPipeline(vertex: .basic, fragment: .mask)
    static let inverseMaskPipeline = MetalPipeline(vertex: .basic, fragment: .inverseMask)
    static let maskColorPipeline = MetalPipeline(vertex: .basic, fragment: .maskColor)
    static let inverseMaskColorPipeline = MetalPipeline(vertex: .basic, fragment: .inverseMaskColor)
    static let combineMaskPipeline = MetalPipeline(vertex: .basic, fragment: .draw2, blending: .combineMasks)
    static let inverseCombineMaskPipeline = MetalPipeline(vertex: .basic, fragment: .inverseDraw, blending: .combineMasks)
    
    static let brushPipeline = MetalPipeline(vertex: .brush, fragment: .brush)
    static let colorBrushPipeline = MetalPipeline(vertex: .brush, fragment: .brush)
    static let liveDrawPipeline = MetalPipeline(vertex: .brush, fragment: .liveDraw)
    
    static let canvasOverlayPipeline = MetalPipeline(vertex: .basic, fragment: .canvasOverlay)
    static let rectsPipeline = MetalPipeline(vertex: .basic, fragment: .rects)
    static let checkerboardPipeline = MetalPipeline(vertex: .basic, fragment: .checkerboard)
    
    var commandQueue: MTLCommandQueue {
        return MetalDevice.commandQueue
    }
    
    // MARK: Default Vertex Buffer
    
    private static let defaultVertexData: [Float] = [-1, -1, 0,
                                                      1, -1, 0,
                                                     -1,  1, 0,
                                                      1,  1, 0]
    
    static let defaultVertexBuffer: MetalBuffer = defaultVertexData.asData
    
}

enum MetalBlendingMode {
    
    case normal
    
    case combineMasks
    
    func set(on colorAttachment: MTLRenderPipelineColorAttachmentDescriptor) {
        switch self {
            case .normal:
                colorAttachment.isBlendingEnabled = true
                colorAttachment.rgbBlendOperation = .add
                colorAttachment.alphaBlendOperation = .add
                colorAttachment.sourceRGBBlendFactor = .one
                colorAttachment.sourceAlphaBlendFactor = .one
                colorAttachment.destinationRGBBlendFactor = .oneMinusSourceAlpha
                colorAttachment.destinationAlphaBlendFactor = .oneMinusSourceAlpha
                
            case .combineMasks:
                colorAttachment.isBlendingEnabled = true
                colorAttachment.rgbBlendOperation = .add
                colorAttachment.alphaBlendOperation = .add
                colorAttachment.sourceRGBBlendFactor = .destinationColor
                colorAttachment.destinationRGBBlendFactor = .zero
                colorAttachment.sourceAlphaBlendFactor = .one
                colorAttachment.destinationAlphaBlendFactor = .one
        }
    }
    
}
