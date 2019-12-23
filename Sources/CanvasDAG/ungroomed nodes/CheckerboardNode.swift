//
//  CheckerboardNode.swift
//  muze
//
//  Created by Greg Fajen on 12/17/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import UIKit

//final class CheckerboardNode: GNode<One> {
//
//    init(_ key: NodeKey = NodeKey(), graph: DAG) {
//        super.init(key, graph: graph, payload: .one, nodeType: .checkerboard)
//    }
//
//    override public func renderPayload(for options: RenderOptions) -> RenderPayload? {
//        let result = RenderIntermediate(identifier: "Checkerboard", options: options, extent: renderExtent)
//        result << RenderPassDescriptor(identifier: "Checkerboard",
//                                       pipeline: .checkerboardPipeline,
//                                       fragmentBuffers: [])
//
//        return result.payload
//    }
//
//    override var calculatedRenderExtent: RenderExtent {
//        return .screen
//    }
//
//    override var calculatedUserExtent: UserExtent {
//        return .brush & calculatedRenderExtent
//    }
//
//}

extension RenderExtent {
    
    static let screen = RenderExtent.basic(.init(rect: UIScreen.main.nativeBounds))
    
}
