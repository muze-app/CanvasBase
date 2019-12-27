//
//  MetalPass.swift
//  muze
//
//  Created by Greg on 1/3/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import MuzePrelude
import Metal

public class MetalPass<DrawableType: SimpleMetalDrawable> {
    
    let pipeline: MetalPipeline
    let drawable: DrawableType
    let clearColor: Color?
    
    let primitive: MTLPrimitiveType
    let vertexCount: Int
    
    let vertexBuffers: [MetalBuffer]
    let fragmentBuffers: [MetalBuffer]
    let fragmentTextures: [MTLTexture]
    
    public typealias CompletionType = ()->()
    let completionBlock: CompletionType?
    
    public var identifier: String?
    
    public init(pipeline: MetalPipeline,
                drawable: DrawableType,
                primitive: MTLPrimitiveType = .triangleStrip,
                vertexCount: Int = 4,
                clearColor: Color? = nil,
                vertexBuffers: [MetalBuffer],
                fragmentBuffers: [MetalBuffer] = [],
                fragmentTextures: [MTLTexture] = [],
                completion: CompletionType? = {}) {
        self.pipeline = pipeline
        self.drawable = drawable
        self.primitive = primitive
        self.vertexCount = vertexCount
        self.clearColor = clearColor ?? (drawable.needsClear ? .clear : nil)
        self.vertexBuffers = vertexBuffers
        self.fragmentBuffers = fragmentBuffers
        self.fragmentTextures = fragmentTextures
        self.completionBlock = completion
        
        drawable.needsClear = false
    }
    
//    func save(textures)
    
    var passDescriptor: MTLRenderPassDescriptor {
        if let descriptor = drawable.renderPassDescriptor {
            return descriptor
        }
        
            let descriptor = MTLRenderPassDescriptor()
            let colorAttachment = descriptor.colorAttachments[0]!
            colorAttachment.texture = drawable._texture
            
            if let color = clearColor {
                colorAttachment.loadAction = .clear
                colorAttachment.clearColor = MTLClearColor(color)
            } else {
                colorAttachment.loadAction = .load
            }
            
            return descriptor
    }
    
    var commandQueue: MTLCommandQueue {
        return MetalDevice.commandQueue
    }
    
    var loadAction: MetalEncoder.LoadAction {
        if let color = clearColor {
            return .clear(color)
        } else {
            return .load
        }
    }

//    @available(*, deprecated)
    public lazy var buffer: MTLCommandBuffer = self.generateBuffer()
    
//    @available(*, deprecated)
    private func generateBuffer() -> MTLCommandBuffer {
        
        let encoder = MetalEncoder()
        addToEncoder(encoder)
        
        encoder.outputFence = drawable.texture.fence
        
        let buffer = MetalCommandBuffer()
        encoder.addToCommandBuffer(buffer)
        
        if let completion = completionBlock {
            buffer.addCompletionHandler { _ in
                completion()
            }
        }
        
        return buffer.buffer
        
//        let buffer = commandQueue.makeCommandBuffer()!
//        let encoder = buffer.makeRenderCommandEncoder(descriptor: passDescriptor)!
//
//        encoder.setRenderPipelineState(pipeline.pipelineState)
//
//        encoder.setVertexBuffers(vertexBuffers)
//        encoder.setFragmentBuffers(fragmentBuffers)
//        encoder.setFragmentTextures(fragmentTextures)
//
//        encoder.drawPrimitives(type: primitive, vertexStart: 0, vertexCount: vertexCount)
//
//        encoder.endEncoding()
//
//        if let completion = completionBlock {
//            buffer.addCompletedHandler { _ in completion() }
//        }
//
//        return buffer
    }
    
