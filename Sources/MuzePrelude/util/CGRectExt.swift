//
//  File.swift
//  
//
//  Created by Greg Fajen on 12/19/19.
//

#if os(macOS)
import AppKit
#else
import UIKit
#endif

public extension CGRect {
    
    @inlinable
    var corners: [CGPoint] {
        let w = width
        let h = height
        return [.init(x: 0, y: 0),
                .init(x: w, y: 0),
                .init(x: 0, y: h),
                .init(x: w, y: h)]
    }
    
}

infix operator ** : MultiplicationPrecedence

public extension Array {
    
    static func ** <B>(lhs: [Element], rhs: [B]) -> [(Element, B)] {
        var result = [(Element, B)]()
        for a in lhs {
            for b in rhs {
                result.append((a, b))
            }
        }
        
        return result
    }
    
}

public extension CGSize {
    
    init(aspectRatio: CGFloat, area: CGFloat) {
        // h * h * r = a
        // h * r = w
        
        let h = sqrt(area/aspectRatio)
        let w = h * aspectRatio
        
        self = CGSize(width: w, height: h)
    }
    
    var area: CGFloat {
        return width * height
    }
    
    var rounded: CGSize {
        return CGSize(width: round(width), height: round(height))
    }
    
    static func & (lhs: CGPoint, rhs: CGSize) -> CGRect {
        return CGRect(origin: lhs, size: rhs)
    }
    
}
