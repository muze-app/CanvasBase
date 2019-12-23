//
//  File.swift
//  
//
//  Created by Greg Fajen on 12/19/19.
//

import UIKit
import muze_prelude

public struct RenderCrop: Equatable {
    
    init(size: CGSize, transform: AffineTransform = .identity) {
        self.size = size
        self.transform = transform
    }
    
    init(rect: CGRect, transform: AffineTransform = .identity) {
        let translate = AffineTransform.translating(x: rect.origin.x, y: rect.origin.y)
        self.init(size: rect.size, transform: translate * transform)
    }
    
    var size: CGSize
    var transform: AffineTransform
    
    func applying(_ transform: AffineTransform) -> RenderCrop {
        return RenderCrop(size: size, transform: self.transform * transform)
    }
    
    var rect: CGRect {
        return .zero & size
    }
    
    var shadedLines: [ShadedLine] {
        return rect.shadedLines.map { $0.applying(transform) }
    }
    
//    var asPaddedFloats: [Float] {
//        return shadedLines.flatMap { $0.asPaddedFloats }
//    }
    
    var corners: [CGPoint] {
        return rect.corners.map { $0.applying(transform.cg) }
    }
    
    func fullyContains(_ other: RenderCrop) -> Bool {
        for line in shadedLines {
            for corner in other.corners {
                if !line.pointIsInShade(corner) {
                    return false
                }
            }
        }
        
        return true
    }
    
}
