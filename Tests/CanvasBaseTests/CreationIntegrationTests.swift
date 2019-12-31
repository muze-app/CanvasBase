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
        }
        
        XCTAssert(true)
    }
    
}
