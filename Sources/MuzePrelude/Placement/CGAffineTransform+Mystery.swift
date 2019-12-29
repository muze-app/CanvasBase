//
//  CGAffineTransform+Mystery.swift
//  muze
//
//  Created by Greg Fajen on 10/13/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import UIKit

public extension CGAffineTransform {
    
    init(mystery zeroZero: CGPoint, _ zeroOne: CGPoint, _ oneZero: CGPoint) {
        let tx = zeroZero.x
        let ty = zeroZero.y
        let a = oneZero.x - zeroZero.x
        let b = oneZero.y - zeroZero.y
        let c = zeroOne.x - zeroZero.x
        let d = zeroOne.y - zeroZero.y
        
        self.init(a: a, b: b, c: c, d: d, tx: tx, ty: ty)
    }
    
}

public extension AffineTransform {
    
    init(mystery zeroZero: CGPoint, _ zeroOne: CGPoint, _ oneZero: CGPoint) {
        self = AffineTransform(.init(mystery: zeroZero, zeroOne, oneZero))
    }
        
}
