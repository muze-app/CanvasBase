//
//  CGRect+MiscFunctionality.swift
//  muze
//
//  Created by Grant Davis on 6/27/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import UIKit

public extension CGRect {
    static let screen: CGRect = UIScreen.main.bounds
    
    init(left: CGFloat, top: CGFloat, right: CGFloat, bottom: CGFloat) {
        self.init(x: left, y: top, width: right-left, height: bottom-top)
    }
    
    var center: CGPoint {
        let x = origin.x + size.width/2
        let y = origin.y + size.height/2
        return CGPoint(x: x, y: y)
    }
    
    var aspectRatio: CGFloat {
        return size.aspectRatio
    }
    
    func inset(by amount: CGFloat) -> CGRect {
        return insetBy(dx: amount, dy: amount)
    }
    
    // anchor (0.5, 0.5) = centered
    func relativeRect(size targetSize: CGSize, anchor: CGPoint = CGPoint(x: 0.5, y: 0.5)) -> CGRect {
        let xd = size.width - targetSize.width
        let yd = size.height - targetSize.height
        
        let x = origin.x + xd * anchor.x
        let y = origin.y + yd * anchor.y
        let o = CGPoint(x: x, y: y)
        
        return CGRect(origin: o, size: targetSize)
    }
    
    func rectThatFills(_ targetAspectRatio: CGFloat, anchor: CGPoint = CGPoint(x: 0.5, y: 0.5)) -> CGRect {
        if aspectRatio == targetAspectRatio {
            return self
        }
        
        let targetSize = size.sizeThatFills(targetAspectRatio)
        return relativeRect(size: targetSize, anchor: anchor)
    }
    
    func rectThatFits(_ targetAspectRatio: CGFloat, anchor: CGPoint = CGPoint(x: 0.5, y: 0.5)) -> CGRect {
        if aspectRatio == targetAspectRatio {
            return self
        }
        
        let targetSize = size.sizeThatFits(targetAspectRatio)
        return relativeRect(size: targetSize, anchor: anchor)
    }
    
    func subtract(y:CGFloat) -> CGRect {
        return CGRect(x: self.minX, y: self.minY - y, width: self.width, height: self.height)
    }
    
    /// returns what the size would be were it to have no rotation transform. The angle input should be based upon a CGAffineTransform, the specific function being: 'angle = atan2(transform.b, transform.a)'. NOTE: You should probably use the UIView version if available because it is simpler and faster.
    func unrotatedSize(forAngle angle: CGFloat) -> CGSize {
        let quadrantAngle = angle.truncatingRemainder(dividingBy: .pi/2)
        let Θ: CGFloat
        if quadrantAngle <= 0 {
            Θ = -quadrantAngle
        } else {
            Θ = .pi/2-quadrantAngle
        }
        
        let H = self.height
        let W = self.width
        
        let cosΘ  = cos(Θ)
        let sinΘ  = sin(Θ)
        let cos2Θ = cos(2*Θ)
        
        let w = (W*cosΘ-H*sinΘ)/cos2Θ
        let h = (H*cosΘ-W*sinΘ)/cos2Θ

        let unrotatedWidth : CGFloat
        let unrotatedHeight: CGFloat
        
        let hemiAngle = angle.truncatingRemainder(dividingBy: .pi)
        let viewIsLeaningBackward = (abs(hemiAngle) > .pi/2) == (hemiAngle > 0)
        if viewIsLeaningBackward {
            unrotatedWidth  = w
            unrotatedHeight = h
        } else { // <=> if viewIsLeaningForward
            unrotatedWidth  = h
            unrotatedHeight = w
        }
        
        return CGSize(width: unrotatedWidth, height: unrotatedHeight)
    }
    
    /// returns what the frame would be were it to have no rotation transform. The angle input should be based upon a CGAffineTransform, the specific function being: 'angle = atan2(transform.b, transform.a)'. NOTE: You should probably use the UIView version if available because it is simpler and faster.
    func unrotatedFrame(forAngle Θ: CGFloat) -> CGRect {
        let unrotatedSize = self.unrotatedSize(forAngle: Θ)
        let w = unrotatedSize.width
        let h = unrotatedSize.height
        
        let x = 0.5*(self.width-w)+self.minX
        let y = 0.5*(self.height-h)+self.minY
        
        return CGRect(x: x, y: y, width: w, height: h)
    }
}
