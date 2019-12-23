//
//  AffineTransform.swift
//  muze
//
//  Created by Greg on 2/6/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import UIKit

// a wrapper around CGAffineTransform with approximate equality
public struct AffineTransform: Equatable {
    
    public let cg: CGAffineTransform
    
    public init(_ transform: CGAffineTransform) {
        cg = transform
    }
    
    public static func == (lhs: AffineTransform, rhs: AffineTransform) -> Bool {
        return lhs.cg ~= rhs.cg
    }
    
    public static let identity = AffineTransform(.identity)
    
    public static func * (lhs: AffineTransform, rhs: AffineTransform) -> AffineTransform {
        return AffineTransform(lhs.cg * rhs.cg)
    }
    
    public static func *= (lhs: inout AffineTransform, rhs: AffineTransform) {
        lhs = lhs * rhs
    }
    
    public var inverse: AffineTransform {
        return AffineTransform(cg.inverted())
    }
    
    public var withoutRotation: AffineTransform {
        return AffineTransform(cg.withoutRotation)
    }
    
//    var asFloats: [Float] {
//        return cg.asFloats
//    }
//    
//    var asPaddedFloats: [Float] {
//        return cg.asPaddedFloats
//    }
    
}

public extension AffineTransform {
    
    static func translating(x: CGFloat, y: CGFloat) -> AffineTransform {
        return AffineTransform(CGAffineTransform(translationX: x, y: y))
    }
    
    func translatedBy(x: CGFloat, y: CGFloat) -> AffineTransform {
        return self * AffineTransform.translating(x: x, y: y)
    }
    
    func translating(from: CGPoint, to: CGPoint) -> AffineTransform {
        return translatedBy(x: to.x-from.x, y: to.y-from.y)
    }
    
    static func scaling(x: CGFloat, y: CGFloat) -> AffineTransform {
        return AffineTransform(CGAffineTransform(scaleX: x, y: y))
    }
    
    static func scaling(_ s: CGFloat) -> AffineTransform {
        return AffineTransform.scaling(x: s, y: s)
    }
    
    static func rotating(_ angle: CGFloat) -> AffineTransform {
        return AffineTransform(CGAffineTransform(rotationAngle: angle))
    }
    
//    public static func rotating(_ angle: Angle) -> AffineTransform {
//        return AffineTransform(CGAffineTransform(rotationAngle: angle.angleInRadians))
//    }
    
//    public static func rotating(degrees angleInDegrees: CGFloat) -> AffineTransform {
//        return AffineTransform.rotating(Angle(degrees: angleInDegrees))
//    }
    
}

public extension AffineTransform {
    
    init(from s: CGRect, to d: CGRect, flipHorizontally: Bool = false, flipVertically: Bool = false) {
        fatalError()
//        let t = CGAffineTransform.init(from: s, to: d, flipHorizontally: flipHorizontally, flipVertically: flipVertically)
//        self = AffineTransform(t)
    }
    
    var decomposition: TransformDecomposition {
        return cg.decomposition
    }
    
}

public extension AffineTransform {
    
    var maxScale: CGFloat {
        let scale = decomposition.scale
        return max(scale.x, scale.y)
    }
    
    var minScale: CGFloat {
        let scale = decomposition.scale
        return max(scale.x, scale.y)
    }
    
}
