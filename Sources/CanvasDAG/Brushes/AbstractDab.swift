//
//  AbstractDab.swift
//  muze
//
//  Created by Greg on 1/3/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import UIKit
import MuzeMetal

public typealias Blendable = MuzeMetal.Blendable

public struct AbstractDab: Equatable, Blendable {
    
    public var point: CGPoint = .zero
    public var diameter: Float = 60
    public var hardness: Float = 0.95
    
    public var color: DabColor = .white
    public var opacity: Float = 1
    
    public init(point: CGPoint = .zero,
                diameter: Float = 60,
                hardness: Float = 0.95,
                color: DabColor = .white,
                opacity: Float = 1) {
        
//        #if MZE_DEBUG
//        guard hardness < 1 else {
//            fatalError("hardness doesn't actually go up to one, it needs to be slightly less")
//        }
//        #endif
        
        self.point = point
        self.diameter = diameter
        self.hardness = hardness
        self.color = color
        self.opacity = opacity
    }
    
    public var x: CGFloat { point.x }
    
    public var y: CGFloat { point.y }
    
    public func with(color: DabColor) -> AbstractDab {
        var copy = self
        copy.color = color
        return copy
    }
    
    public func blend(with target: AbstractDab, _ amount: Float) -> AbstractDab {
        var result = AbstractDab()
        result.point = point.blend(with: target.point, amount)
        result.diameter = diameter.blend(with: target.diameter,  amount)
        result.hardness = hardness.blend(with: target.hardness,  amount)
        result.color = color.blend(with: target.color,  amount)
        result.opacity = opacity.blend(with: target.opacity,  amount)
        
        return result
    }
    
}

public struct DabColor: Equatable, Blendable {
    
    public let red: Float
    public let green: Float
    public let blue: Float

    public static var white: DabColor { return DabColor(red: 1, green: 1, blue: 1) }
    public static var black: DabColor { return DabColor(red: 0, green: 0, blue: 0) }
    
    public init(red: Float, green: Float, blue: Float) {
        self.red = red
        self.green = green
        self.blue = blue
    }
    
    public init(color: UIColor) {
        let color = color.converted(to: .displayP3Space, intent: .absoluteColorimetric)
        
        var r: CGFloat = 1
        var g: CGFloat = 1
        var b: CGFloat = 1
        var a: CGFloat = 1
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        r = RenderColor2.linearize(sRGB: r)
        g = RenderColor2.linearize(sRGB: g)
        b = RenderColor2.linearize(sRGB: b)
        
        self.init(red: Float(r), green: Float(g), blue: Float(b))
    }
    
    public var uiColor: UIColor {
        
        let r = RenderColor2.delinearize(sRGB: red)
        let g = RenderColor2.delinearize(sRGB: green)
        let b = RenderColor2.delinearize(sRGB: blue)
        
        return UIColor(displayP3Red: CGFloat(r),
                       green: CGFloat(g),
                       blue:  CGFloat(b),
                       alpha: 1.0)
    }
    
//    init(color: CGColor) {
//        let c = color.components!.map { return Float($0) }
//        self.init(red: c[0], green: c[1], blue: c[2])
//    }
    
    public func blend(with target: DabColor, _ amount: Float) -> DabColor {
        let r = red.blend(with: target.red, amount)
        let g = green.blend(with: target.green, amount)
        let b = blue.blend(with: target.blue, amount)
        return DabColor(red: r, green: g, blue: b)
    }
    
    public var components: [Float] { [red, green, blue] }
    
    public var luma: Float { 0.2989 * red + 0.5870 * green + 0.1140 * blue }
    
}
