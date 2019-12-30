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

final class OptimizationTests: XCTestCase, CanvasBaseTestCase {
    
    typealias Collection = CanvasNodeCollection
    
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
    
//    func perform(_ times: Int, )
//    
//    func tenTimes<T>(_ block: ()->T) -> [T] {
//        return (0..<10).map { _ in block() }
//    }
//
//    func oneHundredTimes<T>(_ block: ()->T) -> [T] {
//        return (0..<10).map { _ in block() }
//    }
    
}
