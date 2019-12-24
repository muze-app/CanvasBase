//
//  RenderIntermediate.swift
//  muze
//
//  Created by Greg Fajen on 5/7/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import UIKit
import MetalKit
import MuzePrelude

public class RenderIntermediate: RenderNodeOld {
    
    public let options: RenderOptions
    public var extent: RenderExtent
    
    private var _pixelFormat: MTLPixelFormat
    public var pixelFormat: MTLPixelFormat {
        get { return _pixelFormat }
        set {
            _pixelFormat = newValue
            output.pixelFormat = newValue
        }
    }
    
    public var canAlias: Bool {
        get { return output.canAlias }
        set { output.canAlias = newValue }
    }
    
    public var isCache: Bool = false
    
    private var _output: RenderSurface?
    public var output: RenderSurface {
        if let output = _output { return output }
        
        _output = RenderSurface(size: renderSize, pixelFormat: pixelFormat, identifier: identifier)
        return _output!
    }
    
    public var basicExtent: BasicExtent {
        return extent.basic ?? optionsExtent
    }
    
    public var optionsExtent: BasicExtent {
        switch options.mode {
            case .normalized(let size):
                return BasicExtent(size: size, transform: .identity)
            default:
                fatalError()
        }
    }
    
    public var croppable: CropSandwich {
        let extent = basicExtent
        
        let croppable = CropSandwich(preCropTransform: extent.transform.inverse,
                                          cropSize: extent.size,
                                          postCropTransform: extent.transform)
        
        var size = croppable.finalSize
        
        let maxSide = CGFloat(2048)
        let max = maxSide*maxSide
        if size.area > max {
            size = CGSize.init(aspectRatio: croppable.cropSize.aspectRatio,
                              area: max)
        }
        
        size.width = round(size.width)
        size.height = round(size.height)
        
        return croppable.resized(to: size)
    }
    
    public var preCropTransform: AffineTransform {
        return croppable.preCropTransform
    }
    
    public var renderSize: CGSize {
        return croppable.cropSize
    }
    
    public var postCropTransform: AffineTransform {
        return croppable.postCropTransform
    }
    
    public init(identifier: String, options: RenderOptions, extent: RenderExtent, pixelFormat: MTLPixelFormat = .rgba16Float) {
        self.options = options
        self.extent = extent
        self._pixelFormat = pixelFormat
        
        super.init(identifier: identifier)
    }
    
    public var texture: MetalTexture? {
        return output.texture
    }
    
    public func add(pass: RenderPassDescriptor) {
        _passes.append(pass)
        pass.target = output
        
        pass.transform(by: preCropTransform)
    }
    
    public static func << (lhs: RenderIntermediate, rhs: RenderPassDescriptor) {
        lhs.add(pass: rhs)
    }
    
    public var payload: RenderPayload {
        return .cropAndTransform(.intermediate(self), renderSize, postCropTransform)
    }
    
    func flatten() -> (Set<RenderSurface>, [RenderPassDescriptor]) {
        var drawables = Set<RenderSurface>()
        var passes = [RenderPassDescriptor]()
        
        flatten(drawables: &drawables, passes: &passes)
        
        return (drawables, passes)
    }
    
    func flatten(drawables: inout Set<RenderSurface>, passes: inout [RenderPassDescriptor]) {
        for dependency in dependencies {
            dependency.flatten(drawables: &drawables, passes: &passes)
        }
        
        drawables.insert(output)
        
        for pass in self.passes {
            if !passes.contains(pass) {
                passes.append(pass)
            }
        }
    }
    
    // different from just transforming
    func normalize(from transform: AffineTransform, for size: CGSize) -> Bool {
//        let inverse = transform.inverse
        
        for pass in passes {
            pass.transform(by: transform)
        }
        
        extent = .basic(.init(size: size))
        
        if _output.exists {
            _output?.size = renderSize
        }
        
        return true
    }
    
    var timeStamp: TimeInterval? {
        return passes.reduce(nil) { $0 ?? $1.timeStamp }
//        
//        return passes.reduce(nil, { (result: TimeInterval?, pass: RenderPassDescriptor) -> TimeInterval? in
//            return result ?? pass.timeStamp
//        })
    }
    
}

extension RenderPayload: Equatable {
    
    public static func == (lhs: RenderPayload, rhs: RenderPayload) -> Bool {
        switch (lhs, rhs) {
            
            case let (.texture(t1), .texture(t2)): return t1 === t2
            case let (.intermediate(i1), .intermediate(i2)): return i1 === i2
            
            case let (.alpha(p1, f1), .alpha(p2, f2)): return f1 ~= f2 && p1 == p2
            case let (.transforming(p1, t1), .transforming(p2, t2)): return t1 == t2 && p1 == p2
            case let (.cropAndTransform(p1, s1, t1), .cropAndTransform(p2, s2, t2)): return s1 ~= s2 && t1 == t2 && p1 == p2
            
            default: return false
        }
    }
    
}
