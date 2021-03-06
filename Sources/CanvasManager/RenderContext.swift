//
//  RenderContext.swift
//  muze
//
//  Created by Greg Fajen on 4/19/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import MuzeMetal
import CanvasDAG

public protocol RenderableNode {
    
    func renderPayload(for options: RenderOptions) -> RenderPayload?
    
}

//typealias FirstGraph = NodeGraph
//typealias FinalGraph = NodeGraph

open class RenderContext {
    
//    lazy var graph1 = FirstGraph()
//    lazy var graph2 = FinalGraph()
    
    public init() { }
    
//    func wrap(node: Node, for colorSpace: RenderOptions.ColorSpace, sRGB: Bool) -> Node {
//        if colorSpace == .cam16, sRGB == false { return node }
//
//        let matrix = colorSpace.matrix(from: .cam16)
//        let matrixNode = ColorMatrixNode(.init(matrix: matrix, sRGB: sRGB))
//        matrixNode.input = node
//
//        return matrixNode
//    }
    
//    let cache = CacheAndOptimizer()
    
    var caches: [SubgraphKey:CacheAndOptimizer] = [:]
    
    func cache(for subgraph: SubgraphKey) -> CacheAndOptimizer {
        if let cache = caches[subgraph] { return cache }
        
        let cache = CacheAndOptimizer(subgraph)
        caches[subgraph] = cache
        
        return cache
    }
    
    // swiftlint:disable:next function_parameter_count
    public func render(graph: Graph,
                       subgraph: SubgraphKey,
                       canvasSize: CGSize,
                       time: TimeInterval,
                       caching keysToCache: [NodeKey] = [],
                       optimize: Bool = true,
                       format: RenderOptions.PixelFormat,
                       colorSpace: RenderOptions.ColorSpace,
                       completion: @escaping CompletionType) {
        
        if !RenderInstance.tempRect.exists {
            if let extent = graph.store.read({ graph.subgraph(for: subgraph).finalNode?.calculatedRenderExtent }), let bounds = extent.basic?.corners.containingRect {
                RenderInstance.tempRect = bounds
            } else {
                print("WTF")
            }
        }
        
//        fatalError()
//        graph1.keysToCache.formUnion(keysToCache)
//        graph2.keysToCache.formUnion(keysToCache)

//        let node = wrap(node: node, for: colorSpace, sRGB: !format.isLinear)
//        let result = update(with: node, setRoot: true, optimize: optimize)
        let options = RenderOptions("context", size: canvasSize, format: format, time: time)

//        print("time: \(options.time) \(time)")

//        let finalNode = node.finalNode
//        finalNode.log()

//        let store = graph.store
//        store.modLock.lock()
        
        let store = graph.store
        let cache = self.cache(for: subgraph)
        
//        let optimized = graph.optimized(throughCacheNodes: false)
        
//        var finalNode: Node?
//        _ = graph.modify { graph in
//            finalNode = graph.finalNode(for: subgraph) //?.optimize(throughCacheNodes: false)
//        }
        
        let payload = store.write { () -> RenderPayload in
            let optimized = cache.march(graph).subgraph(for: subgraph)
            return optimized.finalNode?.renderPayload(for: options) ?? clearPayload
        }
        
//        store.modLock.unlock()

        let manager = RenderManager.shared
        manager.render(payload, options) { (result) in
//            graph.store.cacheStore.finalize()
//            self.graph1.finalizeCaches(keeping: [])
//            self.graph2.finalizeCaches(keeping: keysToCache)
            
            cache.finalize()

            if result.0.pixelFormat != format.rawValue {
                print("expected \(format.rawValue), received \(result.0.pixelFormat)")
            }

            result.0.colorSpace = colorSpace
            assert(result.0.pixelFormat == format.rawValue)
            completion(result)
        }
    }
    
    func render(intermediateNode node: Graph,
                time: TimeInterval = 0,
                format: RenderOptions.PixelFormat = .float16,
                colorSpace: RenderOptions.ColorSpace = .working,
                completion: @escaping CompletionType) {
        
        fatalError()
        
//        let node = wrap(node: node, for: colorSpace, sRGB: !format.isLinear)
//        let result = update(with: node, setRoot: false, optimize: true)
        
//        let payload: RenderPayload
//        let options = RenderOptions("context", mode: .usingExtent, format: format, time: time)
//        if let load = node.finalNode.renderPayload(for: options) {
//            payload = load
//        } else {
//            let options = RenderOptions("context", size: CGSize(8), format: format, time: time)
//            payload = clearNode.renderPayload(for: options)!
//        }
//        
//        let manager = RenderManager.shared
//        manager.render(payload, options) { (result) in
//            result.0.colorSpace = colorSpace
//            assert(result.0.pixelFormat == format.rawValue)
//            completion(result)
//        }
    }
    
    public typealias CompletionType = RenderManager.CompletionType
    
    var clearPayload: RenderPayload {
        .texture(MetalSolidColorTexture(.clear).texture)
    }
    
//    func update(with node: Node, setRoot: Bool, optimize: Bool) -> Node {
//        fatalError()
////        guard let r1 = graph1.update(with: node, setRoot: setRoot) else { return clearNode }
////        r1.foreach { $0.updateGeneratedInput() }
////        updateAnimations()
////
////        let r2 = graph2.update(with: r1, setRoot: setRoot, optimize: optimize)
////        return r2 ?? clearNode
//    }
    
    // MARK: Animations
    
//    var animations: [NodeAnimationBase] = []
//
//    func add(animation: NodeAnimationBase) {
//        remove(animationsFor: animation.key)
//        animations.append(animation)
//    }
//
//    func animation(for key: NodeKey) -> NodeAnimationBase? {
//        return animations.first { $0.key == key }
//    }
//
//    func remove(animationsFor key: NodeKey) {
//        animations = animations.filter { $0.key != key }
//    }
    
    func updateAnimations() {
//        for animation in animations {
//            if let node = graph1[animation.key] {
//                animation.update(node)
//            } else {
//                if let node = graph1.root?.first(where: { $0.key == animation.key }) {
//                    graph1.add(node: node)
//                    animation.update(node)
//                } else {
//                    animation.keepAround = false
//                }
//            }
//        }
//        
//        animations = animations.filter { !$0.isCompleted || $0.keepAround }
    }
   
}
