//
//  Blendable.swift
//  muze
//
//  Created by Greg Fajen on 4/18/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import MuzePrelude

public protocol Blendable {
    
    func blend(with other: Self, _ t: Float) -> Self
    
}

extension Blendable {
    
    func blend<T: BinaryFloatingPoint>(with other: Self, _ t: T) -> Self {
        return blend(with: other, Float(t))
    }
    
}

extension Float: Blendable {
    
    public func blend(with target: Float, _ amount: Float) -> Float {
        let source = self
        let diff = target - source
        return source + diff * amount
    }
    
}

extension CGFloat: Blendable {
    
    public func blend(with target: CGFloat, _ amount: Float) -> CGFloat {
        let source = self
        let diff = target - source
        return source + diff * CGFloat(amount)
    }
    
}

extension CGPoint: Blendable {
    
    public func blend(with target: CGPoint, _ amount: Float) -> CGPoint {
        let source = self
        let rx = source.x.blend(with: target.x, amount)
        let ry = source.y.blend(with: target.y, amount)
        return CGPoint(x: rx, y: ry)
    }
    
}
