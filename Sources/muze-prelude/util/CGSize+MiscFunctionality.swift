//
//  CGSize+MiscFunctionality.swift
//  muze
//
//  Created by Grant Davis on 7/9/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import UIKit

public extension CGSize {
    
    static let screenCenter: CGPoint = UIScreen.main.bounds.center
    
    var aspectRatio: CGFloat {
        return width / height
    }
    
    func sizeThatFills(_ targetAspectRatio: CGFloat) -> CGSize {
        if aspectRatio == targetAspectRatio {
            return self
        }
        
        // we're wider than the target
        if aspectRatio > targetAspectRatio {
            let h = width / targetAspectRatio
            return CGSize(width: width, height: h)
        }
        
        // we're taller than the target
        let w = height * targetAspectRatio
        return CGSize(width: w, height: height)
    }
    
    func sizeThatFits(_ targetAspectRatio: CGFloat) -> CGSize {
        if aspectRatio == targetAspectRatio {
            return self
        }
        
        // we're taller than the target
        if aspectRatio < targetAspectRatio {
            let h = width / targetAspectRatio
            return CGSize(width: width, height: h)
        }
        
        // we're wider than the target
        let w = height * targetAspectRatio
        return CGSize(width: w, height: height)
    }
    
    static func *(lhs: CGSize, rhs: CGFloat) -> CGSize {
        return CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
    }
    
}
