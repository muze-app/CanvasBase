//
//  Creation.swift
//  muze
//
//  Created by Greg Fajen on 5/27/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import MuzePrelude
import Metal

open class SingleLayerCreation: Creation {
    
    let layerKey = LayerKey()
    var layerManager: LayerManager { return canvasManager.manager(for: layerKey) }
    var layerSubgraphKey: SubgraphKey { return layerManager.subgraphKey }
    
    var currentLayerSubgraph: Subgraph { return canvasManager.current.subgraph(for: layerSubgraphKey) }
    
    var currentCanvasSubgraph: Subgraph { return canvasManager.current.subgraph(for: canvasManager.subgraphKey) }
    
    var subtransaction: CanvasTransaction?
    
    override func setupCanvas(_ graph: MutableGraph) {
        let layerMetaNode = LayerMetaNode(graph: graph, payload: LayerMetadata())
        graph.setMetaNode(layerMetaNode, for: layerSubgraphKey)
        
        var canvasMetadata = canvasManager.metadata(for: graph)
        canvasMetadata.layers.append(layerKey)
        canvasMetadata.layerSubgraphs[layerKey] = layerSubgraphKey
        canvasMetadata.selectedLayer = layerKey
        canvasManager.set(canvasMetadata, in: graph)
    }
    
    public func modify(_ identifier: String, _ block: (Subgraph) -> ()) {
        let x: CanvasTransactionParent = subtransaction ?? canvasManager
        
        let t = x.newTransaction(identifier: identifier)
        t.modify(description: identifier, layer: layerManager, with: block)
        t.commit()
        
        DispatchQueue.global().async { [weak self] in
            self?.canvasManager.reduceMemory()
        }
    }
    
    public func startSubtransaction(_ identifier: String) {
        precondition(!subtransaction.exists)
        subtransaction = canvasManager.newTransaction(identifier: identifier)
    }
    
    public func commmitSubtransaction() {
        precondition(subtransaction.exists)
        subtransaction!.commit()
    }
    
    public func cancelSubtransaction() {
        precondition(subtransaction.exists)
        subtransaction!.cancel()
    }
    
}

open class Creation {
    
    public typealias Subgraph = DAG.Subgraph<CanvasNodeCollection>
    
    public let canvasManager: CanvasManager
    public let context = RenderContext()
    
    public init(canvasSize: CGSize = NewCameraCanvasLayout().canvasSize) {
        canvasManager = CanvasManager(canvasSize: canvasSize)
        
        let graph = canvasManager.current.modify { setupCanvas($0) }
        canvasManager.store.commit(graph)
        
        let ref = graph.externalReference
        canvasManager.current = ref
        canvasManager.displayCanvas = ref
        
//        let graph = canvasManager.store.latest.modify { graph in
//            setupCanvas(graph)
//        }
        
//        canvasManager.current = graph.externalReference
//        canvasManager.displayCanvas = graph.externalReference
    }
    
    func setupCanvas(_ graph: MutableGraph) {
//        transaction.canvas.add(layer: Layer())
//        transaction.canvas.backgroundIsHidden = true
    }
    
    public func clearAllUndos() {
        undoManager.removeAll()
    }
    
    // MARK: Rendering
    
    public func render(format: RenderOptions.PixelFormat = .float16,
                       colorSpace: RenderOptions.ColorSpace = .working,
                       _ callback: @escaping (MetalTexture)->()) {
        
//        fatalError()
        canvasManager.renderTexture { texture in
//            let texture = image.original!.metal.value!
            callback(texture)
        }
    }
    
    var activeNode: NodePath? {
        get { return canvasManager.activeNode }
        set { canvasManager.activeNode = newValue }
    }
    
    // MARK: Undo
    
    public var undoManager: CanvasUndoManager { return canvasManager.undoManager }
    
    func log(_ name: String, _ graph: Graph? = nil) {
        
        canvasManager.store.read {
            let graph = graph ?? canvasManager.display
            print("\(name) (\(graph.key))")
            graph.subgraph(for: canvasManager.subgraphKey).finalNode?.log()
        }
    }
    
    public func undo() {
        if let action = canvasManager.undo() {
            log("BEFORE", action.before)
            log("AFTER", action.after)
            log("DISPLAY")
        }
    }
    
    public func redo() {
        if let action = canvasManager.redo() {
            log("BEFORE", action.before)
            log("AFTER", action.after)
            log("DISPLAY")
        }
    }
    
    public var canUndo: Bool {
        return undoManager.canUndo
    }

    public var canRedo: Bool {
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
        #if os(iOS)
        let rgbaF = renderColor.ui.premultipliedComponents
        //        let rgba10: [UInt16] = rgbaF.map(TColor.float2Int)
        
        let l: (Float) -> Float = RenderColor.linearize
        //        RenderColor.linearize(sRGB: <#T##BinaryFloatingPoint#>)
        
        print("rgbaF: \(rgbaF)")
        //        print("rgba10: \(rgba10)")
        
        r = l(rgbaF[0])
        g = l(rgbaF[1])
        b = l(rgbaF[2])
        a = l(rgbaF[3])
        #else
        fatalError()
        #endif
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
