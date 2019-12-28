//
//  CanvasDAG.swift
//  DAG
//
//  Created by Greg Fajen on 12/23/19.
//

@_exported import MuzePrelude
@_exported import DAG
import MuzeMetal

public typealias GeneratorNode<Payload: NodePayload> = DAG.GeneratorNode<CanvasNodeCollection, Payload>

public typealias PayloadNode<Payload: NodePayload> = DAG.PayloadNode<CanvasNodeCollection, Payload>

public typealias ListNode<Payload: NodePayload> = DAG.ListNode<CanvasNodeCollection, Payload>

public typealias InputNode<Payload: NodePayload> = DAG.INode<CanvasNodeCollection, Payload>

public typealias CanvasGraph = DAGBase<CanvasNodeCollection>
public typealias CanvasNode = GenericNode<CanvasNodeCollection>
public typealias MutableCanvasGraph = MutableDAG<CanvasNodeCollection>

public typealias RenderPayload = MuzeMetal.RenderPayload
public typealias RenderOptions = MuzeMetal.RenderOptions
public typealias RenderExtent  = MuzeMetal.RenderExtent
public typealias UserExtent    = MuzeMetal.UserExtent
public typealias RenderPassDescriptor = MuzeMetal.RenderPassDescriptor
public typealias RenderIntermediate = MuzeMetal.RenderIntermediate

//public protocol CanvasNode: GenericNode<CanvasNodeCollection> {
//
//    typealias Graph = DAGBase<CanvasNodeCollection>
//    typealias Node = GenericNode<CanvasNodeCollection>
//
//}

public enum CanvasNodeCollection: NodeCollection, Hashable {
    
    public typealias Graph = DAGBase<CanvasNodeCollection>
    public typealias Node = GenericNode<CanvasNodeCollection>
    
    public typealias RenderPayloadType = RenderPayload
    public typealias RenderOptionsType = RenderOptions
    public typealias RenderExtentType = RenderExtent
    public typealias UserExtentType = UserExtent
    
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
//            case .color: return CNode(key, graph: graph)
//            case .string: return SNode(key, graph: graph)
//            case .canvasOverlay: return CanvasOverlayNode(key, graph: graph)
            case .image: return ImageNode(key, graph: graph)
            case .blend: return BlendNode(key, graph: graph)
            case .comp:  return CompositeNode(key, graph: graph)
            case .alpha: return AlphaNode(key, graph: graph)
            case .cache: return CacheNode(key, graph: graph)
//            case .rects: return RectsNode(key, graph: graph)
//            case .blurPreview: return BlurPreviewNode(key, graph: graph)
            case .solidColor: return SolidColorNode(key, graph: graph)
            case .transform: return TransformNode(key, graph: graph)
            case .canvasMeta: return CanvasMetaNode(key, graph: graph)
            case .layerMeta: return LayerMetaNode(key, graph: graph)
            case .brush: return BrushNode(key, graph: graph)
            case .maskedColor: return MaskedColorNode(key, graph: graph)
//            case .effect: return EffectNode(key, graph: graph)
            case .mask: return MaskNode(key, graph: graph)
            
            case .colorMatrix: return ColorMatrixNode(key, graph: graph)
            case .maskSeries: return MaskSeriesNode(key, graph: graph)
            
            case .checkerboard: return CheckerboardNode(key, graph: graph)
            
            default:
                print("type: \(self)")
                fatalError()
        }
    }
    
}
