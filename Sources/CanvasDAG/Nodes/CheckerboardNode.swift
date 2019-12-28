//
//  CheckerboardNode.swift
//  muze
//
//  Created by Greg Fajen on 12/17/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import MuzeMetal

public enum One { case one } // Not as silly as it might first appear...

public class CheckerboardNode: GeneratorNode<One> {

    public init(_ key: NodeKey = NodeKey(), graph: Graph) {
        super.init(key, graph: graph, payload: .one, nodeType: .checkerboard)
    }

    override public func renderPayload(for options: RenderOptions) -> RenderPayload? {
        let result = RenderIntermediate(identifier: "Checkerboard", options: options, extent: renderExtent)
        result << RenderPassDescriptor(identifier: "Checkerboard",
                                       pipeline: .checkerboardPipeline,
                                       fragmentBuffers: [])

        return result.payload
    }

    override public var calculatedRenderExtent: RenderExtent {
        return .screen
    }

    override public var calculatedUserExtent: UserExtent {
        return .brush & calculatedRenderExtent
    }

}

public extension RenderExtent {

    static let screen = RenderExtent.basic(.init(rect: UIScreen.main.nativeBounds))

}
