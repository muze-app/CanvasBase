//
//  CGFloat+MiscFunctionality.swift
//  muze
//
//  Created by Grant Davis on 6/27/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import UIKit

extension CGFloat {
    
    var asFloat: Float {
        return Float(self)
    }
    
    var asDouble: Double {
        return Double(self)
    }
    
    // Halo intro soundtrack
    //    o    ~       o      o ~      o  ~
    // o   ~  o    o    ~ o        o   ~    o
    // You  are   now   entering   the   lair   of . . . .
    //
    func mappedProportionally(from r0: (CGFloat, CGFloat),
                                to r1: (CGFloat, CGFloat)) -> CGFloat {
        // y = (x-a)(d-c)/(b-a) + c describes any one-dimensional range transformation consisting of scaling and shifting, where x is a point in the original range [a,b] and y is its mapped correspondent in the transformed range [c,d]. The func returns y where self = x.
        // a, b, c, and d are all coordinates within a single one-dimensional system Z. Here's an example visualization of the transformation:
        //  before:  0 - - a---x------b - - - - - - - - - - - - - - - -> Z
        //   after:  0 - - - - - - - - - - c------y------------d - - - > Z
        
        let a = r0.0
        let b = r0.1
        let c = r1.0
        let d = r1.1
        
        return (self-a)*(d-c)/(b-a) + c
    }
    
//    func mappedProportionally(from r0: AnimationRange,
//                                to r1: AnimationRange) -> CGFloat {
//        return mappedProportionally(from: r0.asDuple, to: r1.asDuple)
//    }
        
    func mappedProportionally(from r: (CGFloat, CGFloat), to t: (CGAffineTransform, CGAffineTransform)) -> CGAffineTransform {
        let mappedA  = self.mappedProportionally(from: r, to: (t.0.a, t.1.a))
        let mappedB  = self.mappedProportionally(from: r, to: (t.0.b, t.1.b))
        let mappedC  = self.mappedProportionally(from: r, to: (t.0.c, t.1.c))
        let mappedD  = self.mappedProportionally(from: r, to: (t.0.d, t.1.d))
        let mappedTx = self.mappedProportionally(from: r, to: (t.0.tx, t.1.tx))
        let mappedTy = self.mappedProportionally(from: r, to: (t.0.ty, t.1.ty))

        return CGAffineTransform(a: mappedA,
                                 b: mappedB,
                                 c: mappedC,
                                 d: mappedD,
                                tx: mappedTx,
                                ty: mappedTy)
    }
    
    //  ~   o     o      o    ~  o      o
    //       o   ~    o   ~  o  ~    o
    //  o ~  o    o   ~ o   o   ~   o  ~   o
    //===========================================
    
    /// This is like the normal clamp function, but it doesn't presume which of the two inputs is the min or max and instead determines that for you.
    func clamp(withinRange range: (CGFloat, CGFloat)) -> CGFloat {
        fatalError()
//        let min = CGFloat.minimum(range.0, range.1)
//        let max = CGFloat.maximum(range.0, range.1)
//
//        return self.clamp(min: min, max: max)
    }
    
//    func clamp(withinRange range: AnimationRange) -> CGFloat {
//        return clamp(withinRange: range.asDuple)
//    }
    
    func isInside(of range: (CGFloat, CGFloat)?) -> Bool {
        guard let r = range else {
            return false
        }
        return self > r.0 && self < r.1
    }
    
//    func isInside(of range: AnimationRange?) -> Bool {
//        return isInside(of: range?.asDuple)
//    }
    
//    func isBefore(_ range: AnimationRange) -> Bool {
//        if range.isPositive {
//            return self < range.start
//        } else {
//            return self > range.start
//        }
//    }
    
//    func isAfter(_ range: AnimationRange) -> Bool {
//        if range.isPositive {
//            return self > range.end
//        } else {
//            return self < range.end
//        }
//    }
    
    func approximates(_ a:CGFloat, precision:CGFloat) -> Bool {
        let min = self - precision
        let max = self + precision
        return a >= min && a <= max 
    }
}
