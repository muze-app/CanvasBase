//
//  InternalDirectSnapshotTests.swift
//  canvas-base
//
//  Created by Greg Fajen on 12/19/19.
//

import XCTest
@testable import DAG
@testable import canvas_base

final class InternalDirectSnapshotTests: XCTestCase {
    
    typealias Collection = MockNodeCollection
    typealias Store = DAGStore<Collection>
    typealias Graph = DAGBase<Collection>
    typealias MutableGraph = MutableDAG<Collection>
    typealias InternalSnapshot = InternalDirectSnapshot<Collection>
    
    typealias ImageNode = MockImageNode
    typealias BlendNode = MockBlendNode
    typealias FilterNode = MockFilterNode
    
    func testCommit() {
        let store = Store()
        let initial = InternalSnapshot(store: store, level: 0)
        store.commit(initial)
        
        let found = store.commit(for: initial.key);
        XCTAssert(found.exists)
    }
    
    func testNotModifiedOptimization() {
        let store = Store()
        let initial = InternalSnapshot(store: store, level: 0)
        
        let notReallyModified = initial.modify { _ in }
        
        XCTAssert(initial === notReallyModified)
    }
    
    func testAddImageNode() {
        let store = Store()
        let initial = InternalSnapshot(store: store, level: 0)
        store.commit(initial)
        
        let nodeKey = NodeKey()
        
        let final = initial.modify { (graph: MutableGraph) -> Void in
            let node = MockImageNode(nodeKey, graph: graph, payload: 0, nodeType: .image)
            print("node: \(node)")
        }
        
        let node = final.node(for: nodeKey)
        print("node: \(node)")
        XCTAssert(node is MockImageNode)
    }
    
    func testFilterNode() {
        let store = Store()
        let initial = InternalSnapshot(store: store, level: 0)
        store.commit(initial)
        
        let imageKey = NodeKey()
        let filterKey = NodeKey()
        
        let final = initial.modify { (graph: MutableGraph) -> Void in
            let image = ImageNode(imageKey, graph: graph, payload: 0, nodeType: .image)
            let filter = FilterNode(filterKey, graph: graph, payload: 0, nodeType: .filter)
            
            filter.input = image
        }
        
        let image = final.node(for: imageKey) as! ImageNode
        let filter = final.node(for: filterKey) as! FilterNode
        
        XCTAssert(filter.input?.key == image.key)
    }
    
    func testRevEdgesNode() {
        let store = Store()
        let initial = InternalSnapshot(store: store, level: 0)
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
    
}
