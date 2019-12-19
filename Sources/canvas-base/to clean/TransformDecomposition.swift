//
//  TransformDecomposition.swift
//  muze
//
//  Created by Greg on 1/15/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import UIKit

protocol TransformAtom: CustomStringConvertible {
    
    var transform: CGAffineTransform { get }
    
    static func decomposing(transform: CGAffineTransform) -> (Self, CGAffineTransform)
    
}

extension TransformAtom {
    
    var inverse: CGAffineTransform {
        return transform.inverted()
    }
    
}

struct TranslateAtom: TransformAtom {
    
    var x: CGFloat
    var y: CGFloat
    
    static func decomposing(transform: CGAffineTransform) -> (TranslateAtom, CGAffineTransform) {
        let atom = TranslateAtom(x: transform.tx, y: transform.ty)
        let remainder = transform * atom.inverse
//        let result = remainder * atom.transform
//        assert( result ~= transform )
        return (atom, remainder)
    }
    
    var transform: CGAffineTransform {
        return CGAffineTransform(translationX: x, y: y)
    }
    
    var description: String {
        return "Translate \(x.string), \(y.string)"
    }
    
}

struct RotateAtom: TransformAtom {
    
    var angle: CGFloat
    var angleInDegrees: CGFloat {
        get {
        return angle * 180 / .pi
        }
        
        set {
            angle = newValue / 180 * .pi
        }
    }
    
    static func decomposing(transform: CGAffineTransform) -> (RotateAtom, CGAffineTransform) {
        assert(transform.tx ~= 0)
        assert(transform.ty ~= 0)
        
        let unit = CGPoint(x: 1, y: 0)
        let rotated = unit.applying(transform)
        var angle = atan2(rotated.y, rotated.x)

//        if angle < 0 { angle += 2 * .pi }
        let halfPi = CGFloat.pi / 2
        if angle > halfPi {
            angle -= .pi
        } else if angle < -halfPi {
            angle += .pi
        }
        
        let atom = RotateAtom(angle: angle)
        let remainder = transform * atom.inverse
//        let result = remainder * atom.transform
//        assert( result ~= transform )
//        assert( remainder.b ~= 0 )
        return (atom, remainder)
    }
    
    var transform: CGAffineTransform {
        return CGAffineTransform(rotationAngle: angle)
    }
    
    var description: String {
        return "Rotate \(angleInDegrees.string)˚"
    }
    
}

struct ScaleAtom: TransformAtom {
    
    var x: CGFloat
    var y: CGFloat
    
    static func decomposing(transform: CGAffineTransform) -> (ScaleAtom, CGAffineTransform) {
        assert(transform.tx ~= 0)
        assert(transform.ty ~= 0)
        assert(transform.b  ~= 0)
        
        let atom = ScaleAtom(x: transform.a, y: transform.d)
        let remainder = transform * atom.inverse
//        let result = remainder * atom.transform
//        assert( result ~= transform )
        return (atom, remainder)
    }
    
    var transform: CGAffineTransform {
        return CGAffineTransform(scaleX: x, y: y)
    }
    
    var description: String {
        return "Scale \(x.string) × \(y.string)"
    }
    
}

struct ShearAtom: TransformAtom {
    
    var shear: CGFloat
    
    static func decomposing(transform: CGAffineTransform) -> (ShearAtom, CGAffineTransform) {
        assert(transform.tx ~= 0)
        assert(transform.ty ~= 0)
        assert(transform.a  ~= 1)
        assert(transform.d  ~= 1)
        assert(transform.b  ~= 0)
       
        let atom = ShearAtom(shear: transform.c)
        let remainder = transform * atom.inverse
//        let result = remainder * atom.transform
//        assert( result ~= transform )
//        assert( remainder ~= .identity )
        return (atom, remainder)
        
    }
    
    var transform: CGAffineTransform {
        return CGAffineTransform(a: 1, b: 0, c: shear, d: 1, tx: 0, ty: 0)
    }
    
