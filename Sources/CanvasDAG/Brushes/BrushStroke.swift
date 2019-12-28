//
//  BrushStroke.swift
//  GrabCutTest
//
//  Created by Greg on 10/18/18.
//

import MuzePrelude
import MuzeMetal

public class BrushStroke: MemoryManageeLeaf {
    
    public let defaultDab: AbstractDab
    public let spacing: CGFloat
    
    public static let defaultSpacing: CGFloat = 0.07
    
    public init(defaultDab: AbstractDab = AbstractDab(), spacing: CGFloat = BrushStroke.defaultSpacing) {
        self.defaultDab = defaultDab
        self.spacing = spacing
    }
    
    public var defaultDiameter: CGFloat { CGFloat(defaultDab.diameter) }
    public var actualSpacing: CGFloat { defaultDiameter * spacing }
    
    // MARK: Dabs
    
    public private(set) var dabs: [AbstractDab] = []
    
    public func append(dab: AbstractDab) {
        dabs.append(dab)
    }
    
    public func append(dabs: [AbstractDab]) {
        for dab in dabs {
            append(dab: dab)
        }
    }
    
    // MARK: Points
    
    public var points: [CGPoint] {
        return dabs.map { $0.point }
    }
    
    public func append(point: CGPoint) {
        var dab = defaultDab
        dab.point = point
        
        append(dab: dab)
    }
    
    public func append(points: [CGPoint]) {
        for point in points {
            append(point: point)
        }
    }
    
    // MARK: Memory Management
    
    public var memorySize: MemorySize {
        let dabSize = MemoryLayout<AbstractDab>.size
        return MemorySize(dabSize * (dabs.count + 1))
    }
    
    public let hashValue: Int = Int(arc4random())
    
}

public typealias MemorySize = MuzePrelude.MemorySize
