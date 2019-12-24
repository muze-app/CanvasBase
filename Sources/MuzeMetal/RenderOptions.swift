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
    
    public let identifier: String
    public let mode: Mode
    public let outputFormat: PixelFormat
    public let time: TimeInterval
    
    public init(_ identifier: String, mode: Mode, format: PixelFormat, time: TimeInterval) {
        self.identifier = identifier
        self.mode = mode
        self.outputFormat = format
        self.time = time
//        if !UIDevice.current.isX {
//            assert(outputFormat != .extended)
//        }
    }
    
    public init(_ identifier: String, size: CGSize, format: PixelFormat, time: TimeInterval) {
        self.identifier = identifier
        self.mode = .normalized(size)
        self.outputFormat = format
        self.time = time
        //if !UIDevice.current.isX {
        //    assert(outputFormat != .extended)
        //}
    }
    
    public var size: CGSize? {
        switch mode {
            case .normalized(let s): return s
            default: return nil
        }
    }
    
    public enum ColorSpace: Hashable {
        case cam16, p3, srgb, iPhoneXR
        public static let working = srgb
    }
    
    public enum PixelFormat {
        case sRGB, float16, extended, sixteen, float32
        
        public var rawValue: MTLPixelFormat {
            switch self {
                case .sRGB: return .bgra8Unorm_srgb
                case .float16: return .rgba16Float
                case .extended: return .bgra10_xr_srgb
                case .sixteen: return .rgba16Unorm
                case .float32: return .rgba32Float
            }
        }
        
        public init?(rawValue: MTLPixelFormat) {
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
    
    public enum Mode {
        case normalized(CGSize)
        case usingExtent
    }
    
}

extension RenderOptions.PixelFormat {
    
    var isLinear: Bool {
        switch self {
            case .extended: return true
            case .float16: return true
            case .float32: return true
            case .sixteen: return false
            case .sRGB: return true
        }
    }
    
}
