//
//  main.swift
//  CanvasBase
//
//  Created by Greg Fajen on 12/26/19.
//

import CanvasDAG

func main() {
    
}

//print("HI!!!")

typealias Collection = CanvasNodeCollection
typealias Store = DAGStore<Collection>
typealias Graph = DAGBase<Collection>
typealias MutableGraph = MutableDAG<Collection>
typealias InternalSnapshot = InternalDirectSnapshot<Collection>
typealias Subgraph = DAG.Subgraph<Collection>

func testCachingLimitsCosts() {
    let store = Store()
    let initial = InternalSnapshot(store: store)
    store.commit(initial)
    
    let subgraphKey = SubgraphKey()
    let cache = CacheAndOptimizer(subgraphKey)
    
    var current = initial
    for _ in 1...100 {
        autoreleasepool {
            current = current.modify {
                addLayer(to: $0,
                         subgraph: subgraphKey)
            }
            
            if current.depth > 10 {
                current = current.flattened
            }
            
    //        print("CURRENT:")
    //        current.subgraph(for: subgraphKey).finalNode!.log()
            
            let optimized = cache.march(current)
            
            let node = optimized.subgraph(for: subgraphKey).finalNode!
            let cost: Int = node.cost
            
    //        print("OPTIMIZED:")
    //        node.log()
            
            print("COST: \(cost)")
        }
//        XCTAssert(cost < 5)
    }
}

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

testCachingLimitsCosts()
