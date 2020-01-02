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
    
    func flatten(_ node: BlendNode) -> [BlendNode] {
        var current = node
        var nodes = [node]
        
        while true {
            guard let next = current.destination as? BlendNode else { break }
            
            nodes.append(next)
            current = next
        }

        return nodes
    }
    
//    func testThatBlendUsesSameKeysConsistently() {
//        let size = CGSize(width: 414, height: 630)
//        let creation = BlendCreation(canvasSize: size)
//        let manager = creation.canvasManager
//        let store = manager.store
//
//        let cache = CacheAndOptimizer(manager.subgraphKey)
//
//        for _ in 0...100 {
//            creation.push(.mock, .normal)
//
//            store.write {
//                let subgraph = manager.display.subgraph(for: creation.layerSubgraphKey)
//                let finalNode = subgraph.finalNode as! BlendNode
//
//                let flat = flatten(finalNode)
//
//                finalNode.log()
//
//                print("flat: \(flat)")
//                print("")
//            }
//        }
//
//
//    }
    
//    func testBlendExtents() {
//        let size = CGSize(width: 414, height: 630)
//        let creation = BlendCreation(canvasSize: size)
//        let manager = creation.canvasManager
//        let store = manager.store
//
//        let cache = CacheAndOptimizer(manager.subgraphKey)
//        
//        for _ in 0...100 {
//            creation.push(.mock, .normal)
//            
//            let opt = store.write { cache.march(manager.displayCanvas) }
//            
//            creation.render(format: <#T##RenderOptions.PixelFormat#>, colorSpace: <#T##RenderOptions.ColorSpace#>, <#T##callback: (MetalTexture) -> ()##(MetalTexture) -> ()#>)
//            
//            store.read {
//                let subgraph = opt.subgraph(for: manager.subgraphKey)
//                
//                let finalNode = subgraph.finalNode!
//                
//                let options = RenderOptions("context",
//                                            size: creation.canvasManager.size,
//                                            format: .sRGB,
//                                            time: 0)
//                
//                let payload = finalNode.renderPayload(for: options)
//                
////                creation.render(<#T##callback: (MetalTexture) -> ()##(MetalTexture) -> ()#>)
//                
//                print("- \(finalNode.calculatedRenderExtent)")
//                print("- \(payload?.extent)")
//                print(" ")
//            }
//        }
//        
//    }
    
}
