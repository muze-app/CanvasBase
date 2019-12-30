//
//  PurgingTests.swift
//  CanvasBaseTests
//
//  Created by Greg Fajen on 12/30/19.
//

import XCTest
@testable import DAG
@testable import CanvasDAG
@testable import CanvasBase

final class PurgingTests: XCTestCase, CanvasBaseTestCase {
    
    typealias Collection = CanvasNodeCollection
    typealias Snapshot = DAGSnapshot<Collection>
    
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
    
    func setupFirstTen(_ store: Store, _ subgraphKey: SubgraphKey) -> [Snapshot] {
        let initial = InternalSnapshot(store: store)
        store.commit(initial)
        
        var graph: Graph = initial
        return addThreeLayers(to: &graph, subgraph: subgraphKey)
    }
    
    func setupSecondTen(_ store: Store, _ subgraphKey: SubgraphKey) -> [Snapshot] {
        var graph: Graph = store.latest
        return addThreeLayers(to: &graph, subgraph: subgraphKey)
    }
    
    func testPurge() {
        let store = Store()
        let subgraphKey = SubgraphKey()
        
        var first: [Snapshot] = autoreleasepool { setupFirstTen(store, subgraphKey) }
        let second: [Snapshot] = autoreleasepool { setupSecondTen(store, subgraphKey) }
     
        let commitCount = store.sortedCommits.count
        print("first.count: \(first.count)")
        print("second.count: \(second.count)")
        print("commit count: \(commitCount)")
        
        XCTAssert(store.sortedCommits.count == 6)
        
        first = []
        
        XCTAssert(store.sortedCommits.count == 3)
        
        store.simplifyTail()
        let commits = store.sortedCommits
        let changed = Set( commits.tail.flatMap { $0.nodesTouchedSincePredecessor } )
        let unchanged = commits.head.allSubgraphs.flatMap { $0.finalNode?.nodes(thatDoNotContain: changed) ?? [] }
        
        for n in unchanged {
            print("- \(n)")
        }
        
        XCTAssert(unchanged.count == 1)
        
        let oldKey = unchanged.first!
        let newKey = NodeKey()
        
        for commit in commits {
            let commit = commit.alias { graph in
                let replacement = SolidColorNode(newKey, graph: graph, payload: RenderColor2.red)
                graph.replace(oldKey, with: replacement)
            }
            
            store.commit(commit)
        }
        
        store.simplifyHead()
        
//        let newHead = commits.head.alias { graph in
//            let replacement = SolidColorNode(newKey, graph: graph, payload: RenderColor2.red)
//                graph.replace(oldKey, with: replacement)
//        } .flattened
//
//        store.commit(newHead)
//        store.simplifyTail()
        
        print("head key: \(commits.head.key)")
        print(" old key: \(oldKey)")
        print(" new key: \(newKey)")
        
        print("CHECKING...")
        
        for commit in store.sortedCommits {
            print("COMMIT \(commit.key)")
            
            let final = commit.subgraph(for: subgraphKey).finalNode!
            
            let containsOld = final.contains(oldKey)
            let containsNew = final.contains(newKey)
            
            final.log()
            
            print("contains old: \(containsOld)")
            print("contains new: \(containsNew)")
            
            XCTAssert(!containsOld)
            XCTAssert(containsNew)
        }
    }

}
