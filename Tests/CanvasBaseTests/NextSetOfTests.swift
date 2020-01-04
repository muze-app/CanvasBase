//
//  NextSetOfTests.swift
//  CanvasBaseTests
//
//  Created by Greg Fajen on 12/30/19.
//

import XCTest
@testable import DAG
@testable import CanvasDAG
//@testable import CanvasBase

class SomethingTests: XCTestCase, CanvasBaseTestCase {
     
//    typealias Collection = MockNodeCollection
    typealias Collection = CanvasNodeCollection
    
    func addThreeLayers(to graph: inout Graph, subgraph: SubgraphKey) -> [Snapshot] {
        var snapshots = [DAGSnapshot<Collection>]()
        
        for _ in 0..<3 {
            graph = graph.modify { graph in
                self.addLayer(to: graph, subgraph: subgraph)
                
                graph.store.commit(graph)
                snapshots.append(graph.externalReference)
            }
        }
        
        return snapshots
    }
    
    func setupFirstTen(_ store: Store, _ graph: inout Graph, _ subgraphKey: SubgraphKey) -> [Snapshot] {
        return addThreeLayers(to: &graph, subgraph: subgraphKey)
    }
    
    func setupSecondTen(_ store: Store, _ graph: inout Graph, _ subgraphKey: SubgraphKey) -> [Snapshot] {
        return addThreeLayers(to: &graph, subgraph: subgraphKey)
    }
    
    func testThatNodesDoNotContainHasNoDupes() {
        let store = Store()
        let initial = InternalSnapshot(store: store)
        store.commit(initial)
        let subgraphKey = SubgraphKey()
        
        var graph: Graph = initial
        var first: [Snapshot] = autoreleasepool { setupFirstTen(store, &graph, subgraphKey) }
        let second: [Snapshot] = autoreleasepool { setupSecondTen(store, &graph, subgraphKey) }
        
        let newNodes = second.flatMap { $0.internalSnapshot.nodesTouchedSincePredecessor }
        
        let commitCount = store.sortedCommits.count
        print("first.count: \(first.count)")
        print("second.count: \(second.count)")
        print("commit count: \(commitCount)")
        
        XCTAssert(store.sortedCommits.count == 6)
        
        first = []
        
        XCTAssert(store.sortedCommits.count == 3)
        
        store.read {
            let result = store.sortedCommits.head.subgraph(for: subgraphKey).finalNode!.nodes(thatDoNotContain: Set(newNodes))
            
//            store.sortedCommits.head.subgraph(for: subgraphKey).finalNode!.log()
            
            print("head nodes: \(store.sortedCommits.head.allNodes)")
            print("new nodes: \(newNodes)")
            print("result: \(result)")
            XCTAssert(result.count == 1)
        }
    }
    
}

class RevEdgeTests: XCTestCase, CanvasBaseTestCase {
    
    typealias Collection = MockNodeCollection
    
    // rev edges
    
    func testBasicRevEdges() {
        let store = Store()
        let initial = InternalSnapshot(store: store)
        store.commit(initial)
        
        let subgraphKey = SubgraphKey()
        let aKey = NodeKey()
        let bKey = NodeKey()
        let cKey = NodeKey()
        
        let graph = initial.modify { graph in
            let subgraph = graph.subgraph(for: subgraphKey)
            
            let a = MockImageNode(aKey, graph: graph, payload: 1, nodeType: .image)
            let b = MockImageNode(bKey, graph: graph, payload: 2, nodeType: .image)
            
            let c = MockBlendNode(cKey, graph: graph, payload: 0, nodeType: .blend)
            c.source = a
            c.destination = b
            
            subgraph.finalNode = c
        }
        
        let aRev = graph.reverseEdges(for: aKey)!.asSet
        let bRev = graph.reverseEdges(for: bKey)!.asSet
        let cRev = graph.reverseEdges(for: cKey)!.asSet
        
        XCTAssert(aRev.count == 1)
        XCTAssert(aRev.contains(cKey))
        
        XCTAssert(bRev.count == 1)
        XCTAssert(bRev.contains(cKey))
        
        XCTAssert(cRev.isEmpty)
    }
    
    func testOverwritePayloadResetsRevData() {
        
    }
    
    func testRevEdgesThroughParent() {
        let store = Store()
        let initial = InternalSnapshot(store: store)
        store.commit(initial)
        
        let subgraphKey = SubgraphKey()
        let aKey = NodeKey()
        let bKey = NodeKey()
        let cKey = NodeKey()
        
        var graph = initial.modify { graph in
            let subgraph = graph.subgraph(for: subgraphKey)
            
            let a = MockImageNode(aKey, graph: graph, payload: 1, nodeType: .image)
            let b = MockImageNode(bKey, graph: graph, payload: 2, nodeType: .image)
            
            let c = MockBlendNode(cKey, graph: graph, payload: 0, nodeType: .blend)
            c.source = a
            c.destination = b
            
            subgraph.finalNode = c
        }
        
        graph = graph.modify { graph in
            let subgraph = graph.subgraph(for: subgraphKey)
            subgraph.metaNode = MockFilterNode(graph: graph, payload: 99, nodeType: .filter)
        }
        
        let aRev = graph.reverseEdges(for: aKey)!.asSet
        let bRev = graph.reverseEdges(for: bKey)!.asSet
        let cRev = graph.reverseEdges(for: cKey)!.asSet
        
        XCTAssert(aRev.count == 1)
        XCTAssert(aRev.contains(cKey))
        
        XCTAssert(bRev.count == 1)
        XCTAssert(bRev.contains(cKey))
        
        XCTAssert(cRev.isEmpty)
    }
    
    func testChangeInputSetsCorrectRevEdges() {
        let store = Store()
        let initial = InternalSnapshot(store: store)
        store.commit(initial)
        
        let subgraphKey = SubgraphKey()
        let aKey = NodeKey()
        let bKey = NodeKey()
        let cKey = NodeKey()
        
        var graph = initial.modify { graph in
            let subgraph = graph.subgraph(for: subgraphKey)
            
            let a = MockImageNode(aKey, graph: graph, payload: 1, nodeType: .image)
            let b = MockImageNode(bKey, graph: graph, payload: 2, nodeType: .image)
            
            let c = MockBlendNode(cKey, graph: graph, payload: 0, nodeType: .blend)
            c.source = a
            c.destination = b
            
            subgraph.finalNode = c
        }
        
        graph = graph.modify { graph in
            let c = MockBlendNode(cKey, graph: graph)
            c.source = MockImageNode(graph: graph, payload: 10, nodeType: .image)
        }
        
        let aRev = graph.reverseEdges(for: aKey)!.asSet
        let bRev = graph.reverseEdges(for: bKey)!.asSet
        let cRev = graph.reverseEdges(for: cKey)!.asSet
        
        XCTAssert(aRev.isEmpty)
        
        XCTAssert(bRev.count == 1)
        XCTAssert(bRev.contains(cKey))
        
        XCTAssert(cRev.isEmpty)
    }
    
}
