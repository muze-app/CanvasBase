//
//  CoalescingOptimization.swift
//  muze
//
//  Created by Greg Fajen on 5/17/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation
import DAG

class CoalescingOptimization<PayloadType: NodePayload,
                             NodeType: InputNode<PayloadType>>: Optimization {
    
    init?(_ source: NodeType, coalescingFunction: @escaping CoalescingFunction) {
        self.coalescingFunction = coalescingFunction
        super.init(source)
    }
    
    required init?(_ source: Node) {
        fatalError("CoalescingOptimization is an abstract class")
    }
    
    var parent: NodeType? {
        return left as? NodeType
    }
    
    var child: NodeType? {
        return parent?.input as? NodeType
    }
    
    // precondition isValid is true; sourceInput exists and has type NodeType
    override final func setupTarget(graph: MutableGraph) {
        let parent = self.parent!
        let child = self.child!
        let type = graph.type(for: parent.key)
        
        let payload = targetPayload!
        
        let target = PayloadNode<PayloadType>(graph: graph, payload: payload, nodeType: type)
        
        graph.setInput(for: target.key, index: 0, to: child.input?.key)
        
        right = target
    }
    
    override var isValid: Bool {
        return child.exists // implies parent exists
    }
    
    typealias CoalescingFunction = (PayloadType, PayloadType) -> PayloadType
    
    let coalescingFunction: CoalescingFunction
    
    var targetPayload: PayloadType? {
        guard let a = parent, let b = child else { return nil }
        return coalescingFunction(a.payload, b.payload)
    }
    
}
