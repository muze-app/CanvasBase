//
//  RenderOptions.swift
//  muze
//
//  Created by Greg on 2/9/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import UIKit
import Metal

public struct RenderOptions {
    
    let identifier: String
    let mode: Mode
    let outputFormat: PixelFormat
    let time: TimeInterval
    
    init(_ identifier: String, mode: Mode, format: PixelFormat, time: TimeInterval) {
        self.identifier = identifier
        self.mode = mode
        self.outputFormat = format
        self.time = time
//        if !UIDevice.current.isX {
//            assert(outputFormat != .extended)
//        }
    }
    
    init(_ identifier: String, size: CGSize, format: PixelFormat, time: TimeInterval) {
        self.identifier = identifier
        self.mode = .normalized(size)
        self.outputFormat = format
        self.time = time
        //if !UIDevice.current.isX {
        //    assert(outputFormat != .extended)
        //}
    }
    
    var size: CGSize? {
        switch mode {
            case .normalized(let s): return s
            default: return nil
        }
    }
    
    public enum ColorSpace: Hashable {
        case cam16, p3, srgb, iPhoneXR
        static let working = srgb
    }
    
    enum PixelFormat {
        case sRGB, float16, extended, sixteen, float32
        
        var rawValue: MTLPixelFormat {
            switch self {
                case .sRGB: return .bgra8Unorm_srgb
                case .float16: return .rgba16Float
                case .extended: return .bgra10_xr_srgb
                case .sixteen: return .rgba16Unorm
                case .float32: return .rgba32Float
            }
        }
        
        init?(rawValue: MTLPixelFormat) {
            switch rawValue {
                case .bgra8Unorm_srgb: self = .sRGB
                case .rgba16Unorm: self = .sixteen
                case .bgra10_xr_srgb: self = .extended
                case .rgba16Float: self = .float16
                case .rgba32Float: self = .float32
                default: return nil
            }
        }
    }
    
    enum Mode {
        case normalized(CGSize)
        case usingExtent
    }
    
}
