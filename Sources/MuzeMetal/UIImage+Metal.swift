//
//  UIImage+Metal.swift
//  muze
//
//  Created by Greg on 12/28/18.
//  Copyright © 2018 Ergo Sum. All rights reserved.
//

#if !os(macOS)

import UIKit
import Metal
import MetalKit

public extension MTLTexture {
    
    var drawingContext: DrawingContext {
        let sixteen: Bool
        let bgra: Bool
        switch pixelFormat {
            case .rgba8Unorm:
                sixteen = false
                bgra = false
            case .bgra8Unorm:
                sixteen = false
                bgra = true
            case .rgba16Unorm:
                sixteen = true
                bgra = false
        //        case .bgra16Unorm:
        //            sixteen = true
        //            bgra = true
            case .bgra8Unorm_srgb:
                sixteen = false
                bgra = true
            default:
                fatalError("unable to create drawing context from pixel format \(pixelFormat)")
        }
        
        let region = MTLRegionMake2D(0, 0, width, height)
        let context = DrawingContext(width: width, height: height, bgra: bgra, sixteen: sixteen)
        getBytes(context.data, bytesPerRow: context.stride, from: region, mipmapLevel: 0)
        
        return context
    }
    
    var cgImage: CGImage {
        return drawingContext.cgImage
    }
    
    var uiImage: UIImage {
        return UIImage(cgImage: cgImage)
    }
    
}

public extension UIImage {
    
    @available(*, deprecated)
    var texture: MTLTexture {
        let context = DrawingContext(image: self, bgra: true)
        let texture = context.cgImage.texture

//        print("created texture with format \(texture.pixelFormat)")
//        if texture.pixelFormat == .rgba16Unorm {
//            print("oops..")
//        }
        
        return texture
    }
    
}

public extension CGImage {
    
    @available(*, deprecated)
    var texture: MTLTexture {
//        MetalDevice.device.makeTexture(descriptor: <#T##MTLTextureDescriptor#>)
        
        let loader = MTKTextureLoader(device: MetalDevice.device)
        let texture = try! loader.newTexture(cgImage: self, options: nil)

        if texture.pixelFormat == .rgba16Unorm {
            print("oops..")
        }
        return texture
    }
    
}

public extension CGBitmapInfo {
    
    init(_ alphaInfo: CGImageAlphaInfo) {
        self.init(rawValue: alphaInfo.rawValue)
    }
    
}

