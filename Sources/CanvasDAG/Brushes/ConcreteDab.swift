//
//  ConcreteDab.swift
//  muze
//
//  Created by Greg on 1/3/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

//import MuzePrelude

public struct ConcreteDab {
    
    public var x: Float
    public var y: Float
    public var radius: Float
    public var exponent: Float
    
    public var color: DabColor
    public var opacity: Float
    
    public var components: [Float] {
//        float2 position;
//        float radius, exponent;
//        float4 color;
        
        return [x,y,radius,exponent] + color.components + [opacity]
    }
}