    var description: String {
        return "Shear: \(shear.string)"
    }
    
}

// Isomorphic to CGAffineTransform modulo rounding errors
struct TransformDecomposition: CustomStringConvertible {
    
    var translation: TranslateAtom
    var rotation: RotateAtom
    var scale: ScaleAtom
    var shear: ShearAtom
    
    init(transform: CGAffineTransform) {
        let (translation, untranslated) = TranslateAtom.decomposing(transform: transform)
        self.translation = translation
//        TransformDecomposition.test(atom: translation, remainder: untranslated, result: transform)
        
        let (rotation, unrotated) = RotateAtom.decomposing(transform: untranslated)
        self.rotation = rotation
//        TransformDecomposition.test(atom: rotation, remainder: unrotated, result: untranslated)
        
        let (scale, unscaled) = ScaleAtom.decomposing(transform: unrotated)
        self.scale = scale
//        TransformDecomposition.test(atom: scale, remainder: unscaled, result: unrotated)
        
        let (shear, _) = ShearAtom.decomposing(transform: unscaled)
        self.shear = shear
//        TransformDecomposition.test(atom: shear, remainder: unsheared, result: unscaled)
        
//        assert(unsheared ~= .identity)
    }
    
    init(_ translation: TranslateAtom, _ rotation: RotateAtom, _ scale: ScaleAtom, _ shear: ShearAtom) {
        self.translation = translation
        self.rotation = rotation
        self.scale = scale
        self.shear = shear
    }
    
    var transform: CGAffineTransform {
        return shear.transform * scale.transform * rotation.transform * translation.transform
    }
    
    var inverse: CGAffineTransform {
        return transform.inverted()
    }
    
    // MARK: Concatenation
    
    mutating func set(to transform: CGAffineTransform) {
        set(to: transform.decomposition)
    }
    
    mutating func set(to decomposition: TransformDecomposition) {
        translation = decomposition.translation
        rotation    = decomposition.rotation
        scale       = decomposition.scale
        shear       = decomposition.shear
    }
    
    mutating func append(_ transform: CGAffineTransform) {
        set(to: self.transform * transform)
    }
    
    mutating func append(_ decomposition: TransformDecomposition) {
        append(decomposition.transform)
    }
    
    mutating func prepend(_ transform: CGAffineTransform) {
        set(to: transform * self.transform)
    }
    
    mutating func prepend(_ decomposition: TransformDecomposition) {
        prepend(decomposition.transform)
    }
    
    // MARK: Description
    
    var description: String {
        return "TransformDecomposition: \n\t\(shear), \n\t\(scale), \n\t\(rotation), \n\t\(translation)"
    }
    
    // MARK: Fuzz Testing
    
    static func test(atom: TransformAtom, remainder: CGAffineTransform, result: CGAffineTransform) {
        assert( remainder * atom.transform ~= result )
        assert( result * atom.inverse ~= remainder )
    }

    static func test() {
        for _ in 0...100 {
            let transform = CGAffineTransform.random
            let decomposition = TransformDecomposition(transform: transform)

            assert(transform ~= decomposition.transform)
        }
    }
    
}

extension CGAffineTransform {
    
    static var random: CGAffineTransform {
        return CGAffineTransform(a: .random, b: .random, c: .random, d: .random, tx: .random, ty: .random)
    }
    
    var decomposition: TransformDecomposition {
        return TransformDecomposition(transform: self)
    }
    
}

extension CGFloat {
    
    static var random: CGFloat {
        return CGFloat(arc4random_uniform(20000)) - 10000
    }
    
    static var formatter: NumberFormatter = NumberFormatter()
    
    func string(digits: Int = 4) -> String {
        let formatter = CGFloat.formatter
        formatter.maximumFractionDigits = digits
        let number: NSNumber = self as NSNumber
        return formatter.string(from: number)!
    }
    
    var string: String {
        return string()
    }
    
}
