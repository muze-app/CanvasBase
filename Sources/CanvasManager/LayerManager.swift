//
//  LayerManager.swift
//  muze
//
//  Created by Greg on 2/2/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import MuzePrelude

public typealias Snapshot = DAG.DAGSnapshot<CanvasNodeCollection>

public class LayerManager {
    
    public weak var canvasManager: CanvasManager?
    
    public let key: LayerKey
    public let subgraphKey = SubgraphKey()
    
    public var preview: LayerPreview?
    public var previewFuture: Future<LayerPreview>?
//    var previewContentHash: Int?
    
    var needsToPurgeCaches = true
    
    public init(_ key: LayerKey = LayerKey(), canvasManager: CanvasManager) {
        self.canvasManager = canvasManager
        self.key = key
    }
    
    // MARK: Layer
    
    public var current: Snapshot { canvasManager!.current }
    public var display: Snapshot { canvasManager!.display }
    
    public func metaNode(for commit: Graph) -> LayerMetaNode {
        return commit.metaNode(for: subgraphKey) as! LayerMetaNode
    }
    
    public func metadata(for commit: Graph) -> LayerMetadata {
        return metaNode(for: commit).payload
    }
    
    public func set(_ metadata: LayerMetadata, in graph: MutableGraph) {
        metaNode(for: graph).payload = metadata
    }
    
    public var currentMetadata: LayerMetadata { return metadata(for: current) }
    public var displayMetadata: LayerMetadata { return metadata(for: display) }
    
    @available(*, deprecated)
    var displayLayer: LayerMetadata { return displayMetadata }
    
    @available(*, deprecated)
    func keysToCache(for graph: Graph) -> [NodeKey] {
        fatalError()
//        let graph = graph.modify { _ in }
////        return []
////        fatalError()
//        let subgraph = graph.subgraph(for: subgraphKey)
//        guard let node = subgraph.finalNode else { return [] }
//
//        let keysToNotCache = Set(node.uncacheableNodes)
////        if let activeNode = canvasManager?.activeNode {
////            keysToNotCache.insert(activeNode.nodeKey)
////        }
//
//        if keysToNotCache.isEmpty { return [node.key] }
//
//        let result = node.nodes(thatDoNotContain: keysToNotCache)
//        print("result: \(result)")
//        return result
    }
    
    func setLayer(_ new: One) {
//        assert(new.key == key)
//
//        let old = _displayLayer
//
//        var keysToCache = self.keysToCache(for: new)
//
////    new.node?.log()
////        print(" ")
//
////        print("RECOMMENDED: ")
////        for key in keysToCache {
////            print("   \(key)")
////        }
//
//        if let existing = old.node?.cachedNodeKeys {
//            keysToCache.append(contentsOf: existing)
//
////            print("EXISTING: ")
////            for key in existing {
////                print("   \(key)")
////            }
//        }
//
//
//        if let active = canvasManager?.activeNode {
////            print("ACTIVE: ")
////            print("   \(active.nodeKey)")
//            keysToCache.removeAll { $0 == active.nodeKey }
//        }
//
//        var new = new
//        new.node = new.node?.addingCacheNodes(keysToCache)
//        _displayLayer = new
//
//        if old == new { return }
//
//        updatePreview()
//
//        informObservers(old: old, new: new)
//
//        needsToPurgeCaches = true
    }
    
    func purgeCachesIfNeeded() {
//        guard needsToPurgeCaches else { return }
//
////        print("PURGING CACHES")
////        print("BEFORE")
////        _displayLayer.node?.log(with: "\t")
//
//        _displayLayer.node = _displayLayer.node?.purgingUnneededCaches()
//
////        print("AFTER")
////        _displayLayer.node?.log(with: "\t")
//
//        needsToPurgeCaches = false
    }
    
    func informObservers(old: One, new: One) {
//        if old.isHidden != new.isHidden {
//            let index = displayCanvas.index(of: new)!
//            informObservers {
//                $0.canvas(layer: new, at: index, wasHidden: new.isHidden)
//            }
//        }
    }
    
    func informObservers(_ block: (CanvasObserver)->()) {
        for observer in canvasManager!.observers {
            block(observer)
        }
    }
    
//    func markInactive() {
//        hideActiveNode = false
//        
//        if hasActiveNode {
//            canvasManager?.activeNode = nil
//        }
//        
////        updatePreview()
//    }
    
    // MARK: Outputs
    
    var hideActiveNode = false
    var lastCacheKey: NodeKey?
    
    // MARK: Preview
    public weak var previewDelegate: LayerPreviewDelegate?
//    var preview: UIImage? = nil
//    var previewState: Layer? = nil
//    let previewContext = LayerPreviewContext()
    
    // MARK: Convenience
//    var node: Node? { return _displayLayer.node }
//    var caption: CaptionNode? { return _displayLayer.caption }
    
//    var displayCanvas: Canvas { return canvasManager!.displayCanvas }
    public var layerIsSelected: Bool { return true }
    public var layerIndex: Int? { return 0 }
    
}
