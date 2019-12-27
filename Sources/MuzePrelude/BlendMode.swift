//
//  BlendMode.swift
//  CanvasBase
//
//  Created by Greg Fajen on 12/26/19.
//

#if os(macOS)
import AppKit
#else
import UIKit
#endif

public enum BlendMode {
    
    case normal, multiply, screen, overlay, darken, lighten
    case colorDodge, colorBurn, hardLight, softLight, difference, exclusion
    
    public static let all: [BlendMode] = [.normal, .lighten, .darken, .overlay, .multiply, .softLight, .hardLight, .exclusion, .colorDodge, .difference, .screen, .colorBurn]
    
    public var name: String {
        switch self {
            case .normal:     return "normal"
            case .multiply:   return "multiply"
            case .screen:     return "screen"
            case .overlay:    return "overlay"
            case .darken:     return "darken"
            case .lighten:    return "lighten"
            case .colorDodge: return "color dodge"
            case .colorBurn:  return "color burn"
            case .hardLight:  return "hard light"
            case .softLight:  return "soft light"
            case .difference: return "difference"
            case .exclusion:  return "exclusion"
        }
    }
    
    public static func from(_ name: String) -> BlendMode? {
        for mode in BlendMode.all where mode.name == name {
            return mode
        }
        
        return nil
    }
    
    public init?(name: String) {
        if let mode = BlendMode.from(name) {
            self = mode
        } else {
            return nil
        }
    }
    
}

public extension BlendMode {
    
    var cgBlendMode: CGBlendMode {
        switch self {
            case .normal:     return .normal
            case .multiply:   return .multiply
            case .screen:     return .screen
            case .overlay:    return .overlay
            case .darken:     return .darken
            case .lighten:    return .lighten
            case .hardLight:  return .hardLight
            case .softLight:  return .softLight
            case .colorDodge: return .colorDodge
            case .colorBurn:  return .colorBurn
            case .difference: return .difference
            case .exclusion:  return .exclusion
        }
    }
    
}

public extension BlendMode {
    
    var ciFilter: String? {
        switch self {
            case .normal: return nil
            
            case .multiply:   return   "multiplyBlendMode"
            case .screen:     return     "screenBlendMode"
            case .overlay:    return    "overlayBlendMode"
            case .darken:     return     "darkenBlendMode"
            case .lighten:    return    "lightenBlendMode"
            case .colorDodge: return "colorDodgeBlendMode"
            case .colorBurn:  return  "colorBurnBlendMode"
            case .hardLight:  return  "hardLightBlendMode"
            case .softLight:  return  "softLightBlendMode"
            case .difference: return "differenceBlendMode"
            case .exclusion:  return  "exclusionBlendMode"
        }
    }
    
}
