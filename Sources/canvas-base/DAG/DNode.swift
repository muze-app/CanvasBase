//
//  DNode.swift
//  muze
//
//  Created by Greg Fajen on 9/1/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation

class Nothing { }


class INode<PayloadType: NodePayload>: PayloadNode<PayloadType> {
    
    var input: Node? {
        get { nodeInputs[0] }
        set { nodeInputs[0] = newValue }
    }
    
//    override var worthCaching: Bool {
//        return input?.worthCaching ?? false
//    }
//
//    override var calculatedRenderExtent: RenderExtent {
//        return input?.renderExtent ?? .nothing
//    }
//
//    override var calculatedUserExtent: UserExtent {
//        return input?.userExtent ?? .nothing
//    }
    
}

@available(*, deprecated)
class DNode: Node {
//class DNode: CustomDebugStringConvertible {
    
//    let key: NodeKey
    @available(*, deprecated)
    var dag: DAG! { graph }
    
//    var type: DNodeType {
//        return dag.type(for: key)! // yeah kinda goofy
//    }
    
    
    
    
//    override public func log(with indentation: String = "") {
//        print("\(indentation)\(self)")
//
//        for input in inputs {
//            input.log(with: "\t" + indentation)
//        }
//    }
    
//    override var debugDescription: String {
//        return String("\(Swift.type(of: self)) (\(key))")
//    }
    
//    override final func update(from node: ComplicatedNode) {
//        fatalError()
//    }
    
//    override final func optimizeInputs(throughCacheNodes: Bool) {
//        let dag = self.dag as! MutableDAG
//
//        for (i, key) in edgeMap {
//            let node = dag.node(for: key)
//            let optimized = node.optimize(throughCacheNodes: throughCacheNodes)
//            dag.setInput(for: self.key, index: i, to: optimized?.key)
//        }
//    }
    
}

enum DNodeType: Hashable {
    
    case canvasMeta
    case layerMeta
    
    case image
//    case video
    
    case solidColor
    case maskedColor
    case blend
    case comp
    case mask
    case maskSeries
//    case mix
    case alpha
    case colorMatrix
    case brush
    
    case checkerboard
    
//    case caption
    case cache
    case effect
//    case crop
    case canvasOverlay
    case rects
    
    case transform
    
    case blurPreview
    
    
    case color, string
    
}

//class CNode: PNode<RenderColor2> {
//
//}

class SNode: PayloadNode<String> {
    
}

extension String: NodePayload {
    
}

extension DNode {
    
    static func test() {
//        let store = DAGStore()
//        let subgraph = SubgraphOld(store: store)
//        let empty = InternalDirectSnapshot(subgraph: subgraph)
//        let cKey = NodeKey()
//        let sKey = NodeKey()
//
//        let a = empty.modify { (graph) in
//            let c = CNode(cKey, graph: graph, payload: RenderColor2([1,0,0], a: 1), nodeType: .color)
//            let s = SNode(sKey, graph: graph, payload: "fish", nodeType: .string)
//            graph.setInput(for: s.key, index: 0, to: c.key)
//            graph.finalKey = s.key
//        }
//
//        let b = a.modify { (graph) in
//            let c = CNode(cKey, graph: graph)
//            let s = SNode(sKey, graph: graph)
//            c.payload = RenderColor2([0,1,1], a: 1)
//            s.payload = "boo"
//
//            graph.setInput(for: s.key, index: 0, to: nil)
//            graph.setInput(for: c.key, index: 0, to: s.key)
//            graph.finalKey = c.key
//        }
//
//        a.finalNode?.log()
//        b.finalNode?.log()
//
//        print("a.s: \(a.payload(for: sKey, of: String.self)!)")
//        print("b.s: \(b.payload(for: sKey, of: String.self)!)")
//
//        print("")
    }
    
}

class GNode<PayloadType: NodePayload>: PayloadNode<PayloadType> {
    
    
    
}

struct NodeInputs {
    
    weak var node: Node?
    
    init(_ node: Node) {
        self.node = node
    }

    subscript(i: Int) -> Node? {
        get {
            let node = self.node!
            let graph = node.graph
            
            if let key = graph.input(for: node.key, index: i) {
                return graph.node(for: key)
            } else {
                return nil
            }
        }
        
        set {
            (node?.graph as! MutableDAG).setInput(for: node!.key, index: i, to: newValue?.key)
        }
    }
    
}
