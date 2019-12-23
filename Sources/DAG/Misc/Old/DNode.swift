//
//  DNode.swift
//  muze
//
//  Created by Greg Fajen on 9/1/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation

class Nothing { }


public class INode<Collection: NodeCollection, PayloadType: NodePayload>: PayloadNode<Collection, PayloadType> {
    
    var input: GenericNode<Collection>? {
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



open class GeneratorNode<Collection: NodeCollection, PayloadType: NodePayload>: PayloadNode<Collection, PayloadType> {
    
    
    
}

public struct NodeInputs<Collection: NodeCollection> {
    
    typealias Node = GenericNode<Collection>
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
            (node?.graph as! MutableDAG<Collection>).setInput(for: node!.key, index: i, to: newValue?.key)
        }
    }
    
}