    func canAddToEncoder(_ encoder: MetalEncoder) -> Bool {
        if encoder.isEmpty { return true }
        
        if loadAction.isClear {
            return false
        }

        if encoder.target !== drawable._texture {
            print("encoder.target: \(encoder.target!) \(encoder.target!.pointerString)")
            print("drawable.texture: \(drawable._texture) \(drawable._texture.pointerString)")
            return false
        }
        
        if fragmentTextures.contains(where: { $0 === drawable.texture }) {
            return false
        }
        
        return true
    }
    
    func addToEncoder(_ encoder: MetalEncoder) {
        if encoder.isEmpty {
            encoder.target = drawable._texture
            encoder.loadAction = loadAction
            encoder.identifier = identifier
        }
        
        let state = pipeline.pipelineState(for: encoder.pixelFormat)
        encoder.setPipelineState(state)
        
        encoder.setVertexBuffers(vertexBuffers)
        encoder.setFragmentBuffers(fragmentBuffers)
        encoder.setFragmentTextures(fragmentTextures)
        
        encoder.drawPrimitives(type: primitive, vertexCount: vertexCount)
    }
    
//    @available(*, deprecated)
    public func present() {
//        print("PRESENT!")
        #if !targetEnvironment(simulator)
        buffer.present(drawable.drawable!)
        #endif
    }
    
//    @available(*, deprecated)
    public func commit() {
        buffer.commit()
    }
    
}

public extension MTLClearColor {
    
    init(_ color: Color) {
        var r: CGFloat = 1
        var g: CGFloat = 1
        var b: CGFloat = 1
        var a: CGFloat = 1
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        self.init(red: Double(r), green: Double(g), blue: Double(b), alpha: Double(a))
    }
    
}

extension MTLRenderCommandEncoder {
    
    func setVertexBuffer(_ buffer: MetalBuffer, index: Int) {
        let data = buffer.asData as NSData
        if data.length <= 4096 {
            setVertexBytes(data.bytes, length: data.length, index: index)
        } else {
            let buffer = MetalDevice.device.makeBuffer(bytes: data.bytes, length: data.length, options: [])!
            setVertexBuffer(buffer, offset: 0, index: index)
        }
    }
    
    func setVertexBuffers(_ buffers: [MetalBuffer]) {
        for (i, buffer) in buffers.izip {
            setVertexBuffer(buffer, index: i)
        }
    }
    
    func setFragmentBuffer(_ buffer: MetalBuffer, index: Int) {
        let data = buffer.asData as NSData
        if data.length <= 4096 {
            setFragmentBytes(data.bytes, length: data.length, index: index)
        } else {
            let buffer = MetalDevice.device.makeBuffer(bytes: data.bytes, length: data.length, options: [])!
            setFragmentBuffer(buffer, offset: 0, index: index)
        }
    }
    
    func setFragmentBuffers(_ buffers: [MetalBuffer]) {
        for (i, buffer) in buffers.izip {
            setFragmentBuffer(buffer, index: i)
        }
    }
    
    func setFragmentTextures(_ textures: [MTLTexture]) {
        setFragmentTextures(textures, range: 0..<textures.count)
    }
    
}

extension Array {
    
    var izip: Zip2Sequence<Range<Int>, [Element]> {
        let ints = 0..<count
        return zip(ints, self)
    }
    
}

//var MetalPassSaveOutputs: Bool = false
//var MetalPassSaveCount: Int = 0
//
//func MetalPassSave<T>(_ pass: MetalPass<T>) {
//    for texture in pass.fragmentTextures {
//        MetalPassSaveTexture(texture)
//    }
//}
//
//func MetalPassSaveTexture(_ texture: MTLTexture) {
//    let count = MetalPassSaveCount
//    MetalPassSaveCount += 1
//    let url = "~/Documents/MetalPass\(count).png".fileURL
//
//    let data = texture.uiImage.pngData()!
//    try! data.write(to: url)
//
//    print("saved to \(url)")
//}

public extension String {
    
    var standardizingPath: String {
        return (self as NSString).standardizingPath
    }
    
    var fileURL: URL {
        return URL(fileURLWithPath: standardizingPath)
    }
    
}
