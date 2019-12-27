//
//  ConcreteDab.swift
//  muze
//
//  Created by Greg on 1/3/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation

struct ConcreteDab {
    
    var x: Float
    var y: Float
    var radius: Float
    var exponent: Float
    
    var color: DabColor
    var opacity: Float
    
    var components: [Float] {
//        float2 position;
//        float radius, exponent;
//        float4 color;
        
        return [x,y,radius,exponent] + color.components + [opacity]
    }
}
