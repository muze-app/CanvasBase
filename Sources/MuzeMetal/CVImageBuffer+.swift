//
//  CVImageBuffer+.swift
//  MuzePrelude
//
//  Created by Greg Fajen on 12/23/19.
//

import Foundation
import Metal
import AVKit

extension CVImageBuffer {
    
    struct Dimensions: CustomDebugStringConvertible {
        
        let width: Int
        let height: Int
        let stride: Int
        
        var length: Int {
            return height * stride
        }
        
        var debugDescription: String {
            //            return "\(width)x\(height) (\(MemorySize(stride)) / row)"
            return "\(width)x\(height) (\(stride)) (\(MemorySize(stride*height)))"
        }
        
    }
    
    static func DegreesToRadians(_ degrees: CGFloat) -> CGFloat { return CGFloat( (degrees * .pi) / 180 ) }
    
    var pixelFormat: OSType {
        return CVPixelBufferGetPixelFormatType(self)
    }
    
    var width: Int {
        return CVPixelBufferGetWidth(self)
    }
    
    var height: Int {
        return CVPixelBufferGetHeight(self)
    }
    
    var cgBitmapInfo: CGBitmapInfo? {
        switch pixelFormat {
            case kCVPixelFormatType_32ARGB:
                return [.byteOrder32Big, CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipFirst.rawValue)]
            case kCVPixelFormatType_32BGRA:
                return [.byteOrder32Little, CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipFirst.rawValue)]
            
            default:
                print("wrong pixel format: \(pixelFormat)")
                return nil
        }
    }
    
    func dimensions(forPlane planeIndex: Int) -> Dimensions {
        let w = CVPixelBufferGetWidthOfPlane(self, planeIndex)
        let h = CVPixelBufferGetHeightOfPlane(self, planeIndex)
        let s = CVPixelBufferGetBytesPerRowOfPlane(self, planeIndex)
        return Dimensions(width: w, height: h, stride: s)
    }
    
    @discardableResult
    func lockPlane(_ planeIndex: Int, for block: ((UnsafeMutableRawPointer)->())) -> Bool {
        let flags = CVPixelBufferLockFlags.readOnly //CVPixelBufferLockFlags(rawValue: 0)
        let result = CVPixelBufferLockBaseAddress(self, flags)
        if result != kCVReturnSuccess {
            return false
        }
        
        guard let address = CVPixelBufferGetBaseAddressOfPlane(self, planeIndex) else {
            return false
        }
        
        block(address)
        
        CVPixelBufferUnlockBaseAddress(self, flags)
        return true
    }
    
    func lockBase(for block: ((UnsafeMutableRawPointer)->())) -> Bool {
        let flags = CVPixelBufferLockFlags(rawValue: 0)
        let result = CVPixelBufferLockBaseAddress(self, flags)
        if result != kCVReturnSuccess {
            return false
        }
        
        guard let address = CVPixelBufferGetBaseAddress(self) else {
            return false
        }
        
        block(address)
        
        CVPixelBufferUnlockBaseAddress(self, flags)
        return true
    }
    
    var cgImage: CGImage? {
        guard let bitmapInfo = cgBitmapInfo else {
            return nil
        }
        
        let stride = CVPixelBufferGetBytesPerRow(self)
        let width = CVPixelBufferGetWidth(self)
        let height = CVPixelBufferGetHeight(self)
        
        var image: CGImage?
        
        _ = lockBase { (address) in
            guard let provider = CGDataProvider(dataInfo: nil,
                                                data: address,
                                                size: stride * height,
                                                releaseData: {_,_,_ in }) else {
                                                    return
            }
            
            let space = CGColorSpaceCreateDeviceRGB()
            image = CGImage(width: width,
                            height: height,
                            bitsPerComponent: 8,
                            bitsPerPixel: 32,
                            bytesPerRow: stride,
                            space: space,
                            bitmapInfo: bitmapInfo,
                            provider: provider,
                            decode: nil,
                            shouldInterpolate: true,
                            intent: .defaultIntent)
        }
        
        return image
    }
    
    @available(*, deprecated)
    public var texture: MTLTexture {
        #if targetEnvironment(simulator)
        fatalError()
        #else
        let device = MetalOffscreenDrawable.device
        var textureCache: CVMetalTextureCache?
        CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, device, nil, &textureCache)
        
        var texture: CVMetalTexture?
        CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCache!, self, nil, .bgra8Unorm, width, height, 0, &texture)
        
        return CVMetalTextureGetTexture(texture!)!
        #endif
    }
    
}

extension CVImageBuffer {
    
    var pixelFormatString: String {
        return "'\(pixelFormat)' \(pixelFormatString2)"
    }
    
