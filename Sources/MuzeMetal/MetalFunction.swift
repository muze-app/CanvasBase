//
//  MetalFunction.swift
//  muze
//
//  Created by Greg on 1/3/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

//import UIKit
import Metal
import MetalKit

public class MetalFunction {
    
    public let name: String
    let function: MTLFunction
    
    public init(name: String) {
        self.name = name
        
        guard let function = MetalDevice.library.makeFunction(name: name) else {
            fatalError("Unable to find Metal function named '\(name)'")
        }
        
        self.function = function
    }
    
}

public class VertexFunction: MetalFunction {
    
    public static let basic = VertexFunction(name: "basic_vertex")
    public static let brush = VertexFunction(name: "brush_vertex")
    
}

public class FragmentFunction: MetalFunction { }
    
public extension FragmentFunction {
    
    static let draw             = FragmentFunction(name: "draw_fragment")
    static let draw2            = FragmentFunction(name: "draw_fragment2")
    static var reorient: FragmentFunction { return FragmentFunction(name: "reorient_fragment") }
    static let raw              = FragmentFunction(name: "raw_fragment")
    static let inverseDraw      = FragmentFunction(name: "inverse_draw_fragment")
    static let mask             = FragmentFunction(name: "mask_fragment")
    static let mix              = FragmentFunction(name: "mix_fragment")
    static let inverseMask      = FragmentFunction(name: "inverse_mask_fragment")
    static let maskColor        = FragmentFunction(name: "mask_color_fragment")
    static let inverseMaskColor = FragmentFunction(name: "inverse_mask_color_fragment")
    static let YUVDown          = FragmentFunction(name: "YUV_down_fragment")
    static let YUVUp            = FragmentFunction(name: "YUV_up_fragment")
    static let brush            = FragmentFunction(name: "brush_fragment")
    static let liveDraw         = FragmentFunction(name: "livedraw_brush_fragment")
    static let canvasOverlay    = FragmentFunction(name: "canvas_overlay")
    static let oldCanvasOverlay = FragmentFunction(name: "old_canvas_overlay")
    static let rects            = FragmentFunction(name: "rects")
    static let checkerboard     = FragmentFunction(name: "checkerboard_fragment")
    static let colorMatrix      = FragmentFunction(name: "color_matrix_fragment")
    static let sRGBColorMatrix  = FragmentFunction(name: "sRGB_color_matrix_fragment")
    
    @available (*, deprecated)
    static let blit             = FragmentFunction(name: "blit_fragment")
    
}

public class MetalDevice {
    
    public static let device: MTLDevice = MTLCreateSystemDefaultDevice()!
    static let library: MTLLibrary = device.makeDefaultLibrary()!
    public static let commandQueue: MTLCommandQueue = device.makeCommandQueue()!
 
    static func textureFrom(_ url: URL) -> MTLTexture {
        let loader = MTKTextureLoader(device: MetalDevice.device)
        let texture = try! loader.newTexture(URL: url, options: nil)
        return texture
    }
    
}
