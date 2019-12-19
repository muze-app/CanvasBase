////
////  PayloadBufferTests.swift
////  muze
////
////  Created by Greg Fajen on 9/1/19.
////  Copyright © 2019 Ergo Sum. All rights reserved.
////
//
//import XCTest
//@testable import muze
//
//import UIKit
//
//struct TempPayload {
//    
//    let view: UIView
//    
//}
//
//class PayloadBufferTests: XCTestCase {
//    
//    func testAlloc() {
//        let bufferSet = PayloadBufferSet()
//        let buffer = PayloadBuffer(bufferSet: bufferSet)!
//        var pointer: UnsafeMutablePointer<TempPayload>!
//        
//        autoreleasepool {
//            let view = UIView()
//            view.backgroundColor = .orange
//            let payload = TempPayload(view: view)
//            pointer = buffer.new(payload)!
//        }
//        
//        let payload = pointer.pointee
//        let view = payload.view
//        let color = view.backgroundColor
//        XCTAssert(color == .orange)
//    }
//    
//    func testDealloc() {
//        var bufferSet: PayloadBufferSet? = PayloadBufferSet()
//        var buffer = PayloadBuffer(bufferSet: bufferSet!)
//        weak var weakView: UIView? = nil
//        
//        autoreleasepool {
//            let view = UIView()
//            view.backgroundColor = .orange
//            weakView = view
//            
//            let payload = TempPayload(view: view)
//            _ = buffer!.new(payload)!
//            
//            bufferSet = nil
//            buffer = nil
//        }
//        
//        XCTAssert(!weakView.exists)
//    }
//    
//}
