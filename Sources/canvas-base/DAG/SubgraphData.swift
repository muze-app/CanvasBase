//
//  Subgraph.swift
//  muze
//
//  Created by Greg Fajen on 9/28/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation

typealias SubgraphKey = Key<SubgraphData>

struct SubgraphData: Equatable, Hashable {
    
    let key: SubgraphKey
    var finalKey: NodeKey?
    var metaKey: NodeKey?
    
    init(key: SubgraphKey = .init()) {
        self.key = key
    }
    
}

class Subgraph {
    
    var die: Never { fatalError() }
    
    let key: SubgraphKey
    let graph: DAG
    var mutableGraph: MutableDAG { return graph as! MutableDAG }
    
    init(key: SubgraphKey, graph: DAG) {
        self.key = key
        self.graph = graph
    }
    
    var finalKey: NodeKey? {
        get { die /*return graph.finalKey(for: key)*/ }
        set { mutableGraph.setFinalKey(newValue, for: key) }
    }
    
    var metaKey: NodeKey? {
        get { return graph.metaKey(for: key) }
        set { mutableGraph.setMetaKey(newValue, for: key) }
    }
    
    var finalNode: Node? {
        get { return graph.finalNode(for: key) }
        set { mutableGraph.setFinalNode(newValue, for: key) }
    }
    
    var metaNode: Node? {
        get { return graph.metaNode(for: key) }
        set { mutableGraph.setMetaNode(newValue, for: key) }
    }
    
}
