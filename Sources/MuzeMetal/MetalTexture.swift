//
//  MetalTexture.swift
//  muze
//
//  Created by Greg Fajen on 5/14/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Metal
import MuzePrelude

#if os(macOS)
import AppKit
#else
import UIKit
#endif

public class MetalTexture: Equatable {
    
    public var _texture: MTLTexture
    public weak var heap: MetalHeap?
    public private(set) var isAliasable = false
    public var isInUseByRenderer = false
    
    public var identifier: String? {
        get { return _texture.label}
        set { _texture.label = newValue }
    }
    
    public var colorSpace: RenderOptions.ColorSpace? = nil {
        didSet {
            if let old = oldValue {
                if let new = colorSpace {
                    if new != old {
                        fatalError("can't change an associated color space")
                    }
                } else {
                    fatalError("can't replace an associated color space with nil")
                }
            }
        }
    }
    
    public var timeStamp: TimeInterval?
    
    public var isLinear: Bool {
        return RenderOptions.PixelFormat(rawValue: pixelFormat)!.isLinear
    }
    
    func assertColorSpaceExists() {
        if !colorSpace.exists {
            fatalError("no associated color space")
        }
    }
    
    var _fence: MTLFence?
    var fence: MTLFence {
        if let fence = _fence { return fence }
        _fence = MetalDevice.device.makeFence()
        return _fence!
    }
    
    public init(_ texture: MTLTexture, heap: MetalHeap? = nil) {
        _texture = texture
        self.heap = heap
    }
    
    var bytesNeeded: Int = 0
    
    #if os(iOS)
    public var uiImage: UIImage {
        return _texture.uiImage
    }
    #endif
    
    public static func == (lhs: MetalTexture, rhs: MetalTexture) -> Bool {
        return lhs === rhs
    }
    
    public var pixelFormat: MTLPixelFormat {
        return _texture.pixelFormat
    }
    
    public var size: CGSize {
        return _texture.size
    }
    
//    var memoryHash: MemoryHash {
//        return _texture.memoryHash
//    }
    
    public var memorySize: MemorySize {
        return _texture.memorySize
    }
    
    public var texture: MetalTexture {
        return self
    }
    
    public var pointerString: String {
        let unsafe = Unmanaged.passUnretained(self).toOpaque()
        return "\(unsafe)"
    }
    
    public var needsClear: Bool = true
    
    func blit(to texture: MetalTexture) {
        let source = self._texture
        let target = texture._texture
        
        let commandBuffer = MetalDevice.commandQueue.makeCommandBuffer()!
        let encoder = commandBuffer.makeBlitCommandEncoder()!
        
        encoder.waitForFence(fence)
        encoder.waitForFence(texture.fence)
        
        encoder.copy(from: source, sourceSlice: 0, sourceLevel: 0, sourceOrigin: .zero, sourceSize: MTLSize(size),
                     to: target, destinationSlice: 0, destinationLevel: 0, destinationOrigin: .zero)
        
        encoder.updateFence(fence)
        encoder.updateFence(texture.fence)
        
        encoder.endEncoding()
        
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }
    
    public func makeAliasable() {
        assert(!isAliasable)
        isAliasable = true
        
        heap?.forget(self)
        _texture.makeAliasable()
    }
    
    var usage: MTLTextureUsage {
        return _texture.usage
    }
    
    public func clear() {
        let desc = MTLRenderPassDescriptor()
        let attachment = desc.colorAttachments[0]!
        attachment.texture = texture._texture
        attachment.clearColor = MTLClearColorMake(0, 0, 0, 0)
        attachment.loadAction = .clear
        
        let commandBuffer = MetalDevice.commandQueue.makeCommandBuffer()!
        let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: desc)
        
        encoder?.endEncoding()
        commandBuffer.commit()
    }
    
}

// temporary
extension MetalTexture: SimpleMetalDrawable {
    
    #if targetEnvironment(simulator)
    
    #else
    public var drawable: CAMetalDrawable? {
        return nil
    }
    #endif
    
    public var renderPassDescriptor: MTLRenderPassDescriptor? {
        return nil
    }

}

public extension MTLOrigin {
    
    static let zero = MTLOrigin(x: 0, y: 0, z: 0)
    
}

public extension MTLTexture {
    
    var size: CGSize {
        return CGSize(width: width, height: height)
    }
    
    var bounds: CGRect {
        return CGRect(origin: .zero, size: size)
    }
    
}

extension MetalTexture: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(pointerString)
    }
    
}

public extension MetalTexture {
    
    var width: Int { return Int(size.width) }
    var height: Int { return Int(size.height) }
    
}
