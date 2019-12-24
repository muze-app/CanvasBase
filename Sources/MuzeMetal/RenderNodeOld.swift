//
//  RenderNodeOld.swift
//  muze
//
//  Created by Greg on 2/10/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import UIKit
import Metal

public class RenderNodeOld: AutoHash {
    
    public let identifier: String
    
    init(identifier: String, pixelFormat: MTLPixelFormat = .bgra8Unorm) {
        self.identifier = identifier
//        output = RenderSurface(pixelFormat: pixelFormat, size: size)
    }
    
//    init(identifier: String, texture: MTLTexture, croppable: AbstractCroppable) {
//        self.identifier = identifier
//        output = RenderSurface(texture: texture, croppable: croppable)
//    }
    
//    convenience init(identifier: String, texture: MTLTexture, size: CGSize) {
//        let croppable = AbstractCroppable(originalSize: size)
//        self.init(identifier: identifier, texture: texture, croppable: croppable)
//    }
   
//    var _dependencies: [RenderPayload] = []
    var _passes: [RenderPassDescriptor] = []
    
    public var passes: [RenderPassDescriptor] { return _passes }
    public var dependencies: [RenderPayload] { return passes.flatMap { $0.inputs } }
    
//    var _outputCanBeReused: Bool = true
//    var outputCanBeReused: Bool {
//        get {
//            if !_outputCanBeReused { return false }
//            if output.cacheData.exists { return false }
//            if output.texture.exists { return false }
////            if output.croppable != RenderSurface.defaultCroppable { return false }
//
//            #warning("fix me")
//            return false
//        }
//
//        set {
//            _outputCanBeReused = newValue
//        }
//    }
//
//    var outputCanBeReset: Bool {
//        if !outputCanBeReused { return false }
//
//        for pass in passes {
//            if pass.target !== output {
//                return false
//            }
//        }
//
//        return true
//    }
    
//    func resetOutput(_ drawable: RenderDrawable) {
//        if !outputCanBeReset { return }
//
//        output = drawable
//        for pass in passes {
//            pass.target = drawable
//        }
//    }
    
}

protocol AutoHash: class, Hashable { }
extension AutoHash {
    
    public var hashValue: Int {
        let unsafe = Unmanaged.passUnretained(self).toOpaque()
        return unsafe.hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(hashValue)
    }
    
    public static func == (rhs: Self, lhs: Self) -> Bool {
        return rhs === lhs
    }
    
}

extension RenderPayload {
    
    func flatten(drawables: inout Set<RenderSurface>, passes: inout [RenderPassDescriptor]) {
        switch self {
            case .texture:
                break
                
            case .intermediate(let intermediate):
                intermediate.flatten(drawables: &drawables, passes: &passes)
                
            case .colorMatrix(let payload, _):
                payload.flatten(drawables: &drawables, passes: &passes)
                
            case .alpha(let payload, _):
                payload.flatten(drawables: &drawables, passes: &passes)
                
            case .cropAndTransform(let payload, _, _):
                payload.flatten(drawables: &drawables, passes: &passes)
                
            case .transforming(let payload, _):
                payload.flatten(drawables: &drawables, passes: &passes)
        }
    }
    
    var timeStamp: TimeInterval? {
        switch self {
            case .texture(let t): return t.timeStamp
            case .intermediate(let i): return i.timeStamp
                
            case .colorMatrix(let p, _): return p.timeStamp
            case .alpha(let p, _): return p.timeStamp
            case .cropAndTransform(let p, _, _): return p.timeStamp
            case .transforming(let p, _): return p.timeStamp
        }
    }
    
}
