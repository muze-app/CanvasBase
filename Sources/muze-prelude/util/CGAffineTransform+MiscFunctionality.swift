//
//  CGAffineTransform+MiscFunctionality.swift
//  muze
//
//  Created by Grant Davis on 6/27/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import UIKit

public extension CGAffineTransform {
    var angle       : CGFloat { return atan2(b, a) }
    var widthScale  : CGFloat { return a+b }
    var heightScale : CGFloat { return c+d }
    var minScale    : CGFloat { return min(unrotatedWidthScale, unrotatedHeightScale) }
    var maxScale    : CGFloat { return max(unrotatedWidthScale, unrotatedHeightScale) }
    
    /// returns a rotation invariant heightScale. Rotations cause the normal heightScale to be with respect to the bounding box of the thing being transformed. If you want to know how much the actual content height itself is being stretched (which is equivalent to heightScale when the rotation is 0), use this.
    var unrotatedHeightScale: CGFloat {
        return self.withoutRotation.heightScale
    }
    
    /// returns a rotation invariant widthScale. Rotations cause the normal widthScale to be with respect to the bounding box of the thing being transformed. If you want to know how much the actual content width itself is being stretched (which is equivalent to widthScale when the rotation is 0), use this.
    var unrotatedWidthScale: CGFloat {
        return self.withoutRotation.widthScale
    }
    
    var withoutRotation: CGAffineTransform {
        let derotation = CGAffineTransform(rotationAngle: -self.angle)
        return self * derotation
    }
    
    init(scale: CGFloat) {
        self.init(scaleX: scale, y: scale)
    }
    
    static func *(lhs: CGAffineTransform, rhs: CGAffineTransform) -> CGAffineTransform {
        return lhs.concatenating(rhs)
    }
    
    static func *= (lhs: inout CGAffineTransform, rhs: CGAffineTransform) {
        lhs = lhs.concatenating(rhs)
    }
    
    var isIdentity: Bool {
        return self ~= .identity
    }
    
    var components: [CGFloat] {
        return [a, b, c, d, tx, ty]
    }
    
    static func ~=(lhs: CGAffineTransform, rhs: CGAffineTransform) -> Bool {
        for (l, r) in zip(lhs.components, rhs.components) {
            if !(l ~= r) {
                //                print ("\(l) != \(r): off by \(abs(l-r))")
                return false
            }
        }
        
        return true
    }
    
    init(from s: CGRect,
         to d: CGRect,
         flipHorizontally: Bool = false,
         flipVertically: Bool = false) {
        var t = CGAffineTransform.identity
        
        t = t.translatedBy(x: d.minX, y: d.minY)
        t = t.scaledBy(x: d.width, y: d.height)
        
        if flipHorizontally {
            t = t.translatedBy(x: 1, y: 0)
            t = t.scaledBy(x: -1, y: 1)
        }
        
        if flipVertically {
            t = t.translatedBy(x: 0, y: 1)
            t = t.scaledBy(x: 1, y: -1)
        }
        
        t = t.scaledBy(x: 1/s.width, y: 1/s.height)
        t = t.translatedBy(x: -s.minX, y: -s.minY)
        
        self = t
    }
    
//    static func testConversions() {
//        for _ in 0..<100 {
//            let s = CGRect.random
//            let d = CGRect.random
//            
//            let t = CGAffineTransform(from: s, to: d, flipHorizontally: false)
//            
//            let d2 = s.applying(t)
//            
//            print("\(s) -> \(d)")
//            print("    \(t)")
//            
//            if d ~= d2 {
//                print("    works!")
//            } else {
//                print("    oops: got \(d2)")
//                print(" ")
//            }
//        }
//    }
    
    func dict() -> [String:Double] {
        return [
            "a": Double(self.a),
            "b": Double(self.b),
            "c": Double(self.c),
            "d": Double(self.d),
            "tX": Double(self.tx),
            "tY": Double(self.ty)
        ]
    }
    
    func scaledBy(_ delta: CGFloat) -> CGAffineTransform {
        return CGAffineTransform(a: self.a + delta,
                                 b: self.b,
                                 c: self.c,
                                 d: self.d + delta,
                                tx: self.tx,
                                ty: self.ty)
    }
    
    //  create a copy of the current transform with specified changed values
    func with(a: CGFloat? = nil,
              b: CGFloat? = nil,
              c: CGFloat? = nil,
              d: CGFloat? = nil,
              tx: CGFloat? = nil,
              ty: CGFloat? = nil) -> CGAffineTransform {
        
        return CGAffineTransform(a: a ?? self.a,
                                 b: b ?? self.b,
                                 c: c ?? self.c,
                                 d: d ?? self.d,
                                 tx: tx ?? self.tx,
                                 ty: ty ?? self.ty)
    }
}
