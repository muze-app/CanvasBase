//
//  DabRealizer.swift
//  muze
//
//  Created by Greg on 1/3/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import MuzePrelude

// takes abstract dabs from interpolator, yields concrete dabs
public class DabRealizer {
    
    public let interpolator: DabInterpolator
    
    public var adjustOpacityBasedOnSpacing = true
    
    public init(interpolator: DabInterpolator) {
        self.interpolator = interpolator
    }
    
    public func getDabs() -> [ConcreteDab] {
        return interpolator.getDabs().map { convert($0) }
    }
    
    func convert(_ abstract: AbstractDab) -> ConcreteDab {
        return ConcreteDab(x: Float(abstract.x),
                           y: Float(abstract.y),
                           radius: abstract.diameter / 2,
                           exponent: getExponent(from: abstract.hardness),
                           color: abstract.color,
                           opacity: getOpacity(from: abstract))
    }
    
    func getExponent(from hardness: Float) -> Float {
        let x = hardness.clamp()
        let a: Float =  1.6595
        let b: Float =  0.2621
        let c: Float =  1.3028
        let d: Float = -2.7835
        return a * tan(b * x + c) + d
    }
    
    func getOpacity(from dab: AbstractDab) -> Float {
        if !adjustOpacityBasedOnSpacing {
            return dab.opacity
        }
        
        let s = Float(interpolator.stroke.spacing)
        let a = dab.opacity
        
        let c = 1-((1-a)^s)
        
        if c < 0.004 {
            return 0.004
        }
        
        return c
    }
    
}

public extension Float {
    
    func clamp(min: Float = 0, max: Float = 1) -> Float {
        if self < min { return min }
        if self > max { return max }
        return self
    }
    
    static func ^ (lhs: Float, rhs: Float) -> Float {
        return pow(lhs, rhs)
    }
    
}
