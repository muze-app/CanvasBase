//
//  RenderPassDescriptor.swift
//  muze
//
//  Created by Greg on 2/10/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import UIKit
import Metal
import MetalPerformanceShaders
import MuzePrelude

protocol MetalPassTarget: class {
    
}

public class RenderPassDescriptor: AutoHash {
    
    var identifier: String
    let pipeline: MetalPipeline
    var target: RenderSurface!
    var fragmentBuffers: [MetalBuffer]
    var inputs: [RenderPayload]
    var clearColor: UIColor?
    
    let primitive: MTLPrimitiveType = .triangleStrip
    let vertexCount: Int = 4
    
    var inputExtent: SizeAndTransform? {
        let extent: RenderExtent = inputs.reduce(.nothing) { $0.union(with: $1.extent) }
        if let basic = extent.basic {
            return SizeAndTransform(basic)
        } else {
            return nil
        }
    }
    
    func vertexBuffer(for size: CGSize) -> MetalBuffer {
        guard var extent = inputExtent else { return MetalPipeline.defaultVertexBuffer }
        
        let transform = AffineTransform(from: .zero & size, to: CGRect(left: -1, top: -1, right: 1, bottom: 1), flipHorizontally: true, flipVertically: true)
        
        extent = extent.expanded(by: 2)
        extent = extent.transformed(by: transform)
        return extent.corners.flatMap { [Float(-$0.x), Float($0.y), 0] }
    }
    
    init(identifier: String,
         pipeline: MetalPipeline,
         fragmentBuffers: [MetalBuffer] = [],
         inputs: [RenderPayload] = [],
         clearColor: UIColor? = nil) {
        self.identifier = identifier
        self.pipeline = pipeline
        self.fragmentBuffers = fragmentBuffers
        self.inputs = inputs
        self.clearColor = clearColor
    }
    
    init(identifier: String,
         pipeline: MetalPipeline,
         fragmentBuffers: [MetalBuffer] = [],
         input: RenderPayload,
         clearColor: UIColor? = nil) {
        self.identifier = identifier
        self.pipeline = pipeline
        self.fragmentBuffers = fragmentBuffers
        self.inputs = [input]
        self.clearColor = clearColor
    }
    
    var timeStamp: TimeInterval? {
         return (inputs.map { $0.timeStamp }).compact.first
    }
    
    func transform(by transform: AffineTransform) {
        inputs = inputs.map { $0.transformed(by: transform) }
        fragmentBuffers = fragmentBuffers.map { $0.transformed(by: transform) }
    }
    
    func metalPass(_ completion: @escaping ()->() = {}) -> MetalPass<MetalTexture> {
        return metalPass(target.texture!, completion)
    }
    
    func metalPass<T>(_ drawable: T, _ completion: @escaping ()->() = {}) -> MetalPass<T> where T: SimpleMetalDrawable {
        var cropRects = [RenderCrop]()
        var params = [MetalBuffer]()
        var textures = [MTLTexture]()
        let fragmentBuffers: [MetalBuffer]
        
        if inputs.isEmpty {
            fragmentBuffers = self.fragmentBuffers
        } else {
            for input in inputs {
                let (texture, param, crops) = input.getParamsAndCrops(cropsSoFar: cropRects.count)
                cropRects.append(contentsOf: crops)
                
                params.append(param)
                textures.append(texture)
            }
            
            if cropRects.isEmpty {
                cropRects.append(RenderCrop(size: .zero, transform: .identity))
            }
            
            let cropBuffer: MetalBuffer = cropRects.flatMap { $0.asPaddedFloats }
            fragmentBuffers = [cropBuffer] + params + self.fragmentBuffers
        }
        
        let pass = MetalPass(pipeline: pipeline,
                         drawable: drawable,
                         primitive: primitive,
                         vertexCount: vertexCount,
                         clearColor: clearColor,
                         vertexBuffers: [vertexBuffer(for: drawable.size)],
                         fragmentBuffers: fragmentBuffers,
                         fragmentTextures: textures,
                         completion: completion)
        
        pass.identifier = identifier
        return pass
    }
    
