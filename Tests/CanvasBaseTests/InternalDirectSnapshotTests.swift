//
//  InternalDirectSnapshotTests.swift
//  canvas-base
//
//  Created by Greg Fajen on 12/19/19.
//

import XCTest
@testable import DAG
@testable import CanvasBase

extension DAGBase: Equatable {
    
    public static func == (lhs: DAGBase<Collection>, rhs: DAGBase<Collection>) -> Bool {
        return lhs.key == rhs.key
    }
    
}

final class InternalDirectSnapshotTests: XCTestCase {
    
    typealias Collection = MockNodeCollection
    typealias Store = DAG.DAGStore<Collection>
    typealias Graph = DAGBase<Collection>
    typealias MutableGraph = MutableDAG<Collection>
    typealias InternalSnapshot = InternalDirectSnapshot<Collection>
    typealias Subgraph = DAG.Subgraph<Collection>
    
    typealias ImageNode = MockImageNode
    typealias BlendNode = MockBlendNode
    typealias FilterNode = MockFilterNode
    
    func testCommit() {
        let store = Store()
        let initial = InternalSnapshot(store: store)
        store.commit(initial)
        
        let found = store.commit(for: initial.key)
        XCTAssert(found.exists)
    }
    
    func testNotModifiedOptimization() {
        let store = Store()
        let initial = InternalSnapshot(store: store)
        
        let notReallyModified = initial.modify { _ in }
        
        XCTAssert(initial === notReallyModified)
    }
    
    func testAddImageNode() {
        let store = Store()
        let initial = InternalSnapshot(store: store)
        store.commit(initial)
        
        let nodeKey = NodeKey()
        
        let final = initial.modify { (graph: MutableGraph) -> Void in
            let node = MockImageNode(nodeKey, graph: graph, payload: 0, nodeType: .image)
            print("node: \(node)")
        }
        
        store.read {
            let node = final.node(for: nodeKey)
            print("node: \(node)")
            XCTAssert(node is MockImageNode)
        }
    }
    
    func testFilterNode() {
        let store = Store()
        let initial = InternalSnapshot(store: store)
        store.commit(initial)
        
        let imageKey = NodeKey()
        let filterKey = NodeKey()
        
        let final = initial.modify { (graph: MutableGraph) -> Void in
            let image = ImageNode(imageKey, graph: graph, payload: 0, nodeType: .image)
            let filter = FilterNode(filterKey, graph: graph, payload: 0, nodeType: .filter)
            
            filter.input = image
        }
        
        store.read {
            let image = final.node(for: imageKey) as! ImageNode
            let filter = final.node(for: filterKey) as! FilterNode
            
            XCTAssert(filter.input?.key == image.key)
        }
    }
    
    func testRevEdgesNode() {
        let store = Store()
        let initial = InternalSnapshot(store: store)
        store.commit(initial)
        
        let imageKey = NodeKey()
        let filterKey = NodeKey()
        
        let final = initial.modify { (graph: MutableGraph) -> Void in
            let image = ImageNode(imageKey, graph: graph, payload: 0, nodeType: .image)
            let filter = FilterNode(filterKey, graph: graph, payload: 0, nodeType: .filter)
            
            filter.input = image
        }
        
        let imageRevEdges = final.reverseEdges(for: imageKey)!
        XCTAssert(imageRevEdges.contains(filterKey))
        XCTAssert(imageRevEdges.asArray.count == 1)
        
        let filterRevEdges = final.reverseEdges(for: filterKey)!
        XCTAssert(filterRevEdges.asArray.count == 0)
    }
    
    func testDepth() {
        let store = Store()
        let initial = InternalSnapshot(store: store)
        store.commit(initial)
        
        print("initial.depth: \(initial.depth)")
        
        let subgraphKey = SubgraphKey()
        
        let one = initial.modify { graph in
            let subgraph = graph.subgraph(for: subgraphKey)
            
            subgraph.finalNode = ImageNode(graph: graph,
                                           payload: 1,
                                           nodeType: .image)
        }
        
        let two = one.modify { graph in
            let subgraph = graph.subgraph(for: subgraphKey)
            
            subgraph.finalNode = ImageNode(graph: graph,
                                           payload: 2,
                                           nodeType: .image)
        }
        
        print("one.depth: \(one.depth)")
        XCTAssert(one.depth == 1)
        print("two.depth: \(two.depth)")
        XCTAssert(two.depth == 2)
    }
    
}
