//
//  MockTexture.swift
//  CanvasBase
//
//  Created by Greg Fajen on 12/28/19.
//

import Metal
@testable import MuzeMetal
// swiftlint:disable all

extension MetalTexture {
    
    static var mock: MetalTexture {
        return MetalTexture(MockTexture())
    }
    
}

class MockTexture: NSObject, MTLTexture {
    
    #if os(macOS)
    var remoteStorageTexture: MTLTexture? { fatalError() }
    
    func makeRemoteTextureView(_ device: MTLDevice) -> MTLTexture? {
        fatalError()
    }
    #endif
    
    
    #if targetEnvironment(simulator)
    
    #else
    @available(iOS 13.0, *)
    func makeSharedTextureHandle() -> MTLSharedTextureHandle? {
        fatalError()
    }
    #endif
    
    var isShareable: Bool { fatalError() }
    
    var firstMipmapInTail: Int { fatalError() }
    
    var tailSizeInBytes: Int { fatalError() }
    
    var isSparse: Bool { fatalError() }
    
    @available(OSX 10.15, *)
    @available(iOS 13.0, *)
    var swizzle: MTLTextureSwizzleChannels { fatalError() }
    
    @available(OSX 10.15, *)
    @available(iOS 13.0, *)
    func __newTextureView(with pixelFormat: MTLPixelFormat, textureType: MTLTextureType, levels levelRange: NSRange, slices sliceRange: NSRange, swizzle: MTLTextureSwizzleChannels) -> MTLTexture? {
        fatalError()
    }
    
    @available(OSX 10.15, *)
    @available(iOS 13.0, *)
    var hazardTrackingMode: MTLHazardTrackingMode { fatalError()}
    
    var resourceOptions: MTLResourceOptions { fatalError() }
    
    var heapOffset: Int { fatalError() }
    
    var iosurface: IOSurfaceRef? = nil
    var iosurfacePlane: Int = 0
    
    var width: Int
    var height: Int
    
    convenience init(_ size: CGSize) {
        self.init(width: Int(size.width), height: Int(size.height))
    }
    
    init(width: Int = 8, height: Int = 8) {
        self.width = width
        self.height = height
        super.init()
    }
    
    func makeTextureView(pixelFormat: MTLPixelFormat) -> MTLTexture? {
        return nil
    }
    
    var label: String? = nil
    
    var rootResource: MTLResource? { return nil }
    
    var parent: MTLTexture? { return nil }
    
    var parentRelativeLevel: Int { return 0 }
    
    var parentRelativeSlice: Int { return 0 }
    
    var buffer: MTLBuffer? { return nil }
    
    var bufferOffset: Int { return 0 }
    
    var bufferBytesPerRow: Int { return 0 }
    
    var textureType: MTLTextureType { return .type1D }
    
    var pixelFormat: MTLPixelFormat { return .a8Unorm }
    
    var depth: Int { return 0 }
    
    var mipmapLevelCount: Int { return 0 }
    
    var sampleCount: Int { return 0 }
    
    var arrayLength: Int { return 0 }
    
    var usage: MTLTextureUsage { return [] }
    
    var isFramebufferOnly: Bool { return false }
    
    var allowGPUOptimizedContents: Bool { return false }
    
    func getBytes(_ pixelBytes: UnsafeMutableRawPointer, bytesPerRow: Int, bytesPerImage: Int, from region: MTLRegion, mipmapLevel level: Int, slice: Int) {
        
    }
    
    func replace(region: MTLRegion, mipmapLevel level: Int, slice: Int, withBytes pixelBytes: UnsafeRawPointer, bytesPerRow: Int, bytesPerImage: Int) {
        
    }
    
    func getBytes(_ pixelBytes: UnsafeMutableRawPointer, bytesPerRow: Int, from region: MTLRegion, mipmapLevel level: Int) {
        
    }
    
    func replace(region: MTLRegion, mipmapLevel level: Int, withBytes pixelBytes: UnsafeRawPointer, bytesPerRow: Int) {
        
    }
    
    func __newTextureView(with pixelFormat: MTLPixelFormat, textureType: MTLTextureType, levels levelRange: NSRange, slices sliceRange: NSRange) -> MTLTexture? {
        return nil
    }
    
    var device: MTLDevice { return MetalDevice.device }
    
    var cpuCacheMode: MTLCPUCacheMode { return .defaultCache }
    
    var storageMode: MTLStorageMode { return .shared }
    
    func setPurgeableState(_ state: MTLPurgeableState) -> MTLPurgeableState {
        return .empty
    }
    
    var heap: MTLHeap? { return nil }
    
    var allocatedSize: Int { return 0 }
    
    func makeAliasable() {
        
    }
    
    func isAliasable() -> Bool {
        return false
    }
    
    
}
