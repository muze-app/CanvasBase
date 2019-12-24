//
//  File.swift
//  
//
//  Created by Greg Fajen on 12/19/19.
//

import UIKit

public extension Range where Element == Int {
    
    var length: Int {
        return upperBound - lowerBound
    }
    
}

public extension CGAffineTransform {
    
    var asFloats: [Float] {
        let values = [a,b,c,d,tx,ty]
        return values.map { Float($0) }
    }
    
    var asPaddedFloats: [Float] {
        let values = [a,b,c,d,tx,ty,0,0]
        return values.map { Float($0) }
    }
    
}

public extension CGFloat {
    
    var abs: CGFloat {
        return self < 0 ? -self : self
    }
    
    static func ~= (lhs: CGFloat, rhs: CGFloat) -> Bool {
        let sigma = Swift.max(lhs / 10000, 0.00000001)
        let diff = (lhs - rhs).abs
        return diff <= sigma
    }
    
}

public extension CGRect {
    
    static var random: CGRect {
        let upper: UInt32 = 2000
        let x = arc4random_uniform(upper)
        let y = arc4random_uniform(upper)
        let w = arc4random_uniform(upper)
        let h = arc4random_uniform(upper)
        return CGRect(x: x, y: y, width: w, height: h)
    }
    
    init(x: UInt32, y: UInt32, width: UInt32, height: UInt32) {
        self.init(x: CGFloat(x), y: CGFloat(y), width: CGFloat(width), height: CGFloat(height))
    }
    
    static func ~= (lhs: CGRect, rhs: CGRect) -> Bool {
        return lhs.minX ~= rhs.minX &&
            lhs.minY ~= rhs.minY &&
            lhs.maxX ~= rhs.maxX &&
            lhs.maxY ~= rhs.maxY
    }
    
}

public extension CGPoint {
    
    static func ~= (lhs: CGPoint, rhs: CGPoint) -> Bool {
        return lhs.x ~= rhs.x && lhs.y ~= rhs.y
    }
    
}

public extension UIColor {
    
    var alpha: CGFloat {
        var alpha: CGFloat = 1
        getRed(nil, green: nil, blue: nil, alpha: &alpha)
        return alpha
    }
    
    var components: [Float] {
        var r: CGFloat = 1
        var g: CGFloat = 1
        var b: CGFloat = 1
        var a: CGFloat = 1
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        return [r,g,b,a].map { Float($0) }
    }
    
    var premultipliedComponents: [Float] {
        let components = self.components
        let a = components[3]
        let r = components[0] * a
        let g = components[1] * a
        let b = components[2] * a
        
        return [r,g,b,a]
    }
    
}
