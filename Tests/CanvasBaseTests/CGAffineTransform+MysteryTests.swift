//
//  CGAffineTransform+MysteryTests.swift
//  Unit Tests
//
//  Created by Greg Fajen on 10/13/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import XCTest
@testable import MuzePrelude

class AffineMysteryTests: XCTestCase {
    
    func check(_ transform: AffineTransform) {
        let transform = transform.cg
        
        let zeroZero = CGPoint(x: 0, y: 0).applying(transform)
        let zeroOne  = CGPoint(x: 0, y: 1).applying(transform)
        let  oneZero = CGPoint(x: 1, y: 0).applying(transform)
        
        let mystery = CGAffineTransform(mystery: zeroZero, zeroOne, oneZero)
        
        XCTAssert(mystery ~= transform)
    }
    
    func testIdentity() {
        check(.identity)
    }
    
    func testScale() {
        check(.scaling(x: 2, y: 3))
    }
    
    func testTranslate() {
        check(.translating(x: 1, y: 3))
    }
    
    func testRotation() {
        check(.rotating(2))
    }
    
    func testScaleTranslate() {
        check(.scaling(x: 2, y: 3) * .translating(x: 5, y: 7))
    }
    
    func testScaleRotate() {
        check(.scaling(x: 2, y: 3) * .rotating(17))
    }
    
    func testTranslateRotate() {
        check(.translating(x: 1, y: 3) * .rotating(19))
    }
    
    func testAllThree() {
        check(.translating(x: 1, y: 3) * .rotating(17) * .scaling(x: 2, y: 3))
    }
    
}
