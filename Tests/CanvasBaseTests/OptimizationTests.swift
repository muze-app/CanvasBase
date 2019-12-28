//
//  OptimizationTests.swift
//  CanvasBase
//
//  Created by Greg Fajen on 12/26/19.
//

import XCTest
@testable import MuzePrelude
@testable import MuzeMetal
@testable import DAG
@testable import CanvasBase
@testable import CanvasDAG

final class OptimizationTests: XCTestCase {
    
    typealias Collection = CanvasNodeCollection
    typealias Store = DAG.DAGStore<Collection>
    typealias Graph = DAGBase<Collection>
    typealias MutableGraph = MutableDAG<Collection>
    typealias InternalSnapshot = InternalDirectSnapshot<Collection>
    typealias Subgraph = DAG.Subgraph<Collection>
    
    var mockImagePayload: ImagePayload { .init(.mock, .identity, .identity) }
    
    func addLayer(to graph: MutableGraph,
                  subgraph: SubgraphKey,
                  blendMode: BlendMode = .normal,
                  alpha: Float = 1) {
        let subgraph = graph.subgraph(for: subgraph)
        
        let image = ImageNode(graph: graph, payload: mockImagePayload)
        let blend = BlendNode(graph: graph, payload: BlendPayload.init(blendMode, alpha))
        blend.source = image
        blend.destination = subgraph.finalNode
        
        subgraph.finalNode = blend
    }
    
    func addBrush(to graph: MutableGraph,
                  subgraph: SubgraphKey) {
        let subgraph = graph.subgraph(for: subgraph)
        
        let color = RenderColor2.white(1)
        
        let brushNode = ImageNode(graph: graph, payload: mockImagePayload)
        let colorNode = MaskedColorNode(graph: graph, payload: MaskedColorPayload(color, .whiteIsTransparent))
        let blendNode = BlendNode(graph: graph, payload: BlendPayload.init(.normal, 1))
        
        colorNode.mask = brushNode
        
        blendNode.source = colorNode
        blendNode.destination = subgraph.finalNode
        
        subgraph.finalNode = blendNode
    }
    
    func addEraser(to graph: MutableGraph,
                   subgraph: SubgraphKey) {
        let subgraph = graph.subgraph(for: subgraph)
        
        let brushNode = ImageNode(graph: graph, payload: mockImagePayload)
        let maskNode = MaskNode(graph: graph, payload: .whiteIsTransparent)
        
        maskNode.input = subgraph.finalNode
        maskNode.mask = brushNode
        
        subgraph.finalNode = maskNode
    }
    
    func testAddLayer() {
        let store = Store()
        let initial = InternalSnapshot(store: store)
        store.commit(initial)
        
        let subgraphKey = SubgraphKey()
        
        let final = initial.modify { (graph: MutableGraph) -> Void in
            addLayer(to: graph, subgraph: subgraphKey)
            addLayer(to: graph, subgraph: subgraphKey)
        }
        
        final.subgraph(for: subgraphKey).finalNode!.log()
        XCTAssert(true)
    }
    
    func testAddBrush() {
        let store = Store()
        let initial = InternalSnapshot(store: store)
        store.commit(initial)
        
        let subgraphKey = SubgraphKey()
        
        let final = initial.modify { (graph: MutableGraph) -> Void in
            addBrush(to: graph, subgraph: subgraphKey)
            addBrush(to: graph, subgraph: subgraphKey)
        }
        
        final.subgraph(for: subgraphKey).finalNode!.log()
        XCTAssert(true)
    }
    
    func testAddEraser() {
        let store = Store()
        let initial = InternalSnapshot(store: store)
        store.commit(initial)
        
        let subgraphKey = SubgraphKey()
        
        let final = initial.modify { (graph: MutableGraph) -> Void in
            addEraser(to: graph, subgraph: subgraphKey)
            addEraser(to: graph, subgraph: subgraphKey)
        }
        
        final.subgraph(for: subgraphKey).finalNode!.log()
        XCTAssert(true)
    }
    
    func testCompositeOptimization() {
        let store = Store()
        let initial = InternalSnapshot(store: store)
        store.commit(initial)
        
        let subgraphKey = SubgraphKey()
        
        let final = initial.modify { (graph: MutableGraph) -> Void in
            addLayer(to: graph, subgraph: subgraphKey)
            addLayer(to: graph, subgraph: subgraphKey)
        }
        
        let optimized = final.optimizing(subgraph: subgraphKey)
        
        optimized.subgraph(for: subgraphKey).finalNode!.log()
        
        guard let comp = optimized.subgraph(for: subgraphKey).finalNode as? CompositeNode else {
            XCTAssert(false)
            return
        }
        
        guard let images = comp.inputs as? [ImageNode] else {
            XCTAssert(false)
            return
        }
        
        XCTAssert(images.count == 2)
    }
    
