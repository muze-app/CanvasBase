//
//  RenderInstance.swift
//  muze
//
//  Created by Greg Fajen on 2/18/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import MuzePrelude
import Metal

public class RenderInstance {
    
//    public static var tempRect: CGRect?
    
    typealias CompletionType = RenderManager.CompletionType
    
    func render(_ payload: RenderPayload,
                _ options: RenderOptions,
                _ completion: @escaping CompletionType) {
        
        _start(.renderInstance)
        
        let (intermediate, transform) = normalize(payload, options)
        let renderNode: RenderIntermediate
        switch intermediate {
            case .l(let i):
                renderNode = i
            case .r(let t):
    //            DispatchQueue.
    //            DispatchQueue.main.async {
                    completion((t,transform))
    //            }
                _end(.renderInstance)
                return
        }
        
        let (drawables, passes) = renderNode.flatten()
        assert(passes.count > 0)
        
        passes.last!.target!.canAlias = false
        
        if isDebugging {
            print("DRAWABLES")
            for drawable in drawables {
                print(" - \(drawable) \(String(describing: drawable.identifier)) \(drawable.pointerString) \(drawable.size)")
            }
            
            print("PASSES")
            for pass in passes {
                print(" - \(pass) \(pass.identifier)")
                print("        \(String(describing: pass.inputExtent))")
            }
        }
        
        _start(.encoders)
        let encoders = self.encoders(for: passes)
        _end(.encoders)
        _start(.commandBuffer)
        let buffer = self.commandBuffer(for: encoders)
        _end(.commandBuffer)
        
        buffer.addCompletionHandler { _ in
            _end(.gpu)
            let result: TextureAndTransform = (renderNode.texture!, transform)
            self.complete(result: result, drawables, options, completion)
            
            for pass in passes {
                pass.target.texture?.isInUseByRenderer = false
            }
        }
        
        _start(.gpu)
        buffer.commit()
        _end(.renderInstance)
    }
    
    func encoders(for passes: [RenderPassDescriptor]) -> [MetalEncoder] {
        var encoder = MetalEncoder()
        var encoders = [encoder]
        
        if isDebugging {
            print("Encoder 0")
        }
        
        var remainingPasses = passes
        var allocatedSurfaces = [RenderSurface]()
        
        for pass in passes {
            remainingPasses.removeFirst()
            
            let surface = pass.target!
            let needsAllocation = surface.needsToAllocateTexture
            if needsAllocation {
                surface.allocateTextureIfNeeded()
                surface.texture?.isInUseByRenderer = true
                surface.timeStamp = pass.timeStamp
                if surface.canAlias {
                    allocatedSurfaces.append(surface)
                }
            }
            
            let metalPass = pass.metalPass()
            
            if !metalPass.canAddToEncoder(encoder) {
                encoder = MetalEncoder()
                encoders.append(encoder)
                if isDebugging {
                    print("Encoder \(encoders.count-1)")
                }
            }
            
            encoder.outputFence = pass.target.fence
            encoder.addInputFences( pass.inputs.compactMap { $0.fence } )
            
            metalPass.addToEncoder(encoder)
            
            let surfacesToAlias = allocatedSurfaces - remainingPasses.usedSurfaces
            for surface in surfacesToAlias {
                surface.texture!.makeAliasable()
            }
            
            allocatedSurfaces -= surfacesToAlias
            
            if isDebugging {
                print("   Pass \(pass.identifier)")
                
                let texture = metalPass.drawable.texture
                print("       target: \(pass.target.identifier ?? texture.pointerString)")
                print("       load action: \(metalPass.loadAction)")
            }
        }
        
        return encoders
    }
    
    func commandBuffer(for encoders: [MetalEncoder]) -> MetalCommandBuffer {
        let buffer = MetalCommandBuffer()
        
        for encoder in encoders {
            encoder.addToCommandBuffer(buffer)
        }
        
        return buffer
    }
    
    func normalize(_ payload: RenderPayload, _ options: RenderOptions) -> IntermediateAndTransform {
        
        let intermediateAndTransform = payload.intermediateAndTransform
        
        let extent: BasicExtent
        
        switch options.mode {
            case .normalized(let size):
                if var (intermediate, transform) = intermediateAndTransform,
                    intermediate.size == size,
                    transform ~= .identity,
                    intermediate.tryToSetPixelFormat(options.outputFormat.rawValue) {
                    transform = .identity
                    let r = (intermediate, transform)
                    return r
                } else if var (intermediate, transform) = intermediateAndTransform,
                    intermediate.tryToSetPixelFormat(options.outputFormat.rawValue),
                    let i = intermediate.l,
                    !i.isCache {
                    
                    _ = i.normalize(from: transform, for: size)
                    transform = .identity
                    return (.l(i), transform)
                } else {
                    extent = BasicExtent(size: size, transform: .identity)
                }
                
            case .usingExtent:
                if var (intermediate, transform) = intermediateAndTransform,
                    intermediate.tryToSetPixelFormat(options.outputFormat.rawValue) {
                    let r = (intermediate, transform)
                    transform = .identity
                    return r
                } else {
                    if let basic = payload.extent.basic {
                        extent = basic
                    } else {
                        if let texture = payload.texture {
                            extent = .init(size: texture.size)
                        } else {
                            fatalError()
                        }
                    }
                }
        }
        
        let normal = RenderIntermediate(identifier: "Normalize", options: options, extent: .basic(extent))
        normal << RenderPassDescriptor(identifier: "Normalize",
                                       pipeline: .drawPipeline2,
                                       inputs: [payload])
        normal.pixelFormat = options.outputFormat.rawValue
        
        return (.l(normal), normal.postCropTransform)
    }
    
