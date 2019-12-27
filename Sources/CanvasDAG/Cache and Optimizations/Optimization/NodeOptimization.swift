//
//  NodeOptimization.swift
//  muze
//
//  Created by Greg Fajen on 5/17/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation
import DAG

public class Optimization {
    
    typealias Collection = CanvasNodeCollection
    typealias Graph = DAG.DAGBase<Collection>
    typealias MutableGraph = MutableDAG<Collection>
    
    typealias Node = CanvasNode
    
    var  left: CanvasNode
    var right: CanvasNode?
    
    var pointerString: String {
        let unsafe = Unmanaged.passUnretained(self).toOpaque()
        return "\(unsafe)"
    }
    
//    final var graph: NodeGraph! {
//        return left.graph!
//    }
    
    var isValid: Bool {
        fatalError("\(self) doesn't implement isValid")
    }
    
    required init?(_ source: CanvasNode) {
        self.left = source
        
        if !isValid { return nil }
        setupTarget(graph: source.graph as! MutableGraph)
    }
    
    func setupTarget(graph: MutableGraph) {
        fatalError()
    }
    
    private final func updateTarget() {
        fatalError()
    }
    
    private var ignoreOptimizationsCheck = false // to prevent infinite loops
    
    var sourceKey: NodeKey {
        return left.key
    }
    
    var targetKey: NodeKey? {
        return right?.key
    }
    
}
