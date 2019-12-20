//
//  DAG.swift
//  muze
//
//  Created by Greg Fajen on 9/2/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation

// todo:
// decide either:
// - require all access + mutation to require a specific level
// - or, lock off certain columns of data
//        (ie, you can't modify the payload of an object in l0 from l1)

typealias MutableDAG = InternalDirectSnapshot

class DAG {
    
    final let key: CommitKey
    var store: DAGStore { fatalError() }
    var depth: Int { die }
    var level: Int { die }
    var maxLevel: Int { die }
    
    init(_ key: CommitKey = .init()) {
        self.key = key
    }
    
    func parent(at level: Int) -> DAG? { die }
    
//    func subgraph(for key: SubgraphKey) -> Subgraph { }
//    func subgraphData(for key: SubgraphKey) -> SubgraphData? { }
//    func subgraphData(for key: SubgraphKey, level: Int) -> SubgraphData? { }
    var allSubgraphKeys: Set<SubgraphKey> { die }
//
    func finalKey(for subgraph: SubgraphKey) -> NodeKey? { die }
//    func finalNode(for subgraph: SubgraphKey) -> Node? { }
    func metaKey(for subgraph: SubgraphKey) -> NodeKey? { die }
//    func metaNode(for subgraph: SubgraphKey) -> Node? { }
//
//    func node(for key: NodeKey) -> Node { }
    func type(for key: NodeKey) -> DNodeType? { die }

//    func payloadAllocation(for key: NodeKey, level: Int) -> PayloadBufferAllocation? { }
//    func payloadPointer(for key: NodeKey, level: Int) -> UnsafeMutableRawPointer? { }
    func payload<T>(for key: NodeKey, of type: T.Type) -> T? { die }

    var die: Never { fatalError() }
    
    func edgeMap(for key: NodeKey, level: Int) -> [Int: NodeKey]? { die }
//    func input(for parent: NodeKey, index: Int) -> NodeKey? { die }
//    func inputNode(for parent: NodeKey, index: Int) -> Node? { die }
//
    func reverseEdges(for key: NodeKey) -> Bag<NodeKey>? { die }
//    func revData(for key: NodeKey) -> NodeRevData? { die }
//    func setRevData(_ data: NodeRevData, for key: NodeKey) { die }
//
//    var modLock: NSRecursiveLock? { die }
//    func  alias(_ block: (MutableDAG)->()) -> InternalDirectSnapshot { die } // use carefully!
//    func modify(_ block: (MutableDAG)->()) -> InternalDirectSnapshot { die }
//    func modify(level: Int, _ block: (MutableDAG)->()) -> InternalDirectSnapshot { die }
//    func modify(as key: CommitKey?, level: Int, _ block: (MutableDAG)->()) -> InternalDirectSnapshot { die }
//    func importing(_ other: DAG) -> ImportSnapshot { die }
//
//    var snapshotToModify: DAG { die } // either InternalSnapshot or GraphCombiner
//
//    func contains(allocations: Set<PayloadBufferAllocation>) -> Bool { die }
//    func contains(textures: Set<MetalTexture>) -> Bool
    
//}


//protocol MutableDAG: DAG {
//
//    func setType(_ type: DNodeType, for key: NodeKey)
//    func setPayload<T: NodePayload>(_ payload: T, for key: NodeKey)
//    func setEdgeMap(_ edgeMap: [Int:NodeKey], for key: NodeKey)
//    func setInput(for parent: NodeKey, index: Int, to child: NodeKey?)
//
//    func setFinalKey(_ key: NodeKey?, for subgraph: SubgraphKey)
//    func setFinalNode(_ node: Node?, for subgraph: SubgraphKey)
//    func setMetaKey(_ key: NodeKey?, for subgraph: SubgraphKey)
//    func setMetaNode(_ node: Node?, for subgraph: SubgraphKey)
//
//    func setReverseEdges(_ bag: Bag<NodeKey>, for key: NodeKey)
//
//}
    
//    func payload<T>(for key: NodeKey, of type: T.Type) -> T? {
//        guard let raw = payloadPointer(for: key, level: level) else { return nil }
//        let pointer = raw.assumingMemoryBound(to: T.self)
//        return pointer.pointee
//    }
    