    func testCompositeOptimization2() {
        let store = Store()
        let initial = InternalSnapshot(store: store)
        store.commit(initial)
        
        let subgraphKey = SubgraphKey()
        
        let final = initial.modify { (graph: MutableGraph) -> Void in
            addLayer(to: graph, subgraph: subgraphKey)
            addLayer(to: graph, subgraph: subgraphKey, alpha: 0.5)
        }
        
        let optimized = final.optimizing(subgraph: subgraphKey)
        
        optimized.subgraph(for: subgraphKey).finalNode!.log()
        
        guard let comp = optimized.subgraph(for: subgraphKey).finalNode as? CompositeNode else {
            XCTAssert(false)
            return
        }
        
        guard let images = comp.inputs as? [ImageNode] else {
            XCTAssert(false)
            return
        }
        
        XCTAssert(images.count == 2)
    }
    
    func testCompositeOptimizationThree() {
        let store = Store()
        let initial = InternalSnapshot(store: store)
        store.commit(initial)
        
        let subgraphKey = SubgraphKey()
        
        let final = initial.modify { (graph: MutableGraph) -> Void in
            addLayer(to: graph, subgraph: subgraphKey)
            addLayer(to: graph, subgraph: subgraphKey)
            addLayer(to: graph, subgraph: subgraphKey)
        }
        
        let optimized = final.optimizing(subgraph: subgraphKey)
        
        optimized.subgraph(for: subgraphKey).finalNode!.log()
        
        guard let comp = optimized.subgraph(for: subgraphKey).finalNode as? CompositeNode else {
            XCTAssert(false)
            return
        }
        
        guard let images = comp.inputs as? [ImageNode] else {
            XCTAssert(false)
            return
        }
        
        XCTAssert(images.count == 3)
    }
    
    func testBrushOptimization() {
        let store = Store()
        let initial = InternalSnapshot(store: store)
        store.commit(initial)
        
        let subgraphKey = SubgraphKey()
        
        let final = initial.modify { (graph: MutableGraph) -> Void in
            addBrush(to: graph, subgraph: subgraphKey)
            addBrush(to: graph, subgraph: subgraphKey)
            addBrush(to: graph, subgraph: subgraphKey)
        }
        
        let optimized = final.optimizing(subgraph: subgraphKey)
        
        optimized.subgraph(for: subgraphKey).finalNode!.log()
        
        guard optimized.subgraph(for: subgraphKey).finalNode is CompositeNode else {
            XCTAssert(false)
            return
        }
        
        /// actually, I don't think we can optimize this further
        /// without creating some more nodes...
        
        XCTAssert(true)
        
//        guard let images = comp.inputs as? [ImageNode] else {
//            XCTAssert(false)
//            return
//        }
//
//        XCTAssert(images.count == 3)
    }
    
    func testEraseOptimization() {
        let store = Store()
        let initial = InternalSnapshot(store: store)
        store.commit(initial)
        
        let subgraphKey = SubgraphKey()
        let backgroundKey = NodeKey()
        
        let final = initial.modify { (graph: MutableGraph) -> Void in
            let background = ImageNode(backgroundKey,
                                       graph: graph,
                                       payload: mockImagePayload)
            graph.subgraph(for: subgraphKey).finalNode = background
            
            addEraser(to: graph, subgraph: subgraphKey)
            addEraser(to: graph, subgraph: subgraphKey)
            addEraser(to: graph, subgraph: subgraphKey)
        }
        
          final.subgraph(for: subgraphKey).finalNode!.log()
        
        let optimized = final.optimizing(subgraph: subgraphKey)
        
        optimized.subgraph(for: subgraphKey).finalNode!.log()
        
        guard let mask = optimized.subgraph(for: subgraphKey).finalNode as? MaskNode else {
            XCTAssert(false)
            return
        }
        
        guard let series = mask.mask as? MaskSeriesNode else {
            XCTAssert(false)
            return
        }

        guard let background = mask.input as? ImageNode else {
            XCTAssert(false)
            return
        }
        
        XCTAssert(background.key == backgroundKey)
        XCTAssert(series.inputCount == 3)
    }
    
}