    var fragmentTextures: [MTLTexture] {
        return inputs.map { return $0.texture!._texture }
    }
    
}

struct RenderDrawParams: MetalBuffer {
   
    var length: Int { return 72 }
    var asData: Data { /*return Data(from: self)*/ fatalError() }
    
    var ta, tb, tc, td, t1, t2: Float                       // 24
    var cropRectStart, cropRectCount: UInt16                // 28
    var alpha: Float                                        // 32
    var ct0, ct1, ct2, ct3, ct4, ct5, ct6, ct7, ct8: Float  // 68
    let padding: UInt32 = 0                                 // 72
    
    init() {
        ta = 1
        tb = 0
        tc = 0
        td = 1
        t1 = 0
        t2 = 0
        
        cropRectStart = 0
        cropRectCount = 0
        alpha = 1
        
        ct0 = 1
        ct1 = 0
        ct2 = 0
        ct3 = 0
        ct4 = 1
        ct5 = 0
        ct6 = 0
        ct7 = 0
        ct8 = 1
    }
    
    init(transform: AffineTransform, colorMatrix: DMatrix3x3, alpha: Float, cropRectStart: Int, cropRectCount: Int) {
        self.init()
        self.transform = transform
        self.colorMatrix = colorMatrix
        self.alpha = alpha
        self.cropRectStart = UInt16(cropRectStart)
        self.cropRectCount = UInt16(cropRectCount)
    }
    
    var transform: AffineTransform {
        get {
            return AffineTransform(__CGAffineTransformMake(CGFloat(ta), CGFloat(tb), CGFloat(tc), CGFloat(td), CGFloat(t1), CGFloat(t2)))
        }
        set {
            let t = newValue.cg
            ta = Float(t.a)
            tb = Float(t.b)
            tc = Float(t.c)
            td = Float(t.d)
            t1 = Float(t.tx)
            t2 = Float(t.ty)
        }
    }
    
    var colorMatrix: DMatrix3x3 {
        get {
            typealias D = Double
            return [[D(ct0),D(ct1),D(ct2)],[D(ct3),D(ct4),D(ct5)],[D(ct6),D(ct7),D(ct8)]]
        }
        
        set(m) {
            ct0 = Float(m[0][0])
            ct1 = Float(m[1][0])
            ct2 = Float(m[2][0])
            ct3 = Float(m[0][1])
            ct4 = Float(m[1][1])
            ct5 = Float(m[2][1])
            ct6 = Float(m[0][2])
            ct7 = Float(m[1][2])
            ct8 = Float(m[2][2])
        }
    }
    
}

extension RenderPayload {
    
    func getParamsAndCrops(cropsSoFar: Int) -> (MTLTexture,MetalBuffer,[RenderCrop]) {
        let (texture, alpha, transform, colorMatrix, crops) = getStuff
        
        let params = RenderDrawParams(transform: transform.inverse,
                                      colorMatrix: colorMatrix,
                                      alpha: alpha,
                                      cropRectStart: cropsSoFar,
                                      cropRectCount: crops.count)
        
        return (texture._texture, params, crops)
    }
    
    var getStuff: (MetalTexture,Float,AffineTransform,DMatrix3x3,[RenderCrop]) {
        switch self {
            case .texture(let texture):
                return (texture, 1, .identity, .identity, [])
                
            case .intermediate(let node):
                return (node.output.texture!, 1, .identity, .identity, [])
                
            case .alpha(let payload, let alpha):
                let (texture, oldAlpha, oldTransform, matrix, crops) = payload.getStuff
                return (texture, alpha * oldAlpha, oldTransform, matrix, crops)
                
            case .colorMatrix(let payload, let matrix):
                let (texture, alpha, transform, oldMatrix, crops) = payload.getStuff
                return (texture, alpha, transform, oldMatrix * matrix, crops)
                
            case .transforming(let payload, let transform):
                let (texture, alpha, oldTransform, matrix, crops) = payload.getStuff
                return (texture, alpha, oldTransform * transform, matrix, crops.map { $0.applying(transform) })
                
            case .cropAndTransform(let payload, let cropSize, let transform):
                var (texture, alpha, oldTransform, matrix, crops) = payload.getStuff
                crops = crops.map { $0.applying(transform) }
                crops.append(RenderCrop(size: cropSize, transform: transform))
                
                return (texture, alpha, oldTransform * transform, matrix, crops)
        }
    }
    