    // PRECONDITION: node must exist in graph or will crash
    func node(for key: NodeKey) -> Node {
        guard let type = type(for: key) else { die }
        
        switch type {
            default: die
//            case .color: return CNode(key, graph: self)
//            case .string: return SNode(key, graph: self)
//            case .canvasOverlay: return CanvasOverlayNode(key, graph: self)
//            case .image: return ImageNode(key, graph: self)
//            case .blend: return BlendNode(key, graph: self)
//            case .rects: return RectsNode(key, graph: self)
//            case .blurPreview: return BlurPreviewNode(key, graph: self)
//            case .solidColor: return SolidColorNode(key, graph: self)
//            case .transform: return TransformNode(key, graph: self)
//            case .canvasMeta: return CanvasMetaNode(key, graph: self)
//            case .layerMeta: return LayerMetaNode(key, graph: self)
//            case .brush: return BrushNode(key, graph: self)
//            case .maskedColor: return MaskedColorNode(key, graph: self)
//            case .effect: return EffectNode(key, graph: self)
//            case .mask: return MaskNode(key, graph: self)
//            case .comp: return CompositeNode(key, graph: self)
//            case .alpha: return AlphaNode(key, graph: self)
//            case .colorMatrix: return ColorMatrixNode(key, graph: self)
//            case .maskSeries: return MaskSeriesNode(key, graph: self)
//            case .cache: return CacheNode(key, graph: self)
//            case .checkerboard: return CheckerboardNode(key, graph: self)
        }
    }
    
    func subgraph(for key: SubgraphKey) -> Subgraph {
        return Subgraph(key: key, graph: self)
    }
    
    func subgraphData(for key: SubgraphKey) -> SubgraphData? {
        die
//        return subgraphData(for: key, level: level)
    }
    
    var allSubgraphs: [Subgraph] {
        die
//        return allSubgraphKeys.map { subgraph(for: $0) }
    }
    
    func finalNode(for subgraph: SubgraphKey) -> Node? {
        die
//        guard let key = finalKey(for: subgraph) else { return nil }
//        return node(for: key)
    }
    
    func metaNode(for subgraph: SubgraphKey) -> Node? {
        die
//        guard let key = metaKey(for: subgraph) else { return nil }
//        return node(for: key)
    }
    
    func input(for parent: NodeKey, index: Int) -> NodeKey? {
        die
//        return edgeMap(for: parent, level: level)?[index]
    }
    
    func inputNode(for parent: NodeKey, index: Int) -> Node? {
        guard let key = input(for: parent, index: index) else { return nil }
        return node(for: key)
    }
    
    func modify(_ block: (MutableDAG)->()) -> InternalDirectSnapshot {
        return modify(as: nil, level: level, block)
    }
    
    func modify(level: Int, _ block: (MutableDAG)->()) -> InternalDirectSnapshot {
        return modify(as: nil, level: level, block)
    }
    
    func modify(as key: CommitKey?, level: Int, _ block: (MutableDAG)->()) -> InternalDirectSnapshot {
        die
        /*
        let snapshot = snapshotToModify
        
        modLock?.lock()
        let pred: DAG = snapshot
        let result = InternalDirectSnapshot(predecessor: pred, store: store!, level: level, key: key ?? CommitKey())
        block(result)
        modLock?.unlock()
        
        if self.level == level, !key.exists, !result.hasChanges, let me = snapshot as? InternalDirectSnapshot {
            return me
        } else {
            result.becomeImmutable()
            return result
        }*/
    }
    
    func  alias(_ block: (MutableDAG)->()) -> InternalDirectSnapshot {
        return modify(as: self.key, level: level, block)
    }
    
    func optimizing(subgraph: SubgraphKey, throughCacheNodes: Bool = false) -> InternalDirectSnapshot {
        
        return modify { graph in
//            let subgraph = graph.subgraph(for: subgraph)
//            subgraph.finalNode = subgraph.finalNode?.optimize(throughCacheNodes: throughCacheNodes)
        }
        
//        return self as! InternalDirectSnapshot
        
//        let optimized = modify { (graph) in
//            graph.finalNode = graph.finalNode?.optimize(throughCacheNodes: throughCacheNodes)
//        }
        
//        for (parent, edgeMap) in optimized.edgeMaps {
//            print("PARENT: \(parent)")
//            for (i, child) in edgeMap {
//                print("    \(i) = \(child)")
//            }
//        }
        
//        print("ORIGINAL")
//        finalNode?.log()
//        print("OPTIMIZED")
//        optimized.finalNode?.log()

//        return optimized.flattened
    }
    
    func reference(for mode: DAGSnapshot.Mode) -> DAGSnapshot {
        die
//        let store = self.store!
//        if let self = self as? InternalDirectSnapshot {
//            if !store.commit(for: key).exists { store.commit(self) }
//        } else {
//            assert( store.commit(for: key).exists )
//        }
//
//        return DAGSnapshot(store: store, key: key, mode)
    }
    
    var internalReference: DAGSnapshot {
        return reference(for: .internalReference)
    }
    
    var externalReference: DAGSnapshot {
        return reference(for: .externalReference)
    }
    
    var isCommitted: Bool {
        return (store.commit(for: key)).exists
    }
    
    func importing(_ other: DAG) -> ImportSnapshot {
        return ImportSnapshot(predecessor: self, imported: other)
    }
    
}

extension MutableDAG {
    
    func setFinalNode(_ node: Node?, for subgraph: SubgraphKey) {
        setFinalKey(node?.key, for: subgraph)
    }
    
    func setMetaNode(_ node: Node?, for subgraph: SubgraphKey) {
        setMetaKey(node?.key, for: subgraph)
    }
    
}
