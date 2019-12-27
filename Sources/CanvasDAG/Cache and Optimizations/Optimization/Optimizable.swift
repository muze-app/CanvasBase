//
//  Optimizable.swift
//  muze
//
//  Created by Greg Fajen on 5/17/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation

public typealias OptFunc = (CanvasNode) -> Optimization?

//public protocol Optimizable {
//    
//    var possibleOptimizations: [OptFunc] { get }
//    
//    func optimize() -> Node
////    func deepOptimize() -> NodeOrOpt
////    func optimize(deep: Bool, shallow: Bool) -> NodeOrOpt
//    
//}

//extension Optimizable {
//
////    public var target: Node? {
////        return asNodeOrOpt.targetNode(OptimizedU.self)
////    }
//
////    public var asNodeOrOpt: NodeOrOpt {
////        if let self = self as? Node {
////            return .n(self)
////        }
////
////        if let self = self as? Optimization {
////            return .o(self)
////        }
////
////        if let self = self as? NodeOrOpt {
////            return self
////        }
////
////        fatalError()
////    }
//
//    public func optimizeOnce() -> OptimizedNode? {
////        asNodeOrOpt.log()
//        for optimize in possibleOptimizations {
//            if let optimization = optimize(self as) {
////                print("    optimized!")
//                return optimization.target
//            }
//        }
//
//        return nil
//    }
//
//    var representedKey: NodeKey {
//        return asNodeOrOpt.sourceNode(OptimizedU.self).key
//    }
//
//    public func optimize(deep: Bool, shallow: Bool) -> NodeOrOpt {
//        assert(deep || shallow)
//        let oldRepesentedKey = representedKey
//        var result: NodeOrOpt = asNodeOrOpt
//
//        if deep {
//            let optimized = result.deepOptimize()
//
//            if (oldRepesentedKey != optimized.representedKey) {
//                print("BEFORE: \(result.representedKey)")
//                result.log()
//
//                print("AFTER: \(optimized.representedKey)")
//                optimized.logOpt()
//
//                fatalError()
//            }
//
//            result = optimized
//        }
//
//        if shallow {
//            let optimized = result.shallowOptimize()
//
//            if (oldRepesentedKey != optimized.representedKey) {
//                print("BEFORE: \(result.representedKey)")
//                result.log()
//
//                print("AFTER: \(optimized.representedKey)")
//                optimized.logOpt()
//
//                fatalError()
//            }
//
//            result = optimized
//        }
//
//        return result
//    }
//
//}

// MARK: move me maybe?

//extension NodeOrOpt {
//
//    public func logOpt() {
//        logOpt(with: "")
//    }
//
//    public func logOpt(with indentation: String) {
//        switch self {
//        case let .n(node):
//            print("\(indentation)(node)")
//            node.logOpt(with: indentation)
//        case let .o(opt):
//            print("\(indentation)(optimization)")
//            opt.logOpt(with: indentation)
//        case let .r(redirect):
//            print("\(indentation)(redirect)")
//            redirect.logOpt(with: indentation)
//        }
//    }
//
//}

extension Optimization {
    
    public var className: String {
        return "\(type(of: self))"
    }
    
//    public func logOpt() {
//        logOpt(with: "")
//    }
    
//    public func logOpt(with indentation: String) {
//        print("\(indentation)\(className) (\(pointerString)). Valid: \(isValid)")
//        print("\(indentation)\tTARGET:")
//
//        if let target = right {
//            target.logOpt(with: "\(indentation)\t\t")
//        } else {
//            print("\(indentation)\t\tnil")
//        }
//
//        print("\(indentation)\tSOURCE:")
//        left.logOpt(with: "\(indentation)\t\t")
//    }
    
}

//extension Node {
//
//    public func logOpt() {
//        log(with: "")
//    }
//
//    public func logOpt(with indentation: String) {
//        print("\(indentation)\(self) (\(key))")
////
////        for input in inputs {
//////            input.logOpt(with: "\t" + indentation)
////        }
//    }
//
//}
