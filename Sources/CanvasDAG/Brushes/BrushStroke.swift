//
//  BrushStroke.swift
//  GrabCutTest
//
//  Created by Greg on 10/18/18.
//

import UIKit
import MuzeMetal

public class BrushStroke: MemoryManageeLeaf {
    
    public let defaultDab: AbstractDab
    public let spacing: CGFloat
    
    public static let defaultSpacing: CGFloat = 0.07
    
    public init(defaultDab: AbstractDab = AbstractDab(), spacing: CGFloat = BrushStroke.defaultSpacing) {
        self.defaultDab = defaultDab
        self.spacing = spacing
    }
    
    var defaultDiameter: CGFloat { CGFloat(defaultDab.diameter) }
    var actualSpacing: CGFloat { defaultDiameter * spacing }
    
    // MARK: Dabs
    
    private var _dabs: [AbstractDab] = []
    var dabs: [AbstractDab] {
        return _dabs
    }
    
    func append(dab: AbstractDab) {
        _dabs.append(dab)
    }
    
    func append(dabs: [AbstractDab]) {
        for dab in dabs {
            append(dab: dab)
        }
    }
    
    // MARK: Points
    
    var points: [CGPoint] {
        return dabs.map { $0.point }
    }
    
    func append(point: CGPoint) {
        var dab = defaultDab
        dab.point = point
        
        append(dab: dab)
    }
    
    func append(points: [CGPoint]) {
        for point in points {
            append(point: point)
        }
    }
    
    // MARK: Memory Management
    
    public var memorySize: MemorySize {
        let dabSize = MemoryLayout<AbstractDab>.size
        return MemorySize(dabSize * (_dabs.count + 1))
    }
    
    public let hashValue: Int = Int(arc4random())
    
}

public typealias MemorySize = MuzePrelude.MemorySize