extension MTLPixelFormat: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        switch self {
            case .invalid: return "MTLPixelFormat.invalid"
            case .a8Unorm: return "MTLPixelFormat.a8Unorm"
            case .r8Unorm: return "MTLPixelFormat.r8Unorm"
            case .r8Unorm_srgb: return "MTLPixelFormat.r8Unorm_srgb"
            case .r8Snorm: return "MTLPixelFormat.r8Snorm"
            case .r8Uint: return "MTLPixelFormat.r8Uint"
            case .r8Sint: return "MTLPixelFormat.r8Sint"
            case .r16Unorm: return "MTLPixelFormat.r16Unorm"
            case .r16Snorm: return "MTLPixelFormat.r16Snorm"
            case .r16Uint: return "MTLPixelFormat.r16Uint"
            case .r16Sint: return "MTLPixelFormat.r16Sint"
            case .r16Float: return "MTLPixelFormat.r16Float"
            case .rg8Unorm: return "MTLPixelFormat.rg8Unorm"
            case .rg8Unorm_srgb: return "MTLPixelFormat.rg8Unorm_srgb"
            case .rg8Snorm: return "MTLPixelFormat.rg8Snorm"
            case .rg8Uint: return "MTLPixelFormat.rg8Uint"
            case .rg8Sint: return "MTLPixelFormat.rg8Sint"
            case .b5g6r5Unorm: return "MTLPixelFormat.b5g6r5Unorm"
            case .a1bgr5Unorm: return "MTLPixelFormat.a1bgr5Unorm"
            case .abgr4Unorm: return "MTLPixelFormat.abgr4Unorm"
            case .bgr5A1Unorm: return "MTLPixelFormat.bgr5A1Unorm"
            case .r32Uint: return "MTLPixelFormat.r32Uint"
            case .r32Sint: return "MTLPixelFormat.r32Sint"
            case .r32Float: return "MTLPixelFormat.r32Float"
            case .rg16Unorm: return "MTLPixelFormat.rg16Unorm"
            case .rg16Snorm: return "MTLPixelFormat.rg16Snorm"
            case .rg16Uint: return "MTLPixelFormat.rg16Uint"
            case .rg16Sint: return "MTLPixelFormat.rg16Sint"
            case .rg16Float: return "MTLPixelFormat.rg16Float"
            case .rgba8Unorm: return "MTLPixelFormat.rgba8Unorm"
            case .rgba8Unorm_srgb: return "MTLPixelFormat.rgba8Unorm_srgb"
            case .rgba8Snorm: return "MTLPixelFormat.rgba8Snorm"
            case .rgba8Uint: return "MTLPixelFormat.rgba8Uint"
            case .rgba8Sint: return "MTLPixelFormat.rgba8Sint"
            case .bgra8Unorm: return "MTLPixelFormat.bgra8Unorm"
            case .bgra8Unorm_srgb: return "MTLPixelFormat.bgra8Unorm_srgb"
            case .rgb10a2Unorm: return "MTLPixelFormat.rgb10a2Unorm"
            case .rgb10a2Uint: return "MTLPixelFormat.rgb10a2Uint"
            case .rg11b10Float: return "MTLPixelFormat.rg11b10Float"
            case .rgb9e5Float: return "MTLPixelFormat.rgb9e5Float"
            case .bgr10a2Unorm: return "MTLPixelFormat.bgr10a2Unorm"
            case .bgr10_xr: return "MTLPixelFormat.bgr10_xr"
            case .bgr10_xr_srgb: return "MTLPixelFormat.bgr10_xr_srgb"
            case .rg32Uint: return "MTLPixelFormat.rg32Uint"
            case .rg32Sint: return "MTLPixelFormat.rg32Sint"
            case .rg32Float: return "MTLPixelFormat.rg32Float"
            case .rgba16Unorm: return "MTLPixelFormat.rgba16Unorm"
            case .rgba16Snorm: return "MTLPixelFormat.rgba16Snorm"
            case .rgba16Uint: return "MTLPixelFormat.rgba16Uint"
            case .rgba16Sint: return "MTLPixelFormat.rgba16Sint"
            case .rgba16Float: return "MTLPixelFormat.rgba16Float"
            case .bgra10_xr: return "MTLPixelFormat.bgra10_xr"
            case .bgra10_xr_srgb: return "MTLPixelFormat.bgra10_xr_srgb"
            case .rgba32Uint: return "MTLPixelFormat.rgba32Uint"
            case .rgba32Sint: return "MTLPixelFormat.rgba32Sint"
            case .rgba32Float: return "MTLPixelFormat.rgba32Float"
            case .pvrtc_rgb_2bpp: return "MTLPixelFormat.pvrtc_rgb_2bpp"
            case .pvrtc_rgb_2bpp_srgb: return "MTLPixelFormat.pvrtc_rgb_2bpp_srgb"
            case .pvrtc_rgb_4bpp: return "MTLPixelFormat.pvrtc_rgb_4bpp"
            case .pvrtc_rgb_4bpp_srgb: return "MTLPixelFormat.pvrtc_rgb_4bpp_srgb"
            case .pvrtc_rgba_2bpp: return "MTLPixelFormat.pvrtc_rgba_2bpp"
            case .pvrtc_rgba_2bpp_srgb: return "MTLPixelFormat.pvrtc_rgba_2bpp_srgb"
            case .pvrtc_rgba_4bpp: return "MTLPixelFormat.pvrtc_rgba_4bpp"
            case .pvrtc_rgba_4bpp_srgb: return "MTLPixelFormat.pvrtc_rgba_4bpp_srgb"
            case .eac_r11Unorm: return "MTLPixelFormat.eac_r11Unorm"
            case .eac_r11Snorm: return "MTLPixelFormat.eac_r11Snorm"
            case .eac_rg11Unorm: return "MTLPixelFormat.eac_rg11Unorm"
            case .eac_rg11Snorm: return "MTLPixelFormat.eac_rg11Snorm"
            case .eac_rgba8: return "MTLPixelFormat.eac_rgba8"
            case .eac_rgba8_srgb: return "MTLPixelFormat.eac_rgba8_srgb"
            case .etc2_rgb8: return "MTLPixelFormat.etc2_rgb8"
            case .etc2_rgb8_srgb: return "MTLPixelFormat.etc2_rgb8_srgb"
            case .etc2_rgb8a1: return "MTLPixelFormat.etc2_rgb8a1"
            case .etc2_rgb8a1_srgb: return "MTLPixelFormat.etc2_rgb8a1_srgb"
            case .astc_4x4_srgb: return "MTLPixelFormat.astc_4x4_srgb"
            case .astc_5x4_srgb: return "MTLPixelFormat.astc_5x4_srgb"
            case .astc_5x5_srgb: return "MTLPixelFormat.astc_5x5_srgb"
            case .astc_6x5_srgb: return "MTLPixelFormat.astc_6x5_srgb"
            case .astc_6x6_srgb: return "MTLPixelFormat.astc_6x6_srgb"
            case .astc_8x5_srgb: return "MTLPixelFormat.astc_8x5_srgb"
            case .astc_8x6_srgb: return "MTLPixelFormat.astc_8x6_srgb"
            case .astc_8x8_srgb: return "MTLPixelFormat.astc_8x8_srgb"
            case .astc_10x5_srgb: return "MTLPixelFormat.astc_10x5_srgb"
            case .astc_10x6_srgb: return "MTLPixelFormat.astc_10x6_srgb"
            case .astc_10x8_srgb: return "MTLPixelFormat.astc_10x8_srgb"
            case .astc_10x10_srgb: return "MTLPixelFormat.astc_10x10_srgb"
            case .astc_12x10_srgb: return "MTLPixelFormat.astc_12x10_srgb"
            case .astc_12x12_srgb: return "MTLPixelFormat.astc_12x12_srgb"
            case .astc_4x4_ldr: return "MTLPixelFormat.astc_4x4_ldr"
            case .astc_5x4_ldr: return "MTLPixelFormat.astc_5x4_ldr"
            case .astc_5x5_ldr: return "MTLPixelFormat.astc_5x5_ldr"
            case .astc_6x5_ldr: return "MTLPixelFormat.astc_6x5_ldr"
            case .astc_6x6_ldr: return "MTLPixelFormat.astc_6x6_ldr"
            case .astc_8x5_ldr: return "MTLPixelFormat.astc_8x5_ldr"
            case .astc_8x6_ldr: return "MTLPixelFormat.astc_8x6_ldr"
            case .astc_8x8_ldr: return "MTLPixelFormat.astc_8x8_ldr"
            case .astc_10x5_ldr: return "MTLPixelFormat.astc_10x5_ldr"
            case .astc_10x6_ldr: return "MTLPixelFormat.astc_10x6_ldr"
            case .astc_10x8_ldr: return "MTLPixelFormat.astc_10x8_ldr"
            case .astc_10x10_ldr: return "MTLPixelFormat.astc_10x10_ldr"
            case .astc_12x10_ldr: return "MTLPixelFormat.astc_12x10_ldr"
            case .astc_12x12_ldr: return "MTLPixelFormat.astc_12x12_ldr"
                 
