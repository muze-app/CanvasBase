//
//  BrushContext.swift
//  muze
//
//  Created by Greg Fajen on 5/19/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import MuzePrelude
import MuzeMetal

public struct BrushContext: MemoryManagee, Equatable {
    
    public static func == (lhs: BrushContext, rhs: BrushContext) -> Bool {
        return true
    }
    
    public let stroke: BrushStroke
    public let interpolator: DabInterpolator
    public let realizer: DabRealizer
    
    public init(defaultDab: AbstractDab, spacing: CGFloat = 0.07) {
        let       stroke = BrushStroke(defaultDab: defaultDab, spacing: spacing)
        let interpolator = DabInterpolator(stroke: stroke)
        let     realizer = DabRealizer(interpolator: interpolator)
        
        self.stroke       = stroke
        self.interpolator = interpolator
        self.realizer     = realizer
    }
    
    public var memoryHash: MemoryHash {
        return stroke.memoryHash
    }
    
}
