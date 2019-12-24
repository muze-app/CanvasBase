//
//  RenderManager.swift
//  muze
//
//  Created by Greg on 2/10/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import UIKit
import Metal

public class RenderManager {

    public static let shared = RenderManager()
//    static var activeRenders = [String]()
    
    let payloadQueue = DispatchQueue(label: "RenderManagerPayloads")
    
    let queue = DispatchQueue(label: "RenderManager",
                              qos: .userInitiated,
                              attributes: DispatchQueue.Attributes(),
                              autoreleaseFrequency: .workItem,
                              target: nil)
    
    public typealias ResultType = TextureAndTransform
    public typealias CompletionType = (ResultType)->()
    
//    var instances = [RenderInstance]()
    
//    func render(_ node: DNode,
//                _ options: RenderOptions,
//                _ completion: @escaping CompletionType) {
//        payloadQueue.async {
//            if let payload = node.renderPayload(for: options) {
//                self.render(payload, options, completion)
//            } else {
//                let texture = MetalSolidColorTexture(.clear).texture
//                completion((texture, .identity))
//            }
//        }
//    }
    
    public func render(_ payload: RenderPayload,
                       _ options: RenderOptions,
                       _ completion: @escaping CompletionType) {
        queue.async {
            let instance = RenderInstance()
//            self.instances.append(instance)
            
            instance.render(payload, options, completion)
        }
    }
    
//    static let drawablePool = DrawablePool<MetalOffscreenDrawable>(initializer: {
//        return MetalOffscreenDrawable(size: CanvasLayout.canvasSize, scale: 1)
//    })
//
//    static let maskDrawablePool = DrawablePool<MetalOffscreenDrawable>(initializer: {
//        return MetalOffscreenDrawable(size: CanvasLayout.canvasSize, scale: 1, pixelFormat: .r8Unorm)
//    })
//
//    var tempDrawables: [MetalOffscreenDrawable] = []
    
//    static var memoryHash: MemoryHash {
//        return drawablePool.memoryHash + maskDrawablePool.memoryHash
//    }
//    
//    var memoryHash: MemoryHash {
//        return RenderManager.memoryHash
//    }
    
}

public extension MTLTexture {
    
    var hashValue: Int {
        let unsafe = Unmanaged.passUnretained(self).toOpaque()
        return unsafe.hashValue
    }
    
    var pointerString: String {
        let unsafe = Unmanaged.passUnretained(self).toOpaque()
        return "\(unsafe)"
    }
    
}

extension RenderSurface {
    
    var pointerString: String {
        let unsafe = Unmanaged.passUnretained(self).toOpaque()
        return "\(unsafe)"
    }
    
}
