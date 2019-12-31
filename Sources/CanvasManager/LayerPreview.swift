//
//  LayerPreview.swift
//  muze
//
//  Created by Greg Fajen on 12/10/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import UIKit

extension UIImage {
 
    static let clear = DrawingContext(width: 1, height: 1).uiImage
    
}

extension Date {
    
    static var now: Date { Date() }
    
}

struct LayerPreview {

    let contentHash: Int
    let image: UIImage
    let date: Date
    
    static let clear = LayerPreview(contentHash: 0,
                                    image: .clear,
                                    date: .now)
    
}

class LayerPreviewRenderer {
    
    static let shared = LayerPreviewRenderer()
    
    let queue = DispatchQueue(label: "LayerPreview")
    
    private var currentFuture: Future<LayerPreview>?
    
    func render(layer subgraphKey: SubgraphKey,
                canvas manager: CanvasManager) -> Future<LayerPreview> {
        
        let graph = manager.display
        
        guard let hash = graph.subgraph(for: subgraphKey).finalNode?.contentHash else {
            return .succeeded(.clear)
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
        fatalError()
        
//        let canvasSize = manager.metadata(for: graph).size
//        let thumbSize = MainLayerCell.frames.image.size * UIScreen.main.nativeScale
//
//        let finalSize = thumbSize.sizeThatFills(canvasSize.aspectRatio)
//        let scale = thumbSize.width / canvasSize.width
//
////        print(" canvas size: \(canvasSize)")
////        print("  thumb size: \(thumbSize)")
////        print("  final size: \(finalSize)")
////        print("       scale: \(scale)")
////        print(" native size: \(UIScreen.main.nativeBounds.size)")
////        print("native scale: \(UIScreen.main.nativeScale)")
//
////        graph.subgraph(for: subgraphKey).finalNode?.log()
//
//        let graph = graph.modify { graph in
//            manager.modifyMetadata(in: graph) { $0.size = finalSize }
//
//            let subgraph = graph.subgraph(for: subgraphKey)
//
//            let transform = TransformNode(graph: graph, payload: .scaling(scale))
//            transform.input = subgraph.finalNode
//
//            subgraph.finalNode = transform
//        }
//
//        return _renderImage(layer: subgraphKey,
//                     graph: graph,
//                     canvas: manager).flatMap { image -> Future<LayerPreview> in
//            let promise = FPromise<LayerPreview>()
//
//            let orig = image.original!
//            let handle = orig.bitmap.makeStrongHandle()
//
//            handle.await { _ in
//                if let ui = orig.bitmap.value?.uiImage {
////                    print("ui size: \(ui.size)")
//                    promise.succeed(.init(contentHash: hash, image: ui, date: date))
//                } else {
//                    promise.fail(MiscError(""))
//                }
//
//                handle.release()
//            }
//
//            return promise.future
//        }
    }
    
//    private func _renderImage(layer subgraphKey: SubgraphKey,
//                              graph: Graph,
//                              canvas manager: CanvasManager) -> Future<Image> {
//        let promise = FPromise<Image>(on: queue)
//        manager.renderImage(for: subgraphKey,
//                                  of: graph,
//                                  format: .sRGB) {
//            promise.succeed($0)
//        }
//        return promise.future
//    }
    
}
