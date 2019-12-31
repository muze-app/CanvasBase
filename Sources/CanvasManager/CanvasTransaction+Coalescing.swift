////
////  CanvasTransaction+Coalescing.swift
////  muze
////
////  Created by Greg on 2/3/19.
////  Copyright © 2019 Ergo Sum. All rights reserved.
////
//
//import Foundation
//
//extension CanvasTransaction {
//    
//    func coalesceActions(canvas: Canvas, options: CoalescingOptions) {
////        print("coalesce \(_actions)")
//        
////        while let new = coalesceActionsOnce(canvas, options: options) {
//////            let old = _actions
//////
//////            var r1 = canvas.copy()
//////            r1 >> old
//////
//////            var r2 = canvas.copy()
//////            r2 >> new
//////
//////            assert(r1 == r2)
////
////            _actions = new
////        }
//        
////        print("    ...\(_actions)")
//    }
//    
//    func coalesceActionsOnce(_ canvas: Canvas, options: CoalescingOptions) -> [CanvasActionOld]? {
//
//        var current = canvas.copy()
//        for pair in actions.consecutivesZipper {
//            if let result = coalescePair(pair, current, options: options) {
//                return result
//            }
//            
//            current >> pair.1
//        }
//        
//        current = canvas.copy()
//        for element in actions.zipper {
//            if let result = coalesceElement(element, current, options: options) {
//                return result
//            }
//            
//            current >> element.1
//        }
//        
//        return nil
//    }
//
//    typealias Pair = ConsecutivesZipper<CanvasAction>.Element
//    typealias Element = Zipper<CanvasAction>.Element
//    typealias CoalescingOptions = CanvasActionOld.CoalescingOptions
//    
//    func coalescePair(_ pair: Pair, _ canvas: Canvas, options: CoalescingOptions) -> [CanvasActionOld]? {
////        let (pred, a, b, succ) = pair
////        if let result = a.coalesced(withSuccessor: b, options: options) {
//////            var r1 = canvas.copy()
//////            r1 >> a
//////            r1 >> b
//////
//////            var r2 = canvas.copy()
//////            r2 >> result
//////
//////            assert(r1 == r2)
////
////            return pred + [result] + succ
////        } else if let result = b.coalesced(withPredecessor: a, options: options) {
//////            var r1 = canvas.copy()
//////            r1 >> a
//////            r1 >> b
//////
//////            var r2 = canvas.copy()
//////            r2 >> result
//////
//////            assert(r1 == r2)
////
////            return pred + [result] + succ
////        }
//        
//        return nil
//    }
//    
//    func coalesceElement(_ element: Element, _ canvas: Canvas, options: CoalescingOptions) -> [CanvasActionOld]? {
////        let (pred, e, succ) = element
////        if let result = e.simplified(withOptions: options) {
////            
//////            var r1 = canvas.copy()
//////            r1 >> e
//////            
//////            var r2 = canvas.copy()
//////            r2 >> result
//////            
//////            assert(r1 == r2)
////            
////            return pred + result + succ
////        }
//        
//        return nil
//    }
//    
//}
