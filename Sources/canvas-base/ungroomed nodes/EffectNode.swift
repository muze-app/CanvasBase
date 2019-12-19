//
//  EffectNode.swift
//  muze
//
//  Created by Greg Fajen on 6/11/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation

//struct EffectPayload: NodePayload {
//    
//    var effect: Effect
//    
//    static func == (l: EffectPayload, r: EffectPayload) -> Bool {
//        return l.effect.equal(to: r.effect)
//    }
//    
//    func hash(into hasher: inout Hasher) {
//        effect.hash(into: &hasher)
//    }
//    
//}
//
//class EffectNode: INode<EffectPayload> {
//    
//    convenience init(_ key: NodeKey = NodeKey(), graph: DAG, effect: Effect) {
//        self.init(key, graph: graph, payload: EffectPayload(effect: effect))
//    }
//    
//    init(_ key: NodeKey = NodeKey(), graph: DAG, payload: EffectPayload? = nil) {
//        super.init(key, graph: graph, payload: payload, nodeType: .effect)
//    }
//    
//    var effect: Effect {
//        get { return payload.effect }
//        set { payload.effect = newValue }
//    }
//    
//    
//    override var cost: Int {
//        return 1 + (input?.cost ?? 0)
//    }
//    
//    override var worthCaching: Bool {
//        return true
//    }
//    
//    override var calculatedRenderExtent: RenderExtent {
//        return input?.renderExtent ?? .nothing
//    }
//    
//    override var calculatedUserExtent: UserExtent {
//        return input?.userExtent ?? .nothing
//    }
//
//    override func renderPayload(for options: RenderOptions) -> RenderPayload? {
//        guard let input = self.input?.renderPayload(for: options) else {
//            return nil
//            
//        }
////        #warning("fix me")
////        return input
////
////        print("effect input: \(input)")
//
//        let intermediate = RenderIntermediate(identifier: effect.name, options: options, extent: renderExtent)
//        intermediate << effect.renderPass(with: input)
//
//        return intermediate.payload
//    }
//    
//}
