//
//  BlendMode+Metal.swift
//  CanvasBase
//
//  Created by Greg Fajen on 12/26/19.
//

import Foundation
import MuzePrelude

public extension BlendMode {
    
    var pipeline: MetalPipeline {
        switch self {
            case .multiply:   return .blendMultiply
            case .screen:     return .blendScreen
            case .overlay:    return .blendOverlay
            case .darken:     return .blendDarken
            case .lighten:    return .blendLighten
            case .colorDodge: return .blendColorDodge
            case .colorBurn:  return .blendColorBurn
            case .hardLight:  return .blendHardLight
            case .softLight:  return .blendSoftLight
            case .difference: return .blendDifference
            case .exclusion:  return .blendExclusion
            
            case .normal: fatalError()
        }
    }
    
}

public extension MetalPipeline {
    
    static let blendMultiply   = MetalPipeline(vertex: .basic, fragment: .blendMultiply)
    static let blendScreen     = MetalPipeline(vertex: .basic, fragment: .blendScreen)
    static let blendOverlay    = MetalPipeline(vertex: .basic, fragment: .blendOverlay)
    static let blendDarken     = MetalPipeline(vertex: .basic, fragment: .blendDarken)
    static let blendLighten    = MetalPipeline(vertex: .basic, fragment: .blendLighten)
    static let blendColorDodge = MetalPipeline(vertex: .basic, fragment: .blendColorDodge)
    static let blendColorBurn  = MetalPipeline(vertex: .basic, fragment: .blendColorBurn)
    static let blendHardLight  = MetalPipeline(vertex: .basic, fragment: .blendHardLight)
    static let blendSoftLight  = MetalPipeline(vertex: .basic, fragment: .blendSoftLight)
    static let blendDifference = MetalPipeline(vertex: .basic, fragment: .blendDifference)
    static let blendExclusion  = MetalPipeline(vertex: .basic, fragment: .blendExclusion)
    
}

public extension FragmentFunction {
    
    static let blendMultiply   = FragmentFunction(name:    "multiply_blend")
    static let blendScreen     = FragmentFunction(name:      "screen_blend")
    static let blendOverlay    = FragmentFunction(name:     "overlay_blend")
    static let blendDarken     = FragmentFunction(name:      "darken_blend")
    static let blendLighten    = FragmentFunction(name:     "lighten_blend")
    static let blendColorDodge = FragmentFunction(name: "color_dodge_blend")
    static let blendColorBurn  = FragmentFunction(name:  "color_burn_blend")
    static let blendHardLight  = FragmentFunction(name:  "hard_light_blend")
    static let blendSoftLight  = FragmentFunction(name:  "soft_light_blend")
    static let blendDifference = FragmentFunction(name:  "difference_blend")
    static let blendExclusion  = FragmentFunction(name:   "exclusion_blend")
    
}
