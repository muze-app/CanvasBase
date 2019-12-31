//
//  LayerAction.swift
//  muze
//
//  Created by Greg on 1/17/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation

class LayerAction: CanvasAction {
    
    init(_ description: String,
         before: Snapshot,
         layerManager: LayerManager,
         _ block: (Subgraph<CanvasNodeCollection>)->()) {
        super.init(description, before: before) { (graph) in
            let subgraph = Subgraph(key: layerManager.subgraphKey, graph: graph)
            block(subgraph)
        }
        
//        let canvasMetaNode = before.metaNode as! CanvasMetaNode
//        let canvasMetadata = canvasMetaNode.payload
//
//        let layerKey = layer.key
//        let layerSnapshot: DAGSnapshot = canvasMetadata.rawSnapshots[layerKey]!
//
//        let layerBefore: InternalDirectSnapshot = layerSnapshot.internalSnapshot
//        let layerAfter: InternalDirectSnapshot = layerBefore.modify(block)
//
//        print("ABOUT TO COMMIT!!! (isLayer: \(layer.subgraph.isLayer))")
//
//        layer.subgraph.commit(layerAfter)
//
//        print("    processedKey: \(layerAfter.key) -> \(layerAfter.key.with("processed"))")
//
//        let processed = layer.subgraph.commit(for: layerAfter.key.with("processed"))! // ?? layerAfter
//
//        let afterInternal: InternalDirectSnapshot = before.internalSnapshot.modify { (graph) in
//            let metaNode = graph.metaNode as! CanvasMetaNode
//            metaNode.payload.rawSnapshots[layerKey] = layerAfter.externalReference
//            metaNode.payload.processedSnapshots[layerKey] = processed.externalReference
//        }
//
//        before.store!.commit(afterInternal)
//
//        let after: DAGSnapshot = afterInternal.externalReference
//
//        super.init(description, before: before, after: after)
    }
    
}
