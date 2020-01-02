//
//  RenderPayload.swift
//  muze
//
//  Created by Greg Fajen on 4/22/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

//import UIKit
import Metal
import MuzePrelude

public indirect enum RenderPayload {
    
    case texture(MetalTexture)
    case intermediate(RenderIntermediate)
    
    case colorMatrix(RenderPayload, DMatrix3x3)
    case alpha(RenderPayload, Float)
    
    case transforming(RenderPayload, AffineTransform)
    case cropAndTransform(RenderPayload, CGSize, AffineTransform)
    
    public var texture: MetalTexture? {
        switch self {
            case .texture(let texture): return texture
            case .intermediate(let i): return i.texture
                
            case .colorMatrix(let payload, _): return payload.texture
            case .alpha(let payload, _): return payload.texture
                
            case .transforming(let payload, _): return payload.texture
            case .cropAndTransform(let payload, _, _): return payload.texture
        }
    }
    
    public func transformed(by transform: AffineTransform) -> RenderPayload {
        if transform ~= .identity { return self }
        
        switch self {
            case let .transforming(p, t):
                return .transforming(p, t * transform)
                
            case let .cropAndTransform(p, s, t):
                return .cropAndTransform(p, s, t * transform)
                
            default:
                return .transforming(self, transform)
        }
    }
    
    public var intermediate: RenderIntermediate? {
        switch self {
            case .colorMatrix(let p, _): return p.intermediate
            case .alpha(let p, _): return p.intermediate
            case .cropAndTransform(let p, _, _): return p.intermediate
            case .transforming(let p, _): return p.intermediate
            case .texture: return nil
            case .intermediate(let i): return i
        }
    }
    
}

public extension RenderPayload {
    
    var isPass: Bool {
        switch self {
            case .texture: return false
            case .intermediate: return true
                
            case .colorMatrix(let p, _): return p.isPass
            case .alpha(let p, _): return p.isPass
            case .transforming(let p, _): return p.isPass
            case .cropAndTransform(let p, _, _): return p.isPass
        }
    }
    
    // warning: this returns a payload with the pass's texture, which has NOT yet been written to
    var withoutPass: RenderPayload? {
        switch self {
            case .texture(let t): return .texture(t)
            case .intermediate(let p):
                guard let t = p.output.texture else { return nil }
                
//                let o = p.output
//                let e = p.basicExtent.transform
                
                return .cropAndTransform(.texture(t), t.size, p.basicExtent.transform)
                
            case .alpha(let p, let a):
                guard let wo = p.withoutPass else { return nil }
                return .alpha(wo, a)
                
            case .colorMatrix(let p, let m):
                guard let wo = p.withoutPass else { return nil }
                return .colorMatrix(wo, m)
                
            case .transforming(let p, let t):
                guard let wo = p.withoutPass else { return nil }
                return .transforming(wo, t)
                
            case .cropAndTransform(let p, let s, let t):
                guard let wo = p.withoutPass else { return nil }
                return .cropAndTransform(wo, s, t)
        }
    }
    
}

public extension CGColorSpace {
    
    static let displayP3Space: CGColorSpace = CGColorSpace(name: CGColorSpace.displayP3)!
    static let sRGBSpace: CGColorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
    
}

#if os(iOS)
public extension UIColor {
    
    func converted(to space: CGColorSpace, intent: CGColorRenderingIntent) -> UIColor {
        let cg = cgColor.converted(to: space, intent: intent, options: nil)!
        return UIColor(cgColor: cg)
    }
    
}
#endif

@available(*, deprecated)
func * (m: DMatrix3x3, v: RenderColor) -> RenderColor {
    let rgb = m * [Double(v.r), Double(v.g), Double(v.b)]
    return RenderColor(rgb, a: v.a)
}

@available(*, deprecated)
public struct RenderColor: Equatable, ExpressibleByArrayLiteral {
    
    var r, g, b, a: Float
    
    public static func linearize<N: BinaryFloatingPoint>(sRGB channel: N) -> N {
        let u = channel
        if u <= 0.04045 {
            return u * 0.0773993808 // 1/12.92
        } else {
            return N(pow((Double(u)+0.055)/1.055, 2.4))
        }
    }
    
    public static func delinearize<N: BinaryFloatingPoint>(sRGB channel: N) -> N {
        let u = channel
        if u <= 0 { return 0 }
        if u >= 1 { return 1 }
        
        if u <= 0.0031308 {
            return u * 12.92
        } else {
            return 1.055 * N(pow(Double(u), 0.4166666667)) - 0.055
        }
    }
    
