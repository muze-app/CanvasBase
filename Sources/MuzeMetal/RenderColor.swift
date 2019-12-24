//
//  RenderColor.swift
//  muze
//
//  Created by Greg Fajen on 7/4/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import UIKit
import MuzePrelude

// unpremultiplied, linear color
public struct RenderColor2: Hashable, Blendable, MetalBuffer {
    
    public typealias ColorSpace = RenderOptions.ColorSpace
    
    public var r, g, b, a: Float
    public let colorSpace: ColorSpace
    
    static func linearize<N: BinaryFloatingPoint>(sRGB channel: N) -> N {
        let s: N = channel < 0 ? -1 : 1
        let u = abs(channel)
        if u <= 0.04045 {
            return s * u * 0.0773993808 // 1/12.92
        } else {
            return s * N(pow((Double(u)+0.055)/1.055, 2.4))
        }
    }
    
    static func delinearize<N: BinaryFloatingPoint>(sRGB channel: N) -> N {
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
        colorSpace = .p3
    }
    
    public init<N: BinaryFloatingPoint, M: BinaryFloatingPoint>(_ v: Vec3<N>, a: M, colorSpace: ColorSpace = .p3) {
        r = Float(v.a)
        g = Float(v.b)
        b = Float(v.c)
        self.a = Float(a)
        self.colorSpace = colorSpace
    }
    
    public init<N: BinaryFloatingPoint, M: BinaryFloatingPoint>(_ v: [N], a: M, colorSpace: ColorSpace = .p3) {
        r = Float(v[0])
        g = Float(v[1])
        b = Float(v[2])
        self.a = Float(a)
        self.colorSpace = colorSpace
    }
    
    public init(_ ui: UIColor) {
        let p3_compressed = ui.converted(to: .displayP3Space, intent: .absoluteColorimetric)
        var rgb = p3_compressed.components
        let a = rgb.removeLast()
        rgb = rgb.map(RenderColor2.linearize)
        
        self = RenderColor2(rgb, a: a, colorSpace: .p3)
    }
    
    // currently assumes we're only using color spaces with sRGB 'gamma' curve
    var ui: UIColor {
        guard let space = colorSpace.cg else {
            return self.converted(to: .p3).ui
        }
        
        let rgb = RenderColor2.delinearize(sRGB: self.rgb)
        let rgba = rgb.components.map { CGFloat($0) } + [CGFloat(a)]
        let cg = CGColor(colorSpace: space, components: rgba)
        return UIColor(cgColor: cg!)
    }
    
    func converted(to space: ColorSpace) -> RenderColor2 {
        if self.colorSpace == space { return self }
        let m = colorSpace.matrix(to: space)
        return RenderColor2(m * rgb, a: a, colorSpace: space)
    }
    
    func assigning(space: ColorSpace) -> RenderColor2 {
        return RenderColor2(rgb, a: a, colorSpace: space)
    }
    
    var rgb: DVec3 {
        typealias D = Double
        return [D(r), D(g), D(b)]
    }
    
    var floats: [Float] {
        return [r,g,b,a]
    }
    
    public static let white = RenderColor2.white(1)
    public static let black = RenderColor2.white(0)
    public static let clear = RenderColor2.white(0, alpha: 0)
    
    public static let red   = RenderColor2.displayP3(red: 1, green: 0, blue: 0)
    public static let green = RenderColor2.displayP3(red: 0, green: 1, blue: 0)
    public static let blue  = RenderColor2.displayP3(red: 0, green: 0, blue: 1)
    
    public static func white(_ y: Float, alpha: Float = 1, colorSpace: ColorSpace = .p3) -> RenderColor2 {
        return RenderColor2([y,y,y], a: alpha, colorSpace: colorSpace)
    }
    
    static func displayP3<N: BinaryFloatingPoint>(red: N, green: N, blue: N, alpha: N = 1) -> RenderColor2 {
        return RenderColor2([red,green,blue], a: alpha, colorSpace: .p3)
    }
    public var length: Int { 16 }
    
    public var asData: Data {
        guard colorSpace == .working else {
            return converted(to: .working).asData
        }
        
        return ([r,g,b,a]).asData
    }
    
    public func blend(with other: RenderColor2, _ t: Float) -> RenderColor2 {
        let other = other.converted(to: colorSpace)
        var c = self
        c.r = self.r.blend(with: other.r, t)
        c.g = self.g.blend(with: other.g, t)
        c.b = self.b.blend(with: other.b, t)
        c.a = self.a.blend(with: other.a, t)
        return c
    }
    
    public func transformed(by transform: AffineTransform) -> RenderColor2 {
        return self
    }
    
}

public extension RenderColor2.ColorSpace {
    
//    var matrixFromCAT16: DMatrix3x3 {
//        return matrixToCAT16.inverse
//    }
    
    typealias ColorSpacePair = Pair<RenderColor2.ColorSpace, RenderColor2.ColorSpace>
    private static var conversionMatrices = ThreadSafeDict<ColorSpacePair, DMatrix3x3>()
    
    static func matrix(from source: RenderColor2.ColorSpace, to target: RenderColor2.ColorSpace) -> DMatrix3x3 {
        if source == target { return .identity }
        
        let pair = Pair(source, target)
        if let matrix = conversionMatrices[pair] { return matrix }
        
        let matrix = target.matrixFromXYZ * source.matrixToXYZ
        conversionMatrices[pair] = matrix
        
        return matrix
    }
    
    func matrix(to target: RenderColor2.ColorSpace) -> DMatrix3x3 {
        if self == target { return .identity }
        return RenderColor2.ColorSpace.matrix(from: self, to: target)
    }
    
    func matrix(from source: RenderColor2.ColorSpace) -> DMatrix3x3 {
        if self == source { return .identity }
        return RenderColor2.ColorSpace.matrix(from: source, to: self)
    }
    
    internal var matrixToXYZ: DMatrix3x3 {
        switch self {
            case .srgb:
                return [[0.4361, 0.3851, 0.1431],
                        [0.2225, 0.7169, 0.0606],
                        [0.0139, 0.0971, 0.7141]]
                
            case .p3:
                return [[0.5151, 0.2920, 0.1571],
                        [0.2412, 0.6922, 0.0666],
                        [-0.0011, 0.0419, 0.7841]]
                
            case .cam16:
                // only correct for Ill. D65 color spaces, which both Display P3 and sRGB are
                return  .M_CAT16_INV * .from(.illuminantE, to: .illuminantD65)
    //            return [[0.401288, 0.650173, -0.051461],
    //                    [-0.250268, 1.204414, 0.045845],
    //                    [-0.002079, 0.048952, 0.953127]]
                
            case .iPhoneXR:
                return RenderColor2.ColorSpace.srgb.matrixToXYZ
    //            return [[0.1999995231633392, 0.6904530752801865, 0.35371200153237375],
    //                    [0.12104988708652727, 0.7828967744928659, 0.2161566933030068],
    //                    [0.04354032611811673, 0.2671484478056687, 0.6773506716109418]]
        }
    }
    
    internal var matrixFromXYZ: DMatrix3x3 {
        return matrixToXYZ.inverse
    }
    
    var cg: CGColorSpace? {
        switch self {
            case .p3: return .displayP3Space
            case .srgb: return .sRGBSpace
            default: return nil
        }
    }
    
}
