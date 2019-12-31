////
////  LayerManager+Output.swift
////  muze
////
////  Created by Greg on 2/9/19.
////  Copyright © 2019 Ergo Sum. All rights reserved.
////
//
////import CanvasBase
//
////typealias InternalSnapshot = CanvasBase.InternalDirectSnapshot<CanvasNodeCollection>
//
////@available(*, deprecated)
////typealias InternalDirectSnapshot = InternalSnapshot
//
//extension LayerManager {
//
////    func checkHistory(graph: InternalSnapshot) {
////
////        if let pred = graph.predecessor {
////            let pred = pred as! InternalDirectSnapshot
////            checkHistory(graph: pred)
////        }
////
////        let subgraphData = graph.subgraphs[subgraphKey]
////        print("GRAPH \(graph.key) (lv\(graph.level)")
////        print("    data: \(subgraphData)")
////    }
//
////    func processCommit(graph: MutableGraph) {
////        let subgraphOne = graph.subgraph(for: subgraphKey)
////        let subgraphZero = graph.lower.subgraph(for: subgraphKey)
////        subgraphOne.finalKey = subgraphZero.finalKey
////
//////        addCacheNodes(subgraphOne)
////        optimize(subgraphOne)
////    }
//
////    func previousCacheNodes(for graph: Graph) -> [NodeKey] {
////        fatalError()
////        guard let parent = graph.parent(at: 1) else { return [] }
////        guard let final = parent.subgraph(for: subgraphKey).finalNode else { return [] }
////
////        return final.all(as: CacheNode.self).map { $0.originalKey }
////    }
//
////    func addCacheNodes(_ subgraph: Subgraph) {
////        fatalError()
////        let old = previousCacheNodes(for: subgraph.graph)
////        let new = keysToCache(for: subgraph.graph)
////
//////        print("old: \(old)")
//////        print("new: \(new)")
////        let keys = old + new
////
////        subgraph.finalNode = subgraph.finalNode?.addingCacheNodes(keys)
////    }
//
////    @available(*, deprecated)
////    func optimize(_ subgraph: Subgraph) {
////        fatalError()
//////        subgraph.finalNode = subgraph.finalNode?.optimize(throughCacheNodes: true)
////    }
//
//
////    var compositingNode: BlendNode { return displayLayer.compositingNode }
////    var captionCompositingNode: BlendNode { return displayLayer.captionCompositingNode }
//
////    func renderNode(for options: RenderOptions) -> RenderNodeOld? {
////        return nodeToRender?.renderNode(for: options)
////    }
//
//    var nodeToRender: Node? {
//        return nil
////        if let node = mainNodeToRender, let caption = captionToRender {
////            captionCompositingNode.alpha = 1
////            captionCompositingNode.blendMode = .normal
////
////            captionCompositingNode.source = caption
////            captionCompositingNode.destination = node
////            return captionCompositingNode
////        }
////
////
////        return mainNodeToRender ?? captionToRender
//    }
//
//    var shouldCache: Bool {
//        return false
////        return (node?.count ?? 0) > 5
//    }
//
//    var mainNodeToRender: Node? {
//        fatalError()
////        if hideActiveNode, let activeNode = activeNode {
////            if let activeInputNode = activeNode as? OldInputNode {
////                let node = activeInputNode.primaryInput
////
//////                if shouldCache, let node = node {
//////                    return CacheNode(node, owner: self)
//////                } else {
////                    return node
//////                }
////            }
////
////            return nil
////        }
//
////        if shouldCache, let activeNode = activeNode as? InputNode, let input = activeNode.primaryInput {
////            let cache = CacheNode(input, owner: self)
////            return activeNode.with(input: cache)
////        }
//
////        let node = displayLayer.node
////        if shouldCache, let node = node {
////            return CacheNode(node, owner: self)
////        }
//
////        return node
//    }
//
//    var captionToRender: Node? {
////        if let caption = caption {
////            print("layer has caption \(caption.key)")
////            print("    activeNode: \(String(describing: canvasManager?.activeNode))")
////            print("    hide active node: \(hideActiveNode)")
////        }
////
////        if captionIsActive {
////            return nil
////        }
//        fatalError()
////        return caption
//    }
//
//    var cacheKey: NodeKey? {
//        fatalError()
////        if activeNode.exists {
////            return lastCacheKey
////        }
////
////
////
////        if let node = displayLayer.node as? TransformNode {
////            lastCacheKey = node.input?.key
////        } else {
////            lastCacheKey = displayLayer.node?.key
////        }
////
////        return lastCacheKey
//    }
//
//
//
//    var activeNode: Node? {
//        fatalError()
////        guard let path = canvasManager?.activeNode, path.layerKey == key else { return nil }
////
////        return displayLayer.find(nodeFor: path.nodeKey)
//    }
//
//    var hasActiveNode: Bool {
//        return activeNode.exists
//    }
//
//    var captionIsActive: Bool {
//        return false
////        guard let captionKey = caption?.key else { return false }
////        guard let path = canvasManager?.activeNode else { return false }
////
////        return path.layerKey == key && path.nodeKey == captionKey
//    }
//
//}
//
////extension LayerManager: RenderCacheOwner {
////
////    var hotCaches: Set<NodeKey> {
////        return Set(cacheKey)
////    }
////
////    func cacheWillBeRendered(_ key: NodeKey) {
//////        cacheKey = key
////    }
////
////
////}
//
//
//
////extension DAG {
////
////    var lower: DAG {
////        massert(level > 0)
////        return self.modify(level: level-1) { _ in }
////    }
////
////}
