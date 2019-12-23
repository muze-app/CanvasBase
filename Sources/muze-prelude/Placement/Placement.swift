//
//  Placement.swift
//  muze
//
//  Created by Greg Fajen on 10/11/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import UIKit

public protocol Placement {
    
    var asSizeAndTransform: SizeAndTransform { get }
    var asDecomposed: DecomposedPlacement { get }
    
    func contains(_ point: CGPoint) -> Bool
    var corners: [CGPoint] { get }
    
    var originalSize: CGSize { get }
    var finalSize: CGSize { get }
    
    var center: CGPoint { get }
    var origin: CGPoint { get }
    
    func transformed(by transform: AffineTransform) -> Placement
    func translatedBy(x: CGFloat, y: CGFloat) -> Placement
    
    func with(origin: CGPoint) -> Placement
    func with(center: CGPoint) -> Placement
    
    var minX: CGFloat { get }
    var maxX: CGFloat { get }
    var minY: CGFloat { get }
    var maxY: CGFloat { get }
    
}

public protocol Placeable: UIView {
    
    var isPlacing: Bool { get set }
    var placement: Placement { get set }
    
}

public extension Placement {
    
    var containingRect: CGRect {
        let corners = self.corners
        let xs = corners.map { $0.x } .sorted()
        let ys = corners.map { $0.y } .sorted()
        
        return CGRect(left: floor(xs.first!),
                      top: floor(ys.first!),
                      right: ceil(xs.last!),
                      bottom: ceil(ys.last!))
    }
    
    var bounds: CGRect {
        return CGRect(origin: .zero, size: originalSize)
    }
    
    var xs: [CGFloat] { return corners.map { $0.x } }
    var ys: [CGFloat] { return corners.map { $0.y } }
    
    var minX: CGFloat { return xs.minimum }
    var maxX: CGFloat { return xs.maximum }
    
    var minY: CGFloat { return ys.minimum }
    var maxY: CGFloat { return ys.maximum }
    
    var center: CGPoint { return corners.average }
    var origin: CGPoint { return CGPoint.zero.applying(asSizeAndTransform.transform.cg) }
    
    var transform: AffineTransform { return self.asSizeAndTransform.transform }
    
    func with(center: CGPoint) -> Placement {
        let current = self.center
        let target = center
        let offset = target-current
        let result = translatedBy(x: offset.x, y: offset.y)
        
        print("current: \(current)")
        print("target: \(target)")
        print("result: \(result)")
        print(".center: \(result.center)")
        
        assert(result.center ~= center)
        return result
    }
    
    func with(origin: CGPoint) -> Placement {
        let current = self.origin
        let target = origin
        let offset = target-current
        let result = translatedBy(x: offset.x, y: offset.y)
        
        print("current: \(current)")
        print("target: \(target)")
        print("result: \(result)")
        print(".center: \(result.origin)")
        
        assert(result.origin ~= origin)
        return result
    }
    
}
 
extension SizeAndTransform: Placement {
    
    public var originalSize: CGSize {
        return size
    }
    
    public func contains(_ point: CGPoint) -> Bool {
        fatalError()
//        return renderCrop.contains(point)
    }
    
    public var asSizeAndTransform: SizeAndTransform {
        return self
    }
    
    public var asDecomposed: DecomposedPlacement {
        return DecomposedPlacement(self)
    }
    
    public func translatedBy(x: CGFloat, y: CGFloat) -> Placement {
        return transformed(by: .translating(x: x, y: y))
    }
    
}

public extension Placeable {
    
    var placement: Placement {
        get {
            return bounds.size & transform
        }
        
        set {
            isPlacing = true
            
            layer.anchorPoint = .zero
            transform = .identity
            
            let sizeAndTransform = newValue.asSizeAndTransform
            frame = .zero & sizeAndTransform.size
            bounds = .zero & sizeAndTransform.size
            transform = sizeAndTransform.transform.cg
            
            isPlacing = false
        }
    }
    
}

public extension Array where Element == CGFloat {
    
    var sum: Element {
        return reduce(0, +)
    }
    
    var average: Element {
        return sum / CGFloat(count)
    }
    
}

public extension Array where Element == CGPoint {
    
    var xs: [CGFloat] { return map{ $0.x } }
    var minX: CGFloat { return xs.minimum }
    var maxX: CGFloat { return xs.maximum }
    
    var ys: [CGFloat] { return map{ $0.y } }
    var minY: CGFloat { return ys.minimum }
    var maxY: CGFloat { return ys.maximum }
    
    var containingRect: CGRect {
        return CGRect(left: minX, top: minY, right: maxX, bottom: maxY)
    }
    
}

public extension Array where Element == CGPoint {
    
    var average: CGPoint {
        return CGPoint(x: xs.average, y: ys.average)
    }
    
}

public extension Placement {
    
    func converted(from: PlacementContext, to: PlacementContext) -> Placement {
        let transform = from.transformToScreen * to.transformFromScreen
        return self.transformed(by: transform)
    }
    
    func converted(from: UIView, to: UIView) -> Placement {
        return converted(from: .init(from), to: .init(to))
    }
    
    func transformed(by transform: AffineTransform) -> Placement {
        return asSizeAndTransform.transformed(by: transform)
    }
    
}

public struct PlacementContext {
    
    let transformToScreen: AffineTransform
    var transformFromScreen: AffineTransform { return transformToScreen.inverse }
    
    init(_ transformToScreen: AffineTransform) {
        self.transformToScreen = transformToScreen
    }
    
    init(_ view: UIView) {
        fatalError()
//        let zeroZero = view.convert(CGPoint(x: 0, y: 0), to: nil)
//        let zeroOne  = view.convert(CGPoint(x: 0, y: 1), to: nil)
//        let  oneZero = view.convert(CGPoint(x: 1, y: 0), to: nil)
//
//        self = .init(AffineTransform(mystery: zeroZero, zeroOne, oneZero))
    }
    
    static let screen: PlacementContext = .init(.identity)
    
}
