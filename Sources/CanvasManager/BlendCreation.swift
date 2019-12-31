//
//  BlendCreation.swift
//  muze
//
//  Created by Greg Fajen on 5/27/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import MuzePrelude

public class BlendCreation: SingleLayerCreation {
    
    public func transform(for texture: MetalTexture) -> AffineTransform {
        let canvasBounds = .zero & canvasManager.currentMetadata.size
        let aspect = texture.size.aspectRatio
        let frame = canvasBounds.rectThatFills(aspect)
        let textureBounds = .zero & texture.size
        return AffineTransform(from: textureBounds, to: frame)
    }
    
    public func colorMatrix(for texture: MetalTexture) -> DMatrix3x3 {
        let colorSpace = texture.colorSpace ?? .srgb
        return colorSpace.matrix(to: .working)
    }
    
    public func push(_ texture: MetalTexture, _ mode: BlendMode) {
        canvasManager.store.modLock.lock()
        modify { subgraph in
            let graph = subgraph.mutableGraph
            
            let imageNode = ImageNode(texture: texture,
                                      transform: transform(for: texture),
                                      colorMatrix: colorMatrix(for: texture),
                                      graph: graph)
            
            let blend = BlendNode(graph: graph, payload: .init(mode, 1))
            
            blend.destination = subgraph.finalNode
            blend.source = imageNode
            
            subgraph.finalNode = blend
        }
        canvasManager.store.modLock.unlock()
    }
    
}

public extension CGRect {
    
    // not necessarily (maxX,maxY); always opposite origin
    var diagonalCorner: CGPoint {
        return CGPoint(x: origin.x + size.width, y: origin.y + size.height)
    }
    
    init(points a: CGPoint, _ b: CGPoint) {
        self = CGRect(left: min(a.x, b.x), top: min(a.y, b.y), right: max(a.x, b.x), bottom: max(a.y, b.y))
    }
    
}