    func complete(result: TextureAndTransform,
                  _ drawables: Set<RenderSurface>,
                  _ options: RenderOptions,
                  _ completion: @escaping CompletionType) {
        
        DispatchQueue.global().async {
            completion(result)
        }
        
//        RenderManager.shared.queue.async {
//            RenderManager.shared.instances.removeAll { $0 === self }
//        }
    }
    
    let isDebugging: Bool = false
    
}

public extension MTLTexture {
    
    var firstPixelIsWhite: Bool {
        let bytesPerRow = width * 4
        let region = MTLRegionMake2D(0, 0, 1, 1)
        
        var buffer: [UInt8] = [0,0,0,0]
        
        getBytes(&buffer, bytesPerRow: bytesPerRow, from: region, mipmapLevel: 0)
        
        return buffer == [255,255,255,255]
    }
     
}

public extension RenderPayload {
    
    var fence: MTLFence? {
        switch self {
            case .intermediate(let node): return node.output.fence
            case .texture(let texture): return texture.fence
            case .colorMatrix(let p, _): return p.fence
            case .alpha(let p, _): return p.fence
            case .transforming(let p, _): return p.fence
            case .cropAndTransform(let p, _, _): return p.fence
        }
    }
    
    // will return nil if we definitely need another renderpass to normalize
    var intermediateAndTransform: IntermediateAndTransform? {
        switch self {
            case .texture(let t):
                return (.r(t), .identity)
                
            case .intermediate(let i):
                return (.l(i), .identity)
                
            case .colorMatrix:
                return nil
                
            case .alpha:
                return nil
                
            case let .transforming(p, t2):
                if let (i,t1) = p.intermediateAndTransform {
                    return (i, t1*t2)
                } else {
                    return nil
                }
                
            case let .cropAndTransform(p, s, t2):
                if p.cropCount > 0 {
                    return nil
                }
                
                if let (i,t1) = p.intermediateAndTransform,
                    i.size == s,
                    t1 ~= .identity {
                    return (i, t2)
                } else {
                    return nil
                }
        }
    }
    
    var cropCount: Int {
        switch self {
            case .texture:
                return 0
            case .intermediate:
                return 0
                
            case .colorMatrix(let p, _):
                return p.cropCount
            case .alpha(let p, _):
                return p.cropCount
                
            case .transforming(let p, _):
                return p.cropCount
                
            case .cropAndTransform(let p, _, _):
                return p.cropCount + 1
        }
    }
    
}

public enum Either<L,R> {
    case l(L)
    case r(R)
    
    public var l: L? {
        switch self {
            case .l(let l): return l
            case .r: return nil
        }
    }
    
    public var r: R? {
        switch self {
            case .l: return nil
            case .r(let r): return r
        }
    }
    
}

public typealias AffineTransform = MuzePrelude.AffineTransform

public typealias TextureAndTransform = (MetalTexture,AffineTransform)
public typealias IntermediateAndTransform = (IntermediateOrTexture,AffineTransform)
public typealias IntermediateOrTexture = Either<RenderIntermediate,MetalTexture>

public extension IntermediateOrTexture {
    
    var size: CGSize {
        switch self {
            case .l(let i): return i.output.size
            case .r(let t): return t.size
        }
    }
    
    var texture: MetalTexture! {
        switch self {
            case .l(let i): return i.output.texture
            case .r(let t): return t
        }
    }
    
    var pixelFormat: MTLPixelFormat {
        switch self {
            case .l(let i): return i.pixelFormat
            case .r(let t): return t.pixelFormat
        }
    }
    
    mutating func tryToSetPixelFormat(_ pixelFormat: MTLPixelFormat) -> Bool {
        if self.pixelFormat == pixelFormat { return true }
        
        switch self {
            case .r: return false
            case .l(let i):
                i.pixelFormat = pixelFormat
                self = .l(i)
                return true
        }
    }
    
}

public extension RenderPayload {
    
    var extent: RenderExtent {
        switch self {
            case .texture:
                return .infinite
            case .intermediate:
                return .infinite
                
            case .colorMatrix(let p, _):
                return p.extent
            case .alpha(let p, _):
                return p.extent
                
            case .transforming(let p, let t):
                let e = p.extent
                return e.transformed(by: t)
            case .cropAndTransform(_, let s, let t):
                return .basic(BasicExtent(size: s, transform: t))
        }
    }
    
}

extension Array where Element == RenderPassDescriptor {
    
    var usedIntermediates: [RenderIntermediate] {
        return flatMap { $0.inputs.compactMap { $0.intermediate } }
    }
    
    var usedSurfaces: [RenderSurface] {
        return usedIntermediates.map { $0.output }
    }
    
}

extension Array where Element: AnyObject {
    
    static func -= <T:Sequence>(lhs: inout [Element], rhs: T) where T.Element == Element {
        lhs = lhs.filter {
            let e = $0
            return !rhs.contains { e === $0 }
        }
    }
    
}
