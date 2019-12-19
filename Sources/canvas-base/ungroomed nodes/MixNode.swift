//
//  MixNode.swift
//  muze
//
//  Created by Greg Fajen on 6/5/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation

enum MixInputKey {
    case a, b, c
}

//class MixNode: InputNode<One, MixInputKey> {
//    
//    override var nodeType: NodeType {
//        return .mix
//    }
//    
//    var a: InputType?
//    var b: InputType?
//    var c: InputType?
//    
//    final override var allKeys: [MixInputKey] { return [.a,.b,.c] }
//    final override func forInput(_ key: MixInputKey, _ mutate: (inout Node?) -> ()) {
//        switch key {
//        case .a: mutate(&a)
//        case .b: mutate(&b)
//        case .c: mutate(&c)
//        }
//    }
//    
//    override var primaryInput: InputType? {
//        get { return a }
//        set { a = newValue }
//    }
//    
//    override public func renderPayload(for options: RenderOptions) -> RenderPayload? {
//        guard let a = self.a?.renderPayload(for: options) else { return b?.renderPayload(for: options) }
//        guard let b = self.b?.renderPayload(for: options) else { return a }
//        guard let c = self.c?.renderPayload(for: options) else { return a }
//        
//        let masked = RenderIntermediate(identifier: "Mix", options: options, extent: renderExtent)
//        masked << RenderPassDescriptor(identifier: "Mix",
//                                       pipeline: .mixPipeline,
//                                       inputs: [a,b,c])
//        
//        return masked.payload
//    }
//    
//    override var calculatedRenderExtent: RenderExtent {
//        guard let ae = a?.renderExtent else { return b?.renderExtent ?? .nothing }
//        guard let be = b?.renderExtent else { return ae }
//        return ae.union(with: be)
//    }
//    
//}
