//
//  CanvasDAG.swift
//  DAG
//
//  Created by Greg Fajen on 12/23/19.
//

import Foundation
import DAG

public typealias GeneratorNode<Payload: NodePayload> = DAG.GeneratorNode<CanvasNodeCollection, Payload> & CanvasNode

public protocol CanvasNode: GenericNode<CanvasNodeCollection> {
    
    typealias Graph = DAGBase<CanvasNodeCollection>
    typealias Node = GenericNode<CanvasNodeCollection>
    
}

public enum CanvasNodeCollection: NodeCollection, Hashable {
    
    public typealias Graph = DAGBase<CanvasNodeCollection>
    public typealias Node = GenericNode<CanvasNodeCollection>
    
    case canvasMeta
    case layerMeta
    
    case image
    //    case video
    
    case solidColor
    case maskedColor
    case blend
    case comp
    case mask
    case maskSeries
    //    case mix
    case alpha
    case colorMatrix
    case brush
    
    case checkerboard
    
    //    case caption
    case cache
    case effect
    //    case crop
    case canvasOverlay
    case rects
    
    case transform
    
    case blurPreview
    
    case color, string
    
    public func node(for key: NodeKey, graph: Graph) -> Node {
        switch self {
            default: fatalError()
            //                    case .color: return CNode(key, graph: self)
            //                    case .string: return SNode(key, graph: self)
            //                    case .canvasOverlay: return CanvasOverlayNode(key, graph: self)
            //                    case .image: return ImageNode(key, graph: self)
            //                    case .blend: return BlendNode(key, graph: self)
            //                    case .rects: return RectsNode(key, graph: self)
            //                    case .blurPreview: return BlurPreviewNode(key, graph: self)
            //                    case .solidColor: return SolidColorNode(key, graph: self)
            //                    case .transform: return TransformNode(key, graph: self)
            //                    case .canvasMeta: return CanvasMetaNode(key, graph: self)
            //                    case .layerMeta: return LayerMetaNode(key, graph: self)
            //                    case .brush: return BrushNode(key, graph: self)
            //                    case .maskedColor: return MaskedColorNode(key, graph: self)
            //                    case .effect: return EffectNode(key, graph: self)
            //                    case .mask: return MaskNode(key, graph: self)
            //                    case .comp: return CompositeNode(key, graph: self)
            //                    case .alpha: return AlphaNode(key, graph: self)
            //                    case .colorMatrix: return ColorMatrixNode(key, graph: self)
            //                    case .maskSeries: return MaskSeriesNode(key, graph: self)
            //                    case .cache: return CacheNode(key, graph: self)
            //                    case .checkerboard: return CheckerboardNode(key, graph: self)
        }
    }
    
}
