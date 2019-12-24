//
//  DecomposedPlacement.swift
//  muze
//
//  Created by Greg Fajen on 10/16/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import UIKit

public struct DecomposedPlacement: Placement {
    
    public var center: CGPoint
    public var rotation: CGFloat
    
    public var originalSize: CGSize
    public var widthScale: CGFloat
    public var heightScale: CGFloat

    public var finalSize: CGSize {
        return CGSize(width: originalSize.width * widthScale,
                      height: originalSize.height * heightScale)
    }
    
    public static func normalize(_ angle: CGFloat) -> CGFloat {
        let d = CGFloat.pi
        let r = angle.truncatingRemainder(dividingBy: d)
        return r >= 0 ? r : r + d
    }
    
    public init(_ originalSize: CGSize, center: CGPoint, widthScale: CGFloat = 1, heightScale: CGFloat = 1, rotation: CGFloat = 0) {
        self.originalSize = originalSize
        self.center = center
        self.rotation = DecomposedPlacement.normalize(rotation)
        self.widthScale = widthScale
        self.heightScale = heightScale
    }
    
    public init(_ sizeAndTransform: SizeAndTransform) {
        let decomp = sizeAndTransform.transform.decomposition

        center = sizeAndTransform.center
        self.rotation = DecomposedPlacement.normalize(decomp.rotation.angle)
        
        originalSize = sizeAndTransform.size
        widthScale = decomp.scale.x
        heightScale = decomp.scale.y
    }
    
    public var asSizeAndTransform: SizeAndTransform {
        let t1 = AffineTransform.translating(x: -originalSize.width/2, y: -originalSize.height/2)
        let t2 = AffineTransform.translating(x: center.x, y: center.y)
        let r = AffineTransform.rotating(rotation)
        let s = AffineTransform.scaling(x: widthScale, y: heightScale)
        
        var result = originalSize & (t1 * s * r * t2)

        if result.finalSize.width ~= -finalSize.width {
            let center = result.center
            
            result = result.transformed(by: .translating(x: -center.x, y: -center.y))
            result = result.transformed(by: .scaling(x: -1, y: -1))
            result = result.transformed(by: .translating(x: center.x, y: center.y))
        }
        
        return result
    }
    
    public var asDecomposed: DecomposedPlacement {
        return self
    }
    
    // MARK: -
    
    public static func ~ (l: DecomposedPlacement, r: DecomposedPlacement) -> Bool {
        return l.center ~= r.center
            && l.originalSize ~= r.originalSize
            && l.rotation ~= r.rotation
            && l.widthScale ~= r.widthScale
            && l.heightScale ~= r.heightScale
    }
    
    public func contains(_ point: CGPoint) -> Bool {
        // can be sped up
        return asSizeAndTransform.contains(point)
    }
    
    public var corners: [CGPoint] {
        // can be sped up
        return asSizeAndTransform.corners
    }
    
    public func translatedBy(x: CGFloat, y: CGFloat) -> Placement {
        var c = self
        c.center.x += x
        c.center.y += y
        return c
    }
    
}

infix operator •: MultiplicationPrecedence
infix operator ~ : ComparisonPrecedence
infix operator × : MultiplicationPrecedence
