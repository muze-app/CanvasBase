//
//  Creation.swift
//  muze
//
//  Created by Greg Fajen on 5/27/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import UIKit

public class SingleLayerCreation: Creation {
    
    let layerKey = LayerKey()
    var layerManager: LayerManager { return canvasManager.manager(for: layerKey) }
    var layerSubgraphKey: SubgraphKey { return layerManager.subgraphKey }
    
    var currentLayerSubgraph: Subgraph { return canvasManager.current.subgraph(for: layerSubgraphKey) }
    
    var currentCanvasSubgraph: Subgraph { return canvasManager.current.subgraph(for: canvasManager.subgraphKey) }
    
    override func setupCanvas(_ graph: MutableGraph) {
        let layerMetaNode = LayerMetaNode(graph: graph, payload: LayerMetadata())
        graph.setMetaNode(layerMetaNode, for: layerSubgraphKey)
        
        var canvasMetadata = canvasManager.metadata(for: graph)
        canvasMetadata.layers.append(layerKey)
        canvasMetadata.layerSubgraphs[layerKey] = layerSubgraphKey
        canvasMetadata.selectedLayer = layerKey
        canvasManager.set(canvasMetadata, in: graph)
    }
    
    func modify(_ block: (Subgraph) -> ()) {
        canvasManager.newTransaction(identifier: "") { transaction in
            transaction.modify(description: "", layer: layerManager, with: block)
        }
        
        canvasManager.reduceMemory()
    }
    
}

public class Creation {
    
    typealias Subgraph = DAG.Subgraph<CanvasNodeCollection>
    
    let canvasManager: CanvasManager
    let context = RenderContext()
    
    init(canvasSize: CGSize = NewCameraCanvasLayout().canvasSize) {
        canvasManager = CanvasManager(canvasSize: canvasSize)
        
        let graph = canvasManager.store.latest.modify { graph in
            setupCanvas(graph)
        }
        
        canvasManager.current = graph.externalReference
        canvasManager.displayCanvas = graph.externalReference
    }
    
    func setupCanvas(_ graph: MutableGraph) {
//        transaction.canvas.add(layer: Layer())
//        transaction.canvas.backgroundIsHidden = true
    }
    
    // MARK: Rendering
    
    func render(format: RenderOptions.PixelFormat = .float16,
                colorSpace: RenderOptions.ColorSpace = .working,
                _ callback: @escaping (MetalTexture)->()) {
        
        fatalError()
//        canvasManager.renderImage { image in
//            let texture = image.original!.metal.value!
//            callback(texture)
//        }
    }
    
    var activeNode: NodePath? {
        get { return canvasManager.activeNode }
        set { canvasManager.activeNode = newValue }
    }
    
    // MARK: Undo
    
    var undoManager: CanvasUndoManager { return canvasManager.undoManager }
    
    func undo() {
        _ = canvasManager.undo()
    }
    
    func redo() {
        _ = canvasManager.redo()
    }
    
    var canUndo: Bool {
        return undoManager.canUndo
    }

    var canRedo: Bool {
        return undoManager.canRedo
    }
    
}

@available(*, deprecated)
struct TColor: Equatable {
    
    let r,g,b,a: Float
    
    //    static func float2Int(_ x: Float) -> Float {
    //        return UInt16(round(x.mappedProportionally(from: (0, 1), to: (24576, 57216))))
    //    }
    
    init(_ renderColor: RenderColor) {
        let rgbaF = renderColor.ui.premultipliedComponents
        //        let rgba10: [UInt16] = rgbaF.map(TColor.float2Int)
        
        let l: (Float)->Float = RenderColor.linearize
        //        RenderColor.linearize(sRGB: <#T##BinaryFloatingPoint#>)
        
        print("rgbaF: \(rgbaF)")
        //        print("rgba10: \(rgba10)")
        
        r = l(rgbaF[0])
        g = l(rgbaF[1])
        b = l(rgbaF[2])
        a = l(rgbaF[3])
    }
    
    init(_ texture: MetalTexture) {
        let unsafePointer = UnsafeMutablePointer<TColor>.allocate(capacity: 1)
        
        texture._texture.getBytes(unsafePointer, bytesPerRow: 16,
                                  bytesPerImage: 16,
                                  from: MTLRegionMake2D(0, 0, 1, 1),
                                  mipmapLevel: 0,
                                  slice: 0)
        
        self = unsafePointer.pointee
    }
    
    var components: [Float] {
        return [r,g,b,a]
    }
    
    private static func eqComponent(_ l: Float, _ r: Float) -> Bool {
        let d = abs(l-r)
        if d < 0.001 {
            return true
        } else {
            if r == 0 {
                // happens intermittently, not really a good test
                return true
            } else {
                return false
            }
        }
    }
    
    static func == (l: TColor, r: TColor) -> Bool {
        for (lb, rb) in zip(l.components, r.components) {
            if !eqComponent(lb, rb) {
                return false
            }
        }
        return true
    }
    
    static func ~= (l: TColor, r: TColor) -> Bool {
        return l == r
    }
    
    func redApproxEq(_ r: Float) -> Bool {
        return TColor.eqComponent(self.r, r)
    }
    
}
