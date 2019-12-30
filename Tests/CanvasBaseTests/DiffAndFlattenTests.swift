//
//  DiffAndFlattenTests.swift
//  CanvasBaseTests
//
//  Created by Greg Fajen on 12/29/19.
//

import XCTest
@testable import DAG
@testable import CanvasDAG
@testable import CanvasBase

final class DiffAndFlattenTests: XCTestCase, CanvasBaseTestCase {
    
    typealias Collection = CanvasNodeCollection
    
    func addTenLayers(to graph: inout Graph, subgraph: SubgraphKey) {
        graph = graph.modify { graph in
            self.addLayer(to: graph, subgraph: subgraph)
        }
    }
    
    func graph(_ a: Graph, equals b: Graph) -> Bool {
        guard a.allSubgraphKeys == b.allSubgraphKeys else { return false }
        
        for key in a.allSubgraphKeys where !subgraph(key, of: a, equals: b) {
            return false
        }
        
        return true
    }
    
    func subgraph(_ subgraph: SubgraphKey, of a: Graph, equals b: Graph) -> Bool {
        let a = a.subgraph(for: subgraph)
        let b = b.subgraph(for: subgraph)
        
        guard node(a.metaNode, equals: b.metaNode) else {
            return false
        }
        
        guard node(a.finalNode, equals: b.finalNode) else {
            return false
        }
        
        return true
    }
    
    func node(_ a: Node?, equals b: Node?) -> Bool {
        if a == nil, b == nil { return true }
        guard let a = a, let b = b else {
            return false
        }
        
        return a.equal(to: b)
    }
    
    func testThatEqualWorks() {
        let store = Store()
        let initial = InternalSnapshot(store: store)
        store.commit(initial)
        
        var graph: Graph = initial
        let subgraphKey = SubgraphKey()
        
        addTenLayers(to: &graph, subgraph: subgraphKey)
        
        XCTAssert(self.graph(graph, equals: graph))
    }
    
    func testThatFlattenWorks() {
        let store = Store()
        let initial = InternalSnapshot(store: store)
        store.commit(initial)
        
        var graph: Graph = initial
        let subgraphKey = SubgraphKey()
        
        addTenLayers(to: &graph, subgraph: subgraphKey)
        let older = graph
        
        addTenLayers(to: &graph, subgraph: subgraphKey)
        let newer = graph
        
        let olderFlattened = older.flattened
        let newerFlattened = newer.flattened
        
        XCTAssert(olderFlattened.depth == 0)
        XCTAssert(newerFlattened.depth == 0)
        
        XCTAssert(self.graph(olderFlattened, equals: older))
        XCTAssert(self.graph(newerFlattened, equals: newer))
    }
    
    func testThatDiffWorks() {
        let store = Store()
        let initial = InternalSnapshot(store: store)
        store.commit(initial)
        
        var graph: Graph = initial
        let subgraphKey = SubgraphKey()
        
        addTenLayers(to: &graph, subgraph: subgraphKey)
        let older = graph
        
        addTenLayers(to: &graph, subgraph: subgraphKey)
        let newer = graph
        
        let diff = newer.diff(from: older.internalReference.internalSnapshot)
        
        XCTAssert(diff.depth == older.depth + 1)
        
        XCTAssert(self.graph(diff, equals: newer))
    }
    
}
