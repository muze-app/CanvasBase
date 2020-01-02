//
//  LayerPreview.swift
//  muze
//
//  Created by Greg Fajen on 12/10/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import MuzePrelude

#if os(iOS)
extension UIImage {
 
    static let clear = DrawingContext(width: 1, height: 1).uiImage
    
}
#endif

extension Date {
    
    static var now: Date { Date() }
    
}

public struct LayerPreview {

    public let date: Date
    public let contentHash: Int
    
    #if os(iOS)
    public let image: UIImage
    
    public static let clear = LayerPreview(0,
                                    image: .clear,
                                    date: .now)
    
    init(_ contentHash: Int, image: UIImage, date: Date) {
        self.date = date
        self.contentHash = contentHash
        self.image = image
    }
    #endif
    
}

class LayerPreviewRenderer {
    
    static let shared = LayerPreviewRenderer()
    
    let queue = DispatchQueue(label: "LayerPreview")
    
    private var currentFuture: Future<LayerPreview>?
    
    func render(layer subgraphKey: SubgraphKey,
                canvas manager: CanvasManager) -> Future<LayerPreview> {
        
        let graph = manager.display
        let store = manager.store
        
        let hashOptional = store.read { graph.subgraph(for: subgraphKey).finalNode?.contentHash }
        guard let hash = hashOptional else {
            #if os(iOS)
            return .succeeded(.clear)
            #else
            fatalError()
            #endif
        }
        
        return _renderPreview(layer: subgraphKey,
                              graph: graph,
                              hash: hash,
                              canvas: manager)
    }
    
    private func _renderPreview(layer subgraphKey: SubgraphKey,
                                graph: Graph,
                                hash: Int,
                                date: Date = .now,
                                canvas manager: CanvasManager) -> Future<LayerPreview> {
//        fatalError()
        
        let canvasSize = manager.metadata(for: graph).size
        let thumbSize = CGSize(240) //MainLayerCell.frames.image.size * UIScreen.main.nativeScale

        let finalSize = thumbSize.sizeThatFills(canvasSize.aspectRatio)
        let scale = thumbSize.width / canvasSize.width

//        print(" canvas size: \(canvasSize)")
//        print("  thumb size: \(thumbSize)")
//        print("  final size: \(finalSize)")
//        print("       scale: \(scale)")
//        print(" native size: \(UIScreen.main.nativeBounds.size)")
//        print("native scale: \(UIScreen.main.nativeScale)")

//        graph.subgraph(for: subgraphKey).finalNode?.log()
        
        let graph = graph.store.writeAsync {
            graph.modify { graph in
                manager.modifyMetadata(in: graph) { $0.size = finalSize }
                
                let subgraph = graph.subgraph(for: subgraphKey)
                
                let transform = TransformNode(graph: graph, payload: .scaling(scale))
                transform.input = subgraph.finalNode
                
                subgraph.finalNode = transform
            }
        }
        
        return graph.hop(to: queue).flatMap { graph  in
            self._renderImage(layer: subgraphKey,
                         graph: graph,
                         canvas: manager).map { texture -> LayerPreview in
                #if os(iOS)
                let image = texture.uiImage
                return .init(hash, image: image, date: date)
                #else
                return .init(date: date, contentHash: hash)
                #endif
            }
        }
    }
    
    private func _renderImage(layer subgraphKey: SubgraphKey,
                              graph: Graph,
                              canvas manager: CanvasManager) -> Future<MetalTexture> {
        let promise = Promise<MetalTexture>(on: queue)
        manager.renderTexture(for: subgraphKey,
                                  of: graph,
                                  format: .sRGB) {
            promise.succeed($0)
        }
        return promise.future
    }
    
}
