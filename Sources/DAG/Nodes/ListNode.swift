//
//  ListNode.swift
//  CanvasBase
//
//  Created by Greg Fajen on 12/26/19.
//

import Foundation

extension Array: NodePayload where Element: NodePayload {
    
//    public func transformed(by transform: AffineTransform) -> [Element] {
//        map { $0.transformed(by: transform) }
//    }
    
}

open class ListNode<Collection: NodeCollection, PayloadElement: NodePayload>: PayloadNode<Collection, [PayloadElement]> {
    
    public typealias PayloadType = [PayloadElement]
    
    public func input(for index: Int) -> Node? {
        guard let key = edgeMap[index] else { return nil }
        return graph.node(for: key)
    }
    
    public func set(input: Node?, for index: Int) {
        let dag = graph as! MutableDAG
        dag.setInput(for: key, index: index, to: input?.key)
    }
    
//    subscript(index: Int) -> Node? {
//        get { return input(for: index) }
//        set { set(input: newValue, for: index) }
//    }
    
    // MARK: Pairs
    
    public typealias PairType = (PayloadElement, Node?)
    
    public var pairs: [PairType] {
        get {
            return payload.enumerated().map { ($0.1, input(for: $0.0)) }
        }
        
        set {
            payload = newValue.map { $0.0 }
            
            var edgeMap = [Int:NodeKey]()
            
            let nodes = newValue.map { $0.1 }
            for (i, node) in nodes.enumerated() {
                edgeMap[i] = node?.key
            }
            
            let dag = self.graph as! MutableGraph
            dag.setEdgeMap(edgeMap, for: key)
        }
    }
    
}
