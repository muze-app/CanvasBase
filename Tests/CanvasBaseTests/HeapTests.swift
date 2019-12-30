//
//  HeapTests.swift
//  CanvasBaseTests
//
//  Created by Greg Fajen on 12/29/19.
//

import XCTest
@testable import MuzePrelude
@testable import MuzeMetal
@testable import DAG

class HeapTests: XCTestCase {

    func testHeap() {
        let set = PayloadBufferSet()
        
        weak var object: TrackableObject?
        
        var allocation: PayloadBufferAllocation?
        
//        print("size: \(set.all)")
        
        autoreleasepool {
            let object = TrackableObject()
            let payload = TrackablePayload(object: object)
            allocation = set.new(payload)
        }
        
        print("allocation: \(String(describing: allocation))")
        let a1 = set.used
        
        autoreleasepool {
            allocation = nil
        }
        
        let a2 = set.used
        
        XCTAssert(object == nil)
        XCTAssert(a1 > 0)
        XCTAssert(a2 == 0)
        XCTAssert(TrackableObject.count == 0)
    }
    
}

struct TrackablePayload {
    
    let object: TrackableObject
    
}

class TrackableObject {
    
    static var count: Int = 0
    
    init() {
        TrackableObject.count += 1
    }
    
    deinit {
        TrackableObject.count -= 1
    }
    
}