    var pixelFormatString2: String {
        switch pixelFormat {
            case kCVPixelFormatType_1Monochrome: return  "1Monochrome"
            case kCVPixelFormatType_2Indexed: return  "2Indexed"
            case kCVPixelFormatType_4Indexed: return  "4Indexed"
            case kCVPixelFormatType_8Indexed: return  "8Indexed"
            case kCVPixelFormatType_1IndexedGray_WhiteIsZero: return  "1IndexedGray_WhiteIsZero"
            case kCVPixelFormatType_2IndexedGray_WhiteIsZero: return  "2IndexedGray_WhiteIsZero"
            case kCVPixelFormatType_4IndexedGray_WhiteIsZero: return  "4IndexedGray_WhiteIsZero"
            case kCVPixelFormatType_8IndexedGray_WhiteIsZero: return  "8IndexedGray_WhiteIsZero"
            case kCVPixelFormatType_16BE555: return  "16BE555"
            case kCVPixelFormatType_16LE555: return  "16LE555"
            case kCVPixelFormatType_16LE5551: return  "16LE5551"
            case kCVPixelFormatType_16BE565: return  "16BE565"
            case kCVPixelFormatType_16LE565: return  "16LE565"
            case kCVPixelFormatType_24RGB: return  "24RGB"
            case kCVPixelFormatType_24BGR: return  "24BGR"
            case kCVPixelFormatType_32ARGB: return  "32ARGB"
            case kCVPixelFormatType_32BGRA: return  "32BGRA"
            case kCVPixelFormatType_32ABGR: return  "32ABGR"
            case kCVPixelFormatType_32RGBA: return  "32RGBA"
            case kCVPixelFormatType_64ARGB: return  "64ARGB"
            case kCVPixelFormatType_48RGB: return  "48RGB"
            case kCVPixelFormatType_32AlphaGray: return  "32AlphaGray"
            case kCVPixelFormatType_16Gray: return  "16Gray"
            case kCVPixelFormatType_30RGB: return  "30RGB"
            case kCVPixelFormatType_422YpCbCr8: return  "422YpCbCr8"
            case kCVPixelFormatType_4444YpCbCrA8: return  "4444YpCbCrA8"
            case kCVPixelFormatType_4444YpCbCrA8R: return  "4444YpCbCrA8R"
            case kCVPixelFormatType_4444AYpCbCr8: return  "4444AYpCbCr8"
            case kCVPixelFormatType_4444AYpCbCr16: return  "4444AYpCbCr16"
            case kCVPixelFormatType_444YpCbCr8: return  "444YpCbCr8"
            case kCVPixelFormatType_422YpCbCr16: return  "422YpCbCr16"
            case kCVPixelFormatType_422YpCbCr10: return  "422YpCbCr10"
            case kCVPixelFormatType_444YpCbCr10: return  "444YpCbCr10"
            case kCVPixelFormatType_420YpCbCr8Planar: return  "420YpCbCr8Planar"
            case kCVPixelFormatType_420YpCbCr8PlanarFullRange: return  "420YpCbCr8PlanarFullRange"
            case kCVPixelFormatType_422YpCbCr_4A_8BiPlanar: return  "422YpCbCr_4A_8BiPlanar"
            case kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange: return  "420YpCbCr8BiPlanarVideoRange"
            case kCVPixelFormatType_420YpCbCr8BiPlanarFullRange: return  "420YpCbCr8BiPlanarFullRange"
            case kCVPixelFormatType_422YpCbCr8_yuvs: return  "422YpCbCr8_yuvs"
            case kCVPixelFormatType_422YpCbCr8FullRange: return  "422YpCbCr8FullRange"
            case kCVPixelFormatType_OneComponent8: return  "OneComponent8"
            case kCVPixelFormatType_TwoComponent8: return  "TwoComponent8"
            case kCVPixelFormatType_30RGBLEPackedWideGamut: return  "30RGBLEPackedWideGamut"
            case kCVPixelFormatType_ARGB2101010LEPacked: return  "ARGB2101010LEPacked"
            case kCVPixelFormatType_OneComponent16Half: return  "OneComponent16Half"
            case kCVPixelFormatType_OneComponent32Float: return  "OneComponent32Float"
            case kCVPixelFormatType_TwoComponent16Half: return  "TwoComponent16Half"
            case kCVPixelFormatType_TwoComponent32Float: return  "TwoComponent32Float"
            case kCVPixelFormatType_64RGBAHalf: return  "64RGBAHalf"
            case kCVPixelFormatType_128RGBAFloat: return  "128RGBAFloat"
            case kCVPixelFormatType_14Bayer_GRBG: return  "14Bayer_GRBG"
            case kCVPixelFormatType_14Bayer_RGGB: return  "14Bayer_RGGB"
            case kCVPixelFormatType_14Bayer_BGGR: return  "14Bayer_BGGR"
            case kCVPixelFormatType_14Bayer_GBRG: return  "14Bayer_GBRG"
            case kCVPixelFormatType_DisparityFloat16: return  "DisparityFloat16"
            case kCVPixelFormatType_DisparityFloat32: return  "DisparityFloat32"
            case kCVPixelFormatType_DepthFloat16: return  "DepthFloat16"
            case kCVPixelFormatType_DepthFloat32: return  "DepthFloat32"
            case kCVPixelFormatType_420YpCbCr10BiPlanarVideoRange: return  "420YpCbCr10BiPlanarVideoRange"
            case kCVPixelFormatType_422YpCbCr10BiPlanarVideoRange: return  "422YpCbCr10BiPlanarVideoRange"
            case kCVPixelFormatType_444YpCbCr10BiPlanarVideoRange: return  "444YpCbCr10BiPlanarVideoRange"
            case kCVPixelFormatType_420YpCbCr10BiPlanarFullRange: return  "420YpCbCr10BiPlanarFullRange"
            case kCVPixelFormatType_422YpCbCr10BiPlanarFullRange: return  "422YpCbCr10BiPlanarFullRange"
            case kCVPixelFormatType_444YpCbCr10BiPlanarFullRange: return  "444YpCbCr10BiPlanarFullRange"
            default: fatalError()
        }
    }
    
}
