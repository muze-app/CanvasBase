//
//  CreationIntegrationTests.swift
//  CanvasBase
//
//  Created by Greg Fajen on 12/31/19.
//

import XCTest
@testable import DAG
@testable import CanvasDAG
@testable import CanvasBase
@testable import CanvasManager

final class CreationIntegrationTests: XCTestCase, CanvasBaseTestCase {
    
    typealias Collection = CanvasNodeCollection
    
    func testBlendCreation() {
        
        let creation = BlendCreation()
        
        for _ in 0...100 {
            creation.push(.mock, .normal)
            
//            let node = creation.canvasManager.current.subgraph(for: creation.canvasManager.subgraphKey).finalNode!
//            
//            guard node.depth < 20 else {
//                fatalError()
//            }
            
        }
        
        XCTAssert(true)
    }
    
    func testBlendExtents() {
        let size = CGSize(width: 414, height: 630)
        let creation = BlendCreation(canvasSize: size)
        let manager = creation.canvasManager
        let store = manager.store
        
        for _ in 0...100 {
            creation.push(.mock, .normal)
            
            store.read {
                let subgraph = manager.displayCanvas.subgraph(for: manager.subgraphKey)
                
                let finalNode = subgraph.finalNode!
                
                print("- \(finalNode.calculatedRenderExtent)")
            }
        }
        
    }
    
}
