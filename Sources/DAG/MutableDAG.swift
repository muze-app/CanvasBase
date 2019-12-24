//
//  MutableDAG.swift
//  DAG
//
//  Created by Greg Fajen on 12/21/19.
//

import Foundation
import MuzePrelude

public typealias MutableDAG = InternalDirectSnapshot

public extension MutableDAG {
    
    func setFinalNode(_ node: Node?, for subgraph: SubgraphKey) {
        setFinalKey(node?.key, for: subgraph)
    }
    
    func setMetaNode(_ node: Node?, for subgraph: SubgraphKey) {
        setMetaKey(node?.key, for: subgraph)
    }
    
}
