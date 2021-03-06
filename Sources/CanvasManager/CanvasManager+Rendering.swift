//
//  CanvasManager+Rendering.swift
//  muze
//
//  Created by Greg on 2/9/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

@available(*, deprecated)
typealias MutableDAG = MutableGraph

extension CanvasManager {
    
    // MARK: Offscreen Rendering
    
    func renderTexture(for subgraph: SubgraphKey? = nil,
                       of commit: Graph? = nil,
                       format: RenderOptions.PixelFormat = .sRGB,
                       completion: @escaping (MetalTexture)->()) {

        let subgraph = subgraph ?? self.subgraphKey
        let commit = commit ?? current //.optimizing(subgraph: subgraph)
        let canvasMetadata = metadata(for: commit)
        
        context.render(graph: commit,
                       subgraph: subgraph,
                       canvasSize: canvasMetadata.size,
                       time: 0,
                       caching: [],
                       format: format,
                       colorSpace: .working) { (result) in

            let (texture, _) = result
            DispatchQueue.main.async {
                completion(texture)
            }
        }
    }
    
    // MARK: - Unsorted
    
//    var activeCaption: Node? {
//        fatalError()
////         if let key = activeCaptionPath?.layerKey, let manager = existingManager(for: key)  {
////            return manager.displayLayer.caption
////        } else {
////            return nil
////        }
//    }
    
    // I'm doing the worst thing ever here
//    static let mock: Image = {
//        let ui = UIImage(named: "20kb.jpg")!
//        let image = Image.with(ui)
//
//        var ok = false
//
//        image.original!.metal.ensureExists({ (_) in
//            ok = true
//        })
//
//        while !ok { sleep(1) }
//
//        return image
//    }()
    
    func updateCanvasSubgraph(in graph: MutableGraph) {
        let subgraph = graph.subgraph(for: subgraphKey)
        let canvasMetaNode = subgraph.metaNode as! CanvasMetaNode
        let canvasMetadata = canvasMetaNode.payload

        var lastBlend: BlendNode?

        let subgraphKeys = canvasMetadata.layers.map { canvasMetadata.layerSubgraphs[$0]! }
        for subgraphKey in subgraphKeys {
            let subgraph = graph.subgraph(for: subgraphKey)
            
            guard let finalKey = subgraph.finalKey else { continue }
            let metaNode = subgraph.metaNode as! LayerMetaNode
            let metadata = metaNode.payload
            if metadata.isHidden { continue }
            if metadata.alpha == 0 { continue }
            
            let layerKey = NodeKey(subgraphKey)
            
            let blocker = CacheBlocker(layerKey.with("blocker"), graph: graph)
            blocker.input = graph.node(for: finalKey)
            
            let blend = BlendNode(layerKey.with("blend"), graph: graph, payload: metadata.blendPayload)
            blend.destination = lastBlend
            blend.source = blocker
            blend.alpha = metadata.alpha
            blend.blendMode = metadata.blendMode

            lastBlend = blend
        }

        subgraph.finalNode = lastBlend
    }
    
//    var cacheKeys: [NodeKey] {
//        return allLayerManagers.compactMap { return $0.cacheKey }
//    }
    
}
