//
//  Node+Opt.swift
//  CanvasBase
//
//  Created by Greg Fajen on 12/26/19.
//

import Foundation
import DAG
 
extension NodeCollection {
    
    var removeIdentity: OptFunc { { RemoveIdentityOptimization($0) } }
    var removeInvisibles: OptFunc { { RemoveInvisibleOptimization($0) } }
    
    var alphaCoalesce: OptFunc { { AlphaCoalesce($0) } }
    
    var blendCleanUp: OptFunc { { BlendCleanUpOpt($0) } }
    var blendToComp: OptFunc { { BlendToCompOpt($0) } }
    
    var compCombine: OptFunc { { CombineCompositesOpt($0) } }
    var compInvisibles: OptFunc { { RemoveInvisiblesFromCompositeOpt($0) } }
    var justOneComp: OptFunc { { SimplifyUnaryCompositeOpt($0) } }
    
    var maskToSeries: OptFunc { { MaskToSeriesOpt($0) } }
    
    var transformPushThrough: OptFunc { { PushTransformThroughCompOpt($0) } }
    var transformCoalesce: OptFunc { { TransformCoalesce($0) } }
    
    var possibleOptimizations: [OptFunc] {
        guard let self = self as? CanvasNodeCollection else { return [] }
        switch self {
            case .image: return []
            case .blend:
//                let blendToComp: OptFunc = {_ in { BlendToCompOpt($0) }}
                return [removeInvisibles, blendCleanUp, blendToComp]
            case .comp: return [compCombine, compInvisibles, justOneComp]
            case .alpha: return [removeIdentity, removeInvisibles, alphaCoalesce]
            case .cache: return []
            case .maskedColor: return [removeInvisibles]
            case .mask: return [removeIdentity, removeInvisibles, maskToSeries]
//            case .canvasMeta:
//
//            case .layerMeta:
//
//            case .solidColor:
//
//            case .maskSeries:
//
//            case .colorMatrix:
//
//            case .brush:
//
//            case .checkerboard:
//
//            case .effect:
//
//            case .canvasOverlay:
//
//            case .rects:
//
            case .transform:  return [removeIdentity, removeInvisibles, transformPushThrough, transformCoalesce]
//
//            case .blurPreview:
//            
            
            default: return [removeIdentity, removeInvisibles]
        }
    }
    
}

public extension GenericNode {
    
    var possibleOptimizations: [OptFunc] {
        type.possibleOptimizations
    }
    
    final func optimizeOnce() -> Optimization? {
//        guard let self = self as? Node else { return nil }

//        print("Optimizing \(self)")
//        print("   as canvas: \(self as! CanvasNode)")
        //        asNodeOrOpt.log()
        for optimize in possibleOptimizations {
            if let optimization = optimize(self as! CanvasNode) {
//                print("    optimized via \(optimization)")
//                print("    returning \(String(describing: optimization.right))")
                return optimization
            }
        }

        return nil
    }
    
    final func optimizeInputs(throughCacheNodes: Bool,
                              map: inout [NodeKey:NodeKey]) {
        let graph = self.graph as! MutableGraph
        for (i, inputKey) in edgeMap {
            let input = graph.node(for: inputKey).optimize(throughCacheNodes: throughCacheNodes,
                                                           map: &map)
            graph.setInput(for: key, index: i, to: input?.key)
//            self[i] = input.optimize() as! Node
        }
    }
    
    final func optimize(throughCacheNodes: Bool,
                        map: inout [NodeKey:NodeKey]) -> Node? {
        if !throughCacheNodes, self is CacheNode { return self }
        optimizeInputs(throughCacheNodes: throughCacheNodes, map: &map)

        guard var opt = self.optimizeOnce() else { return self }

        while let right = opt.right, let next = right.optimizeOnce() {
            opt = next
        }

            //            print("   done optimizing \(trimmedName)(\(key))")
            //            opt.logOpt(with: "\t")
        
        if let result = opt.right as? GenericNode<Collection> {
            map[result.key] = key
            return result
        } else {
            return nil
        }
    }
    
}
