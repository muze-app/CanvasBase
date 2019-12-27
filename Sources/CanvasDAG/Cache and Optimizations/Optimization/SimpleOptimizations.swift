//
//  SimpleOptimizations.swift
//  muze
//
//  Created by Greg Fajen on 5/17/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation

final class RemoveInvisibleOptimization: Optimization {
    
    override var isValid: Bool {
//        return false
        let r = left.isInvisible
        return r
    }
    
    // target is always nil
    override func setupTarget(graph: MutableGraph) { }
    
}

final class RemoveIdentityOptimization: Optimization {
    
    var inputNode: Node? {
        return left
    }
    
    override var isValid: Bool {
//        return false
        return inputNode?.isIdentity ?? false
    }
    
    override func setupTarget(graph: MutableGraph) {
        right = inputNode!.inputs.first
    }
    
}

//final class DeepOptimizationPatch: Optimization {
//    
//    // normally, optimizations are 'undoable' by just replacing them with their source
//    // however, we need to re-optimize graphs that have been updated but have partial optimizations
//    // in order to avoid redoing all optimizations everytime, we need optimizations to be able to deepOptimize
//    // going through the source, this will always recreate the optimization
//    // so, we go to the target. the problem is that this trick breaks our invariant that the original source is always
//    // in the final tree
//    
//    // this 'patch' class fixes that
//    var originalOptimization: Optimization {
//        switch source {
//        case .n: fatalError()
//        case .o(let o): return o
//        case .p: fatalError()
//        }
//    }
//    
//    let targetOptimization: Optimization
//    
//    init?(original: Optimization, target: Optimization) {
//        targetOptimization = target
//        super.init(.o(original))
//    }
//    
//    required init?(_ source: NodeOrOpt) {
//        fatalError("init(_:) has not been implemented")
//    }
//    
//    override var isValid: Bool {
//        return originalOptimization.isValid && targetOptimization.isValid
//    }
//    
//   override func setupTarget() {
//        
//    }
//    
//    override func updateTarget() {
//        targetOptimization.updateTarget()
//    }
//    
//    override var _target: Node? {
//        get { return targetOptimization._target }
//        set { }
//    }
//    
//}
