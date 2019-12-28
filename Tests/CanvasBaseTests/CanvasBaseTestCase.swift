//
//  CanvasBaseTestCase.swift
//  CanvasBase
//
//  Created by Greg Fajen on 12/26/19.
//

import XCTest
@testable import DAG
@testable import CanvasBase
@testable import CanvasDAG

class CanvasBaseTestCase<Collection: NodeCollection>: XCTestCase {
    
//    typealias Collection = MockNodeCollection
    typealias Store = DAG.DAGStore<Collection>
    typealias Graph = DAGBase<Collection>
    typealias MutableGraph = MutableDAG<Collection>
    typealias InternalSnapshot = InternalDirectSnapshot<Collection>
    typealias Subgraph = DAG.Subgraph<Collection>
    
}
