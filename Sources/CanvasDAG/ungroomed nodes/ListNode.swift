//
//  ListNode.swift
//  muze
//
//  Created by Greg Fajen on 5/19/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation
import DAG

extension Array: NodePayload where Element: NodePayload {
      
}

//class ListNode<PayloadElement: NodePayload>: PNode<[PayloadElement]> {
//    
//    typealias PayloadType = [PayloadElement]
//    
////    convenience init() {
////        self.init([])
////    }
////
////    required init(_ payload: PayloadType, _ key: Key = Key(), _ graph: NodeGraph? = nil) {
////        super.init(payload, key, graph)
////    }
//    
//    // MARK: Inputs
//    
////    var _inputs: [InputType] = []
//    
////    final override var inputs: [Node] {
////        return _inputs
////    }
//    
////    final override func transform(by transform: AffineTransform) {
////        payload = payload.transformed(by: transform)
////        for input in inputs {
////            input.transform(by: transform)
////        }
////    }
//    
//    func input(for index: Int) -> DNode? {
//        guard let key = edgeMap[index] else { return nil }
//        return dag.node(for: key)
//    }
//    
//    func set(input: DNode?, for index: Int) {
//        let dag = self.dag as! MutableDAG
//        dag.setInput(for: key, index: index, to: input?.key)
//    }
//    
////    subscript(index: Int) -> DNode? {
////        get { return input(for: index) }
////        set { set(input: newValue, for: index) }
////    }
//    
//    // MARK: Pairs
//    
//    typealias PairType = (PayloadElement,DNode?)
//    
//    var pairs: [PairType] {
//        get {
//            return payload.izip.map { ($0.1, input(for: $0.0)) }
//        }
//        
//        set {
//            payload = newValue.map { $0.0 }
//            
//            var edgeMap = [Int:NodeKey]()
//            
//            let nodes = newValue.map{ $0.1 }
//            for (i, node) in nodes.izip {
//                edgeMap[i] = node?.key
//            }
//            
//            let dag = self.dag as! MutableDAG
//            dag.setEdgeMap(edgeMap, for: key)
//        }
//    }
//    
//    // MARK: Hashing
//    
////    final override func hash(into hasher: inout Hasher, includeKeys: Bool) {
////        hasher.combine(nodeType)
////        
////        if includeKeys {
////            hasher.combine(key)
////        }
////        
////        hasher.combine(payload)
////        
////        for input in inputs {
////            input.hash(into: &hasher, includeKeys: includeKeys)
////        }
////    }
//    
//    // MARK: Updating
//    
////    final override func update(from node: Node) {
////        let node = node as! ListNode<PayloadElement>
////        payload = node.payload
////        _inputs = node.inputs.map { updated(inputFrom: $0) }
////
////        assert(payload.count == _inputs.count)
////        resetRenderExtent()
////    }
//    
//    
////    final func updated(inputFrom node: Node) -> Node {
////        guard let graph = graph else { fatalError() }
////
////        if let existing = graph[node.key] {
////            existing.update(from: node)
////            return existing
////        } else {
////            let newNode = Node.create(from: node, graph: graph)
////            graph.add(node: newNode)
////            newNode.update(from: node)
////            return newNode
////        }
////    }
//    
//    // MARK: Optimizing
//    
////    final override func optimizeInputs() {
////        for (i, input) in _inputs.izip {
////            self[i] = input.optimize() as! Node
////        }
////    }
//    
////    final override func replace(_ keyToReplace: NodeKey, with replacement: Node) {
////        for (i, input) in _inputs.izip {
////            if input.key == keyToReplace {
////                self[i] = replacement
////            }
////        }
////    }
////    
////    final override func addingCacheNodes(_ keysToCache: [NodeKey]) -> Node? {
////        _inputs = _inputs.map { $0.addingCacheNodes(keysToCache)! }
////        return super.addingCacheNodes(keysToCache)
////    }
//    
//    final override func _purgingUnneededCaches(isBehindCache: Bool) -> Node? {
//        fatalError()
//////        print("BEFORE")
//////        for input in _inputs {
//////            input.log(with: "\t")
//////        }
////
////        _inputs = _inputs.map{
////            $0._purgingUnneededCaches(isBehindCache: isBehindCache) ?? SolidColorNode(.clear)
////        }
////
//////        print("AFTER")
//////        for input in _inputs {
//////            input.log(with: "\t")
//////        }
////
////        return self
//    }
//    
//    public override var linearized: [Node] {
//        switch inputs.count {
//        case 0: return [self]
//        case 1: return [self] + inputs[0].linearized
//        default: fatalError()
//        }
//    }
//    
//}
