//
//  MockTexture.swift
//  CanvasBase
//
//  Created by Greg Fajen on 12/28/19.
//

import Metal
import MuzePrelude
// swiftlint:disable all

public extension MetalTexture {
    
    static var mock: MetalTexture {
        return MetalTexture(MockTexture())
    }
    
}

public class MockTexture: NSObject, MTLTexture {
    
    #if os(macOS)
    public var remoteStorageTexture: MTLTexture? { fatalError() }
    
    public func makeRemoteTextureView(_ device: MTLDevice) -> MTLTexture? {
        fatalError()
    }
    #endif
    
    
    #if targetEnvironment(simulator)
    
    #else
    @available(iOS 13.0, *)
    public func makeSharedTextureHandle() -> MTLSharedTextureHandle? {
        fatalError()
    }
    #endif
    
    public var isShareable: Bool { fatalError() }
    
    public var firstMipmapInTail: Int { fatalError() }
    
    public var tailSizeInBytes: Int { fatalError() }
    
    public var isSparse: Bool { fatalError() }
    
    @available(OSX 10.15, *)
    @available(iOS 13.0, *)
    public var swizzle: MTLTextureSwizzleChannels { fatalError() }
    
    @available(OSX 10.15, *)
    @available(iOS 13.0, *)
    public func __newTextureView(with pixelFormat: MTLPixelFormat, textureType: MTLTextureType, levels levelRange: NSRange, slices sliceRange: NSRange, swizzle: MTLTextureSwizzleChannels) -> MTLTexture? {
        fatalError()
    }
    
    @available(OSX 10.15, *)
    @available(iOS 13.0, *)
    public var hazardTrackingMode: MTLHazardTrackingMode { fatalError()}
    
    public var resourceOptions: MTLResourceOptions { fatalError() }
    
    public var heapOffset: Int { fatalError() }
    
    public var iosurface: IOSurfaceRef? = nil
    public var iosurfacePlane: Int = 0
    
    public var width: Int
    public var height: Int
    
    convenience init(_ size: CGSize) {
        self.init(width: Int(size.width), height: Int(size.height))
    }
    
    init(width: Int = 828, height: Int = 1260) {
        self.width = width
        self.height = height
        super.init()
    }
    
    public func makeTextureView(pixelFormat: MTLPixelFormat) -> MTLTexture? {
        return nil
    }
    
    public var label: String? = nil
    
    public var rootResource: MTLResource? { return nil }
    
    public var parent: MTLTexture? { return nil }
    
    public var parentRelativeLevel: Int { return 0 }
    
    public var parentRelativeSlice: Int { return 0 }
    
    public var buffer: MTLBuffer? { return nil }
    
    public var bufferOffset: Int { return 0 }
    
    public var bufferBytesPerRow: Int { return 0 }
    
    public var textureType: MTLTextureType { return .type1D }
    
    public var pixelFormat: MTLPixelFormat { return .a8Unorm }
    
    public var depth: Int { return 0 }
    
    public var mipmapLevelCount: Int { return 0 }
    
    public var sampleCount: Int { return 0 }
    
    public var arrayLength: Int { return 0 }
    
    public var usage: MTLTextureUsage { return [] }
    
    public var isFramebufferOnly: Bool { return false }
    
    public var allowGPUOptimizedContents: Bool { return false }
    
    public func getBytes(_ pixelBytes: UnsafeMutableRawPointer, bytesPerRow: Int, bytesPerImage: Int, from region: MTLRegion, mipmapLevel level: Int, slice: Int) {
        
    }
    
    public func replace(region: MTLRegion, mipmapLevel level: Int, slice: Int, withBytes pixelBytes: UnsafeRawPointer, bytesPerRow: Int, bytesPerImage: Int) {
        
    }
    
    public func getBytes(_ pixelBytes: UnsafeMutableRawPointer, bytesPerRow: Int, from region: MTLRegion, mipmapLevel level: Int) {
        
    }
    
    public func replace(region: MTLRegion, mipmapLevel level: Int, withBytes pixelBytes: UnsafeRawPointer, bytesPerRow: Int) {
        
    }
    
    public func __newTextureView(with pixelFormat: MTLPixelFormat, textureType: MTLTextureType, levels levelRange: NSRange, slices sliceRange: NSRange) -> MTLTexture? {
        return nil
    }
    
    public var device: MTLDevice { return MetalDevice.device }
    
    public var cpuCacheMode: MTLCPUCacheMode { return .defaultCache }
    
    public var storageMode: MTLStorageMode { return .shared }
    
    public func setPurgeableState(_ state: MTLPurgeableState) -> MTLPurgeableState {
        return .empty
    }
    
    public var heap: MTLHeap? { return nil }
    
    public var allocatedSize: Int { return 0 }
    
    public func makeAliasable() {
        
    }
    
    public func isAliasable() -> Bool {
        return false
    }
    
    
}
