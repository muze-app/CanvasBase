//
//  MetalPipeline+Effects.swift
//  muze
//
//  Created by Greg Fajen on 2/25/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation

extension FragmentFunction {
    
    static let invert     = FragmentFunction(name: "invert_fragment")
    static let exposure   = FragmentFunction(name: "exposure_fragment")
    static let gamma      = FragmentFunction(name: "gamma_fragment")
    static let saturation = FragmentFunction(name: "saturation_fragment")
    static let hue        = FragmentFunction(name: "hue_fragment")
    static let bulge      = FragmentFunction(name: "bulge_fragment")
    static let contrast   = FragmentFunction(name: "contrast_fragment")
    
}

extension MetalPipeline {
    
    static let invertPipeline     = MetalPipeline(vertex: .basic, fragment: .invert)
    static let exposurePipeline   = MetalPipeline(vertex: .basic, fragment: .exposure)
    static let gammaPipeline      = MetalPipeline(vertex: .basic, fragment: .gamma)
    static let saturationPipeline = MetalPipeline(vertex: .basic, fragment: .saturation)
    static let huePipeline        = MetalPipeline(vertex: .basic, fragment: .hue)
    static let bulgePipeline      = MetalPipeline(vertex: .basic, fragment: .bulge)
    static let contrastPipeline   = MetalPipeline(vertex: .basic, fragment: .contrast)
    
}
