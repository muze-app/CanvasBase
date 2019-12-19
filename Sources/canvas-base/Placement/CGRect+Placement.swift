//
//  CGRect+Placement.swift
//  muze
//
//  Created by Greg Fajen on 10/16/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import UIKit

extension CGRect: Placement {
    
    var originalSize: CGSize { return size }
    var finalSize: CGSize { return size }
    
    var asSizeAndTransform: SizeAndTransform {
        return size & .translating(x: origin.x, y: origin.y)
    }
    
    var asDecomposed: DecomposedPlacement {
        return DecomposedPlacement(originalSize,
                                   center: center,
                                   widthScale: 1,
                                   heightScale: 1,
                                   rotation: 0)
    }
    
    func translatedBy(x: CGFloat, y: CGFloat) -> Placement {
        var r = self
        r.origin.x += x
        r.origin.y += y
        return r
    }
    
}
