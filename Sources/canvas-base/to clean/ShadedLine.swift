//
//  ShadedLine.swift
//  muze
//
//  Created by Greg Fajen on 4/18/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import UIKit
import muze_prelude

struct ShadedLine {
    
    let point: CGPoint
    let angle: CGFloat
    
    init(point: CGPoint, angle: CGFloat, isFlipped: Bool = false) {
        self.point = point
        self.angle = angle
    }
    
    init(point: CGPoint, slope: CGFloat) {
        self.init(point: point, angle: atan(slope))
    }
    
    init(points a: CGPoint, _ b: CGPoint) {
        let angle = atan2(b.y-a.y, b.x-a.x)
        self.init(point: a, angle: angle)
    }
    
    func with(pointInShade: CGPoint) -> ShadedLine {
        let flip = !pointIsInShade(pointInShade)
        return ShadedLine(point: point,
                          angle: angle + (flip ? .pi : 0))
    }
    
    var transform: CGAffineTransform {
//        let translation = CGAffineTransform(translationX: -point.x, y: -point.y)
//        let rotation = CGAffineTransform(rotationAngle: -angle)
        
        fatalError()
//        return translation * rotation
    }
    
    func value(for point: CGPoint) -> CGFloat {
        return point.applying(transform).y
    }
    
    func pointIsInShade(_ point: CGPoint) -> Bool {
        let v = value(for: point)
        let r = v >= -0.0000001
        return r
    }
    
    var slope: CGFloat? {
        let t = tan(angle)
        return t.isNaN ? nil : t
    }
    
    var otherPoint: CGPoint {
        return CGPoint(x: 1000, y: 0).applying(transform.inverted())
    }
    
    var aPointInShade: CGPoint {
        return CGPoint(x: 0, y: 1000).applying(transform.inverted())
    }
    
    func applying(_ transform: CGAffineTransform) -> ShadedLine {
        let a = point.applying(transform)
        let b = otherPoint.applying(transform)
        
        let c = aPointInShade.applying(transform)
        
        return ShadedLine(points: a, b).with(pointInShade: c)
    }
    
    func parallelLine(shifted amount: CGFloat) -> ShadedLine {
        let t = transform.inverted()
        let a = CGPoint(x:    0, y: amount).applying(t)
        let b = CGPoint(x: 1000, y: amount).applying(t)
        return ShadedLine(points: a, b)
    }
    
}

extension CGRect {
    
    var shadedLines: [ShadedLine] {
        let a = CGPoint(x: minX, y: minY)
        let b = CGPoint(x: minX, y: maxY)
        let c = CGPoint(x: maxX, y: minY)
        let d = CGPoint(x: maxX, y: maxY)
        
        let left = ShadedLine(points: a, b).with(pointInShade: center)
        let top = ShadedLine(points: a, c).with(pointInShade: center)
        let right = ShadedLine(points: c, d).with(pointInShade: center)
        let bottom = ShadedLine(points: b, d).with(pointInShade: center)
        
        return [left, top, right, bottom]
    }
    
}

extension ShadedLine {
    
    func applying(_ transform: AffineTransform) -> ShadedLine {
        return self.applying(transform.cg)
    }
    
//    var floats: [Float] {
//        return transform.asPaddedFloats
//    }
    
}

//extension ShadedLine: MetalBuffer {
//
//    var length: Int {
//        return 32
//    }
//
//    var asData: Data {
//        return AffineTransform(transform).asData
//    }
//
//    func transformed(by transform: AffineTransform) -> ShadedLine {
//        return self.applying(transform)
//    }
//
//}

//extension Array where Element == ShadedLine {
//
//    var floats: [Float] {
//        return flatMap { $0.floats }
//    }
//
//}

