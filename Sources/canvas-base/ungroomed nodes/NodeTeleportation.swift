//
//  NodeTeleportation.swift
//  muze
//
//  Created by Greg Fajen on 5/17/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation


// moving nodes between universes!
extension ComplicatedNode {
    
    // does not update children. use update for that
//    static func create(from source: Node, graph: NodeGraph) -> Node {
//        if source is DNode {
//            return source
//        }
//        
//        switch source.nodeType {
//            
//        case .video:
//            let source = source as! VideoNode
//            return VideoNode(source.payload, source.key, graph)
//     
//        case .crop:
//            let source = source as! CropNode
//            return CropNode(source.payload, source.key, graph)
//                        
//        case .caption:
//            let source = source as! CaptionNode
//            return CaptionNode(source.payload, source.key, graph)
//        
//        case .mix:
//            let source = source as! MixNode
//            return MixNode(source.payload, source.key, graph)
//            
//        }
//    }
    
}

enum NodeType: Hashable {
//    case image
    case video
    
//    case solidColor
//    case maskedColor
//    case blend
//    case comp
//    case mask
//    case maskSeries
    case mix
//    case alpha
//    case colorMatrix
//    case brush
    
    case caption
//    case cache
//    case effect
    case crop
//    case canvasOverlay
//    case rects
    
//    case transform
    
//    case blurPreview
}
