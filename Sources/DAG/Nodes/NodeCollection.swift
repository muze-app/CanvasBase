//
//  NodeCollection.swift
//  canvas-base
//
//  Created by Greg Fajen on 12/19/19.
//

import Foundation

public protocol NodeCollection: Hashable {
    
    func node(for key: NodeKey, graph: DAGBase<Self>) -> GenericNode<Self>
    
}
