//
//  CanvasBaseTestCase.swift
//  CanvasBase
//
//  Created by Greg Fajen on 12/26/19.
//

import XCTest
@testable import DAG
@testable import CanvasBase
@testable import CanvasDAG

protocol CanvasBaseTestCase: XCTestCase {
    
    associatedtype Collection: NodeCollection
    
}

extension CanvasBaseTestCase {
    
    typealias Store = DAG.DAGStore<Collection>
    typealias Graph = DAGBase<Collection>
    typealias MutableGraph = MutableDAG<Collection>
    typealias InternalSnapshot = InternalDirectSnapshot<Collection>
    typealias Subgraph = DAG.Subgraph<Collection>
    
}

extension CanvasBaseTestCase where Collection == CanvasNodeCollection {
    
    var mockImagePayload: ImagePayload { .init(.mock, .identity, .identity) }
    
    func addLayer(to graph: MutableGraph,
                  subgraph: SubgraphKey,
                  blendMode: BlendMode = .normal,
                  alpha: Float = 1) {
        let subgraph = graph.subgraph(for: subgraph)
        
        let image = ImageNode(graph: graph, payload: mockImagePayload)
        let blend = BlendNode(graph: graph, payload: BlendPayload.init(blendMode, alpha))
        blend.source = image
        blend.destination = subgraph.finalNode
        
        subgraph.finalNode = blend
    }
    
    func addBrush(to graph: MutableGraph,
                  subgraph: SubgraphKey) {
        let subgraph = graph.subgraph(for: subgraph)
        
        let color = RenderColor2.white(1)
        
        let brushNode = ImageNode(graph: graph, payload: mockImagePayload)
        let colorNode = MaskedColorNode(graph: graph, payload: MaskedColorPayload(color, .whiteIsTransparent))
        let blendNode = BlendNode(graph: graph, payload: BlendPayload.init(.normal, 1))
        
        colorNode.mask = brushNode
        
        blendNode.source = colorNode
        blendNode.destination = subgraph.finalNode
        
        subgraph.finalNode = blendNode
    }
    
    func addEraser(to graph: MutableGraph,
                   subgraph: SubgraphKey) {
        let subgraph = graph.subgraph(for: subgraph)
        
        let brushNode = ImageNode(graph: graph, payload: mockImagePayload)
        let maskNode = MaskNode(graph: graph, payload: .whiteIsTransparent)
        
        maskNode.input = subgraph.finalNode
        maskNode.mask = brushNode
        
        subgraph.finalNode = maskNode
    }
    
}
