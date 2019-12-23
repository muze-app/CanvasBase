//
//  NodeAnimation.swift
//  muze
//
//  Created by Greg Fajen on 5/26/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation
import DAG

class NodeAnimationBase {
    
    let key: NodeKey
    let start, end: Date
    let f: (Float)->Float
    var keepAround = false
    
    init(_ key: NodeKey, _ duration: TimeInterval, _ f: @escaping (Float)->Float) {
        self.key = key
        self.start = Date()
        self.end = Date() + duration
        self.f = f
    }
    
    var duration: TimeInterval {
        return end.timeIntervalSince(start)
    }
    
    var progress: Float {
//        let total = end - start
//        let progress = -start.timeIntervalSinceNow
        fatalError()
//        return Float(progress / total).clamp()
    }
    
    var t: Float {
        return f(progress)
    }
    
    var isCompleted: Bool {
        return end.timeIntervalSinceNow < 0
    }
    
    func update(_ node: GenericNode<MockNodeCollection>) {
        
    }
    
}

//class NodeAnimation<Payload: NodePayload & Animatable>: NodeAnimationBase {
//    
//    typealias NodeType = PNode<Payload>
//    
//    let source, target: Payload
//    
//    init(_ key: NodeKey, source: Payload, target: Payload, duration: TimeInterval, _ f: @escaping (Float)->Float = { $0 }) {
//        self.source = source
//        self.target = target
//        super.init(key, duration, f)
//    }
//    
//    var value: Payload {
//        fatalError()
////        return source.blend(with: target, t)
//    }
//    
//    override func update(_ node: Node) {
////        if node is DNode {
////            print("not animating \(node) during DAG refactor")
////            return
////        }
////
////        if let node = node as? CanvasOverlayNode {
////            let value = self.value as! CanvasOverlayPayload
////            node.cropMode = value.cropMode
////            return
////        }
////
////
////
////        let node = node as! NodeType
////        node.payload = value
//    }
//    
//}

//protocol Animatable: Blendable {
//    
//    
//}

extension Date {
    
    static func - (l: Date, r: Date) -> TimeInterval {
        return l.timeIntervalSince(r)
    }
    
}
