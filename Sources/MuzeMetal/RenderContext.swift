//
//  RenderContext.swift
//  muze
//
//  Created by Greg Fajen on 4/19/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import UIKit
import Metal

//typealias FirstGraph = NodeGraph
//typealias FinalGraph = NodeGraph

public class RenderContext {
    
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
    
    /*
    
    func render(graph: DAG,
                subgraph: SubgraphKey,
                canvasSize: CGSize,
                time: TimeInterval,
                caching keysToCache: [NodeKey] = [],
                optimize: Bool = true,
                format: RenderOptions.PixelFormat,
                colorSpace: RenderOptions.ColorSpace,
                completion: @escaping CompletionType) {
        
//        fatalError()
//        graph1.keysToCache.formUnion(keysToCache)
//        graph2.keysToCache.formUnion(keysToCache)

//        let node = wrap(node: node, for: colorSpace, sRGB: !format.isLinear)
//        let result = update(with: node, setRoot: true, optimize: optimize)
        let options = RenderOptions("context", size: canvasSize, format: format, time: time)

//        print("time: \(options.time) \(time)")

//        let finalNode = node.finalNode
//        finalNode.log()

//        let optimized = graph.optimized(throughCacheNodes: false)
        
        var finalNode: DNode?
        _ = graph.modify { graph in
            finalNode = graph.finalNode(for: subgraph) //?.optimize(throughCacheNodes: false)
        }
        
        let payload = finalNode?.renderPayload(for: options) ?? clearPayload

        let manager = RenderManager.shared
        manager.render(payload, options) { (result) in
            graph.store?.cacheStore.finalize()
//            self.graph1.finalizeCaches(keeping: [])
//            self.graph2.finalizeCaches(keeping: keysToCache)

            if result.0.pixelFormat != format.rawValue {
                print("expected \(format.rawValue), received \(result.0.pixelFormat)")
            }

            result.0.colorSpace = colorSpace
            assert(result.0.pixelFormat == format.rawValue)
            completion(result)
        }
    }
    
    func render(intermediateNode node: InternalDirectSnapshot,
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
    */
    
    typealias CompletionType = RenderManager.CompletionType
    
    var clearPayload: RenderPayload {
        return .texture(MetalSolidColorTexture(.clear).texture)
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

extension RenderOptions.PixelFormat {
    
    var isLinear: Bool {
        switch self {
            case .extended: return true
            case .float16: return true
            case .float32: return true
            case .sixteen: return false
            case .sRGB: return true
        }
    }
    
}
