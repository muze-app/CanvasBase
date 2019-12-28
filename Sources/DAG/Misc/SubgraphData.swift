//
//  Subgraph.swift
//  muze
//
//  Created by Greg Fajen on 9/28/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation

public typealias SubgraphKey = Key<SubgraphData>

public struct SubgraphData: Equatable, Hashable {
    
    let key: SubgraphKey
    var finalKey: NodeKey?
    var metaKey: NodeKey?
    
    init(key: SubgraphKey = .init()) {
        self.key = key
    }
    
}

public class Subgraph<Collection: NodeCollection> {
    
    public typealias Node = GenericNode<Collection>
    public typealias Graph = DAGBase<Collection>
    public typealias MutableGraph = MutableDAG<Collection>
    
    var die: Never { fatalError() }
    
    public let key: SubgraphKey
    public let graph: Graph
    public var mutableGraph: MutableGraph { graph as! MutableGraph }
    
    public init(key: SubgraphKey, graph: Graph) {
        self.key = key
        self.graph = graph
    }
    
    public var finalKey: NodeKey? {
        get { return graph.finalKey(for: key) }
        set { mutableGraph.setFinalKey(newValue, for: key) }
    }
    
    public var metaKey: NodeKey? {
        get { return graph.metaKey(for: key) }
        set { mutableGraph.setMetaKey(newValue, for: key) }
    }
    
    public var finalNode: Node? {
        get { return graph.finalNode(for: key) }
        set { mutableGraph.setFinalNode(newValue, for: key) }
    }
    
    public var metaNode: Node? {
        get { return graph.metaNode(for: key) }
        set { mutableGraph.setMetaNode(newValue, for: key) }
    }
    
}