            case .gbgr422: return "MTLPixelFormat.gbgr422"
            case .bgrg422: return "MTLPixelFormat.bgrg422"
            case .depth32Float: return "MTLPixelFormat.depth32Float"
            case .stencil8: return "MTLPixelFormat.stencil8"
            case .depth32Float_stencil8: return "MTLPixelFormat.depth32Float_stencil8"
            case .x32_stencil8: return "MTLPixelFormat.x32_stencil8"
                
            case .astc_4x4_hdr: return "MTLPixelFormat.astc_4x4_hdr"
            case .astc_5x4_hdr: return "MTLPixelFormat.astc_5x4_hdr"
            case .astc_6x5_hdr: return "MTLPixelFormat.astc_6x5_hdr"
            case .astc_8x5_hdr: return "MTLPixelFormat.astc_8x5_hdr"
            case .astc_8x6_hdr: return "MTLPixelFormat.astc_8x6_hdr"
            case .astc_8x8_hdr: return "MTLPixelFormat.astc_8x8_hdr"
            case .astc_10x5_hdr: return "MTLPixelFormat.astc_10x5_hdr"
            case .astc_10x6_hdr: return "MTLPixelFormat.astc_10x6_hdr"
            case .astc_10x8_hdr: return "MTLPixelFormat.astc_10x8_hdr"
            case .astc_10x10_hdr: return "MTLPixelFormat.astc_10x10_hdr"
            case .astc_12x10_hdr: return "MTLPixelFormat.astc_12x10_hdr"
            case .astc_12x12_hdr: return "MTLPixelFormat.astc_12x12_hdr"
            case .astc_5x6_hdr: return "MTLPixelFormat.astc_5x6_hdr"
            case .depth16Unorm: return "MTLPixelFormat.depth16Unorm"
                
            @unknown default:
                return "MTLPixelFromat.unknown"
        }
    }
    
}

#endif