    var getTransform: (AffineTransform) {
        switch self {
            case .texture:
                return .identity
                
            case .intermediate:
                return  .identity
                
            case .alpha(let payload, _):
                return payload.getTransform
                
            case .colorMatrix(let payload, _):
                return payload.getTransform
                
            case .transforming(let payload, let transform):
                return payload.getTransform * transform
                
            case .cropAndTransform(let payload, _, let transform):
                return payload.getTransform * transform
        }
    }
    
}

extension ShadedLine {
    
    var asPaddedFloats: [Float] {
        return transform.asPaddedFloats
    }
    
}

public struct RenderCrop: Equatable {
    
    init(size: CGSize, transform: AffineTransform = .identity) {
        self.size = size
        self.transform = transform
    }
    
    init(rect: CGRect, transform: AffineTransform = .identity) {
        let translate = AffineTransform.translating(x: rect.origin.x, y: rect.origin.y)
        self.init(size: rect.size, transform: translate * transform)
    }
    
    var size: CGSize
    var transform: AffineTransform
    
    func applying(_ transform: AffineTransform) -> RenderCrop {
        return RenderCrop(size: size, transform: self.transform * transform)
    }
    
    var rect: CGRect {
        return .zero & size
    }
    
    var shadedLines: [ShadedLine] {
        return rect.shadedLines.map { $0.applying(transform) }
    }
    
    var asPaddedFloats: [Float] {
        return shadedLines.flatMap { $0.asPaddedFloats }
    }
    
    var corners: [CGPoint] {
        return rect.corners.map { $0.applying(transform.cg) }
    }
    
    func fullyContains(_ other: RenderCrop) -> Bool {
        for line in shadedLines {
            for corner in other.corners {
                if !line.pointIsInShade(corner) {
                    return false
                }
            }
        }
        
        return true
    }
    
}

extension RenderCrop: MetalBuffer {
    
    public var length: Int {
        return 128
    }
    
    public var asData: Data {
        return asPaddedFloats.asData
    }
    
}

class SpecialRenderPass: RenderPassDescriptor {
    
    let kernel: MPSImageGaussianBlur
    
    init(input: RenderPayload, kernel: MPSImageGaussianBlur) {
        self.kernel = kernel
        
        super.init(identifier: "blur", pipeline: .drawPipeline2, input: input)
    }
    
    override func metalPass<T>(_ drawable: T, _ completion: @escaping () -> () = {}) -> MetalPass<T> where T : SimpleMetalDrawable {
        let texture = inputs.first!.texture!
        return SpecialMetalPass(texture, drawable as! MetalTexture, kernel) as! MetalPass<T>
    }
    
}

class SpecialMetalPass: MetalPass<MetalTexture> {
    
    let kernel: MPSImageGaussianBlur
    
    init(_ input: MetalTexture, _ drawable: MetalTexture, _ kernel: MPSImageGaussianBlur) {
        self.kernel = kernel
        super.init(pipeline: .drawPipeline2,
                   drawable: drawable,
                   vertexBuffers: [],
                   fragmentTextures: [input._texture])
    }
    
    override func canAddToEncoder(_ encoder: MetalEncoder) -> Bool {
        return encoder.isEmpty
    }

    override func addToEncoder(_ encoder: MetalEncoder) {
        encoder.target = drawable._texture
        encoder.addInputFences([drawable.fence])
        encoder.push(.special(kernel, fragmentTextures[0], drawable._texture))
        
        assert(fragmentTextures[0] !== drawable._texture)
    }
    
}

extension SizeAndTransform {
    
    init(_ crop: RenderCrop) {
        self = crop.size & crop.transform
    }
    
    var renderCrop: RenderCrop {
        return RenderCrop(size: size, transform: transform)
    }
    
    static func ~ (l: SizeAndTransform, r: SizeAndTransform) -> Bool {
        return l.size ~= r.size && l.transform ~= r.transform
    }
    
}
