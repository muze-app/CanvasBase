//
//  CachingTests.swift
//  CanvasBase
//
//  Created by Greg Fajen on 12/26/19.
//

import XCTest
@testable import MuzePrelude
@testable import DAG
@testable import CanvasBase
@testable import CanvasDAG

final class CachingTests: XCTestCase {
    
    typealias Collection = CanvasNodeCollection
    typealias Store = DAGStore<Collection>
    typealias Graph = DAGBase<Collection>
    typealias MutableGraph = MutableDAG<Collection>
    typealias InternalSnapshot = InternalDirectSnapshot<Collection>
    typealias Subgraph = DAG.Subgraph<Collection>
    
    func addLayer(to graph: MutableGraph,
                  subgraph: SubgraphKey,
                  blendMode: BlendMode = .normal,
                  alpha: Float = 1) {
        let subgraph = graph.subgraph(for: subgraph)
        
        let image = ImageNode(graph: graph, payload: ImagePayload.init())
        let blend = BlendNode(graph: graph, payload: BlendPayload.init(blendMode, alpha))
        blend.source = image
        blend.destination = subgraph.finalNode
        
        subgraph.finalNode = blend
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
    
    func testIncreasingCosts() {
        let store = Store()
        let initial = InternalSnapshot(store: store)
        store.commit(initial)
        
        let subgraphKey = SubgraphKey()
        
        var current = initial
        var lastCost = 0
        for _ in 1...100 {
            current = current.modify {
                addLayer(to: $0,
                         subgraph: subgraphKey)
            }
            
            let node = current.subgraph(for: subgraphKey).finalNode!
            let cost: Int = node.cost
            
            XCTAssert(cost > lastCost)
            lastCost = cost
        }
    }
    
    func testCachingLimitsCosts() {
        let store = Store()
        let initial = InternalSnapshot(store: store)
        store.commit(initial)
        
        let subgraphKey = SubgraphKey()
        let cache = CacheAndOptimizer(subgraphKey)
        
        var current = initial
        for _ in 1...30 {
            current = current.modify {
                addLayer(to: $0,
                         subgraph: subgraphKey)
            }
            
//            print("CURRENT:")
//            current.subgraph(for: subgraphKey).finalNode!.log()
            
            let optimized = cache.march(current)
        
            let node = optimized.subgraph(for: subgraphKey).finalNode!
            let cost: Int = node.cost
            
//            print("OPTIMIZED:")
//            node.log()
            
//            print("COST: \(cost)")
            
            XCTAssert(cost < 5)
        }
    }
    
}