    static func linearize(sRGB vec: DVec3) -> DVec3 {
        var v = vec
        v.a = linearize(sRGB: v.a)
        v.b = linearize(sRGB: v.b)
        v.c = linearize(sRGB: v.c)
        return v
    }
    
    static func delinearize(sRGB vec: DVec3) -> DVec3 {
        var v = vec
        v.a = delinearize(sRGB: v.a)
        v.b = delinearize(sRGB: v.b)
        v.c = delinearize(sRGB: v.c)
        return v
    }
    
    public init(arrayLiteral elements: Float...) {
        r = elements[0]
        g = elements[1]
        b = elements[2]
        a = elements[3]
    }
    
    public init<N: BinaryFloatingPoint, M: BinaryFloatingPoint>(_ v: Vec3<N>,a: M) {
        r = Float(v.a)
        g = Float(v.b)
        b = Float(v.c)
        self.a = Float(a)
    }
    
    public init<N: BinaryFloatingPoint, M: BinaryFloatingPoint>(_ v: [N], a: M) {
        r = Float(v[0])
        g = Float(v[1])
        b = Float(v[2])
        self.a = Float(a)
    }
    
    #if os(iOS)
    public init(_ ui: UIColor) {
        let p3_compressed = ui.converted(to: .displayP3Space, intent: .absoluteColorimetric)
        var rgb = p3_compressed.components
        let a = rgb.removeLast()
        rgb = rgb.map(RenderColor.linearize)
        
        let p3_linear =  RenderColor(rgb, a: a)
        
        self = DMatrix3x3.cat16_to_dp3.inverse * p3_linear
    }
    
    public var ui: UIColor {
        let p3_linear = DMatrix3x3.cat16_to_dp3 * self
        let rgba = p3_linear.floats.map {RenderColor.delinearize(sRGB: CGFloat($0))} + [CGFloat(a)]
        let cg = CGColor(colorSpace: .displayP3Space, components: rgba)
        return UIColor(cgColor: cg!)
    }
    #endif
    
    public static let white = RenderColor.white(1)
    public static let black = RenderColor.white(0)
    public static let clear = RenderColor.white(0, alpha: 0)
    
    public static let red   = RenderColor.displayP3(red: 1, green: 0, blue: 0)
    public static let green = RenderColor.displayP3(red: 0, green: 1, blue: 0)
    public static let blue  = RenderColor.displayP3(red: 0, green: 0, blue: 1)
    
    public static func white(_ y: Float, alpha: Float = 1) -> RenderColor {
        return [y,y,y,alpha]
//        return RenderColor.displayP3(red: y, green: y, blue: y, alpha: alpha)
    }
    
    static func displayP3<N: BinaryFloatingPoint>(red: N, green: N, blue: N, alpha: N = 1) -> RenderColor {
        #if os(macOS)
        fatalError()
        #else
        let components = [red,green,blue,alpha].map { CGFloat($0) }
        let cg = CGColor(colorSpace: .displayP3Space, components: components)!
        let ui = UIColor(cgColor: cg)
        let color = RenderColor(ui)
        
//        let rui = color.ui
        
//        print("from \(ui.components)")
//        print(" got \(rui.components)")
        
        return color
        #endif
    }
    
}

@available(*, deprecated)
extension RenderColor {
    
    init(json: [String:Float]) {
        let   red = json["red"]!
        let green = json["green"]!
        let  blue = json["blue"]!
        let alpha = json["alpha"]!
        
        self = [red,green,blue,alpha]
    }
    
    var json: [String:Float] {
        return ["red": r, "green": g, "blue": b, "alpha": a]
    }
    
}

#if os(iOS)
@available(*, deprecated)
extension RenderColor {
    
    func withAlphaComponent(_ alpha: Float) -> RenderColor {
        return RenderColor([r,g,b], a: alpha)
    }
    
    var floats: [Float] {
        return [r,g,b,a]
    }
    
    var premultipliedComponents: [Float] {
        return [r*a,g*a,b*a,a]
    }
    
}
#endif

#if os(iOS)
public extension UIColor {
    
    convenience init(_ color: RenderColor2) {
        self.init(cgColor: color.ui.cgColor)
    }
    
    static func displayP3<N: BinaryFloatingPoint>(red: N, green: N, blue: N, alpha: N = 1) -> UIColor {
        let components = [red,green,blue,alpha].map { CGFloat($0) }
        let cg = CGColor(colorSpace: .displayP3Space, components: components)!
        return UIColor(cgColor: cg)
    }
    
}
#endif
