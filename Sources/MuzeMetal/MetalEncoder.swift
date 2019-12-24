//
//  MetalEncoder.swift
//  muze
//
//  Created by Greg on 2/11/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import UIKit
import Metal
import MetalPerformanceShaders

class MetalEncoder {
    
    // MARK: Pass Descriptor
    
    var target: MTLTexture?
    var loadAction: LoadAction = .dontCare
    
    var identifier: String?
    
    enum LoadAction: Equatable {
        case dontCare, load, clear(UIColor)
        
        var isClear: Bool {
            switch self {
                case .clear: return true
                default: return false
            }
        }
        
    }
    
    var passDescriptor: MTLRenderPassDescriptor {
        let descriptor = MTLRenderPassDescriptor()
        let colorAttachment = descriptor.colorAttachments[0]!
        colorAttachment.texture = target!
        
        switch loadAction {
            
            case .dontCare:
                colorAttachment.loadAction = .dontCare
            case .load:
                colorAttachment.loadAction = .load
            case .clear(let color):
                colorAttachment.loadAction = .clear
                colorAttachment.clearColor = MTLClearColor(color)
        }
        
        return descriptor
    }
    
    var pixelFormat: MTLPixelFormat {
        return target!.pixelFormat
    }
    
    // MARK: Fences
    
    var inputFences: [MTLFence] = []
    var outputFence: MTLFence?
    
    func addInputFences(_ fences: [MTLFence]) {
        for fence in fences {
            if !inputFences.contains(where: { $0 === fence }) {
                inputFences.append(fence)
            }
        }
    }
    
    // MARK: Commands
    
    var commands: [Command] = []
    var isEmpty: Bool { return commands.isEmpty }
    
    func push(_ command: Command) {
        commands.append(command)
    }
    
    enum Command {
        case pipelineState(MTLRenderPipelineState)
        case vertexBuffers([MetalBuffer])
        case fragmentBuffers([MetalBuffer])
        case fragmentTextures([MTLTexture])
        case primitives(MTLPrimitiveType,Int)
        case special(MPSImageGaussianBlur,MTLTexture,MTLTexture)
    }
    
    // MARK: Setting up
    
    func setPipelineState(_ state: MTLRenderPipelineState) {
        push(.pipelineState(state))
    }
    
    func setVertexBuffers(_ buffers: [MetalBuffer]) {
        push(.vertexBuffers(buffers))
    }
    
    func setFragmentBuffers(_ buffers: [MetalBuffer]) {
        push(.fragmentBuffers(buffers))
    }
    
    func setFragmentTextures(_ textures: [MTLTexture]) {
        push(.fragmentTextures(textures))
    }
    
    func drawPrimitives(type: MTLPrimitiveType, vertexCount: Int) {
        push(.primitives(type, vertexCount))
    }
    
    // MARK: adding to command buffer
    
    var isSpecial: Bool {
        guard let command = commands.first else { return false }
        switch command {
            case .special: return true
            default: return false
        }
    }
    
    func addToCommandBuffer(_ commandBuffer: MetalCommandBuffer) {
        if isSpecial {
            addToComputeBuffer(commandBuffer)
            return
        }
         
        let buffer = commandBuffer.buffer
        let encoder = buffer.makeRenderCommandEncoder(descriptor: passDescriptor)!
        
        buffer.label = identifier
        
        let allFences = inputFences + outputFence.array
        for fence in allFences {
            encoder.waitForFence(fence, before: .fragment)
        }
        
        for command in commands {
            switch command {
                case .pipelineState(let state):
                    encoder.setRenderPipelineState(state)
                
                case .vertexBuffers(let buffers):
                    encoder.setVertexBuffers(buffers)
                
                case .fragmentBuffers(let buffers):
                    encoder.setFragmentBuffers(buffers)
                
                case .fragmentTextures(let textures):
                    encoder.setFragmentTextures(textures)
                
                case .primitives(let type, let vertexCount):
                    encoder.drawPrimitives(type: type,
                                           vertexStart: 0,
                                           vertexCount: vertexCount)
                
                case .special:
                    fatalError()
            }
        }
        
        for fence in allFences {
            encoder.updateFence(fence, after: .fragment)
        }
        
        encoder.endEncoding()
    }
    
    func addToComputeBuffer(_ commandBuffer: MetalCommandBuffer) {
        let buffer = commandBuffer.buffer
        //        let encoder = buffer.makeComputeCommandEncoder()!
        
        var encoder = buffer.makeComputeCommandEncoder()!
        
        let allFences = inputFences + outputFence.array
        for fence in allFences {
            encoder.waitForFence(fence)
        }
        
        encoder.endEncoding()
        
        for command in commands {
            switch command {
                case .special(let kernel, let input, let output):
                    
                    //                kernel.sourceRegion(destinationSize: <#T##MTLSize#>)
                    kernel.edgeMode = .clamp
                    
                    kernel.encode(commandBuffer: buffer, sourceTexture: input, destinationTexture: output)
                
//                                let size = MTLSize(input.size)
//
//                                encoder.copy(from: input,
//                                             sourceSlice: 0,
//                                             sourceLevel: 0,
//                                             sourceOrigin: .zero,
//                                             sourceSize: size,
//                                             to: output,
//                                             destinationSlice: 0,
//                                             destinationLevel: 0, destinationOrigin: .zero)
                
                default: fatalError()
            }
        }
        
        encoder = buffer.makeComputeCommandEncoder()!
        
        for fence in allFences {
            encoder.updateFence(fence)
        }
        
        encoder.endEncoding()
    }
    
}
