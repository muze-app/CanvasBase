//
//  SolidColorNode.swift
//  CanvasDAG
//
//  Created by Greg Fajen on 12/27/19.
//

import MuzeMetal

extension RenderColor2: NodePayload { }

public class SolidColorNode: GeneratorNode<RenderColor2> {
    
    init(_ key: NodeKey = NodeKey(), graph: Graph, payload: RenderColor2? = nil) {
        super.init(key, graph: graph, payload: payload, nodeType: .solidColor)
    }
    
    //    convenience init(_ uiColor: UIColor) {
    //        self.init(.init(uiColor))
    //    }
    //
    //    override var nodeType: NodeType { return .solidColor }
    
    var color: RenderColor2 {
        get { return payload }
        set { payload = newValue }
    }
    
    var colorTexture: MetalTexture { return MetalSolidColorTexture(color).texture }
    
    override public func renderPayload(for options: RenderOptions) -> RenderPayload? {
        return .texture(colorTexture)
    }
    
    override public var calculatedRenderExtent: RenderExtent {
        return .infinite
    }
    
    override public var calculatedUserExtent: UserExtent {
        return .brush & .infinite
    }
    
}
