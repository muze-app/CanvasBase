//
//  CGPoint+MiscFunctionality.swift
//  muze
//
//  Created by Grant Davis on 6/27/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import UIKit

extension CGPoint {
    static let screenCenter: CGPoint = UIScreen.main.bounds.center
    
    var asVector: CGVector {
        return CGVector(dx: self.x, dy: self.y)
    }
    
    /// returns whether the point, when considered as a vector,
    /// is predominantly pointing (positively or negatively) in
    /// the horizontal (x axis) direction.
    func isHorizontal(byAFactorOf factor: CGFloat = 1) -> Bool {
        return abs(x) > abs(factor*y)
    }
    
    /// returns whether the point, when considered as a vector,
    /// is predominantly pointing (positively or negatively) in
    /// the vertical (y axis) direction.
    func isVertical(byAFactorOf factor: CGFloat = 1) -> Bool {
        return abs(y) > abs(factor*x)
    }
    
    func distance(from point: CGPoint) -> CGFloat {
        let xd = x - point.x
        let yd = y - point.y
        return sqrt(xd*xd + yd*yd)
    }
    
    func blend(with point: CGPoint, amount: CGFloat = 0.5) -> CGPoint {
        let xOff = point.x - self.x
        let yOff = point.y - self.y
        
        var result = self
        result.x += xOff * amount
        result.y += yOff * amount
        
        return result
    }
    
    static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        let x = lhs.x + rhs.x
        let y = lhs.y + rhs.y
        return CGPoint(x: x, y: y)
    }
    
    static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        let x = lhs.x - rhs.x
        let y = lhs.y - rhs.y
        return CGPoint(x: x, y: y)
    }
    
    static func *(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        return CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
    }
    
    static func +=(lhs: inout CGPoint, rhs: CGPoint) {
        lhs = lhs + rhs
    }
    
    func isInside(of rect: CGRect?) -> Bool {
        return rect?.contains(self) ?? false
    }
}
