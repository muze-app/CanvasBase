//
//  DAG+Opt.swift
//  CanvasBase
//
//  Created by Greg Fajen on 12/26/19.
//

import Foundation
import DAG

public extension DAGBase {
    
    func optimizing(subgraph: SubgraphKey,
                    throughCacheNodes: Bool = false) -> Snapshot {
        var map = [NodeKey:NodeKey]()
        
        return optimizing(subgraph: subgraph,
                          throughCacheNodes: throughCacheNodes,
                          map: &map)
    }
    
    func optimizing(subgraph: SubgraphKey,
                    throughCacheNodes: Bool = false,
                    map: inout [NodeKey:NodeKey]) -> Snapshot {
        return modify { graph in
                        let subgraph = graph.subgraph(for: subgraph)
            subgraph.finalNode = subgraph.finalNode?.optimize(throughCacheNodes: throughCacheNodes,
                                                              map: &map)
        }
        
        //        return self as! InternalDirectSnapshot
        
        //        let optimized = modify { (graph) in
        //            graph.finalNode = graph.finalNode?.optimize(throughCacheNodes: throughCacheNodes)
        //        }
        
        //        for (parent, edgeMap) in optimized.edgeMaps {
        //            print("PARENT: \(parent)")
        //            for (i, child) in edgeMap {
        //                print("    \(i) = \(child)")
        //            }
        //        }
        
        //        print("ORIGINAL")
        //        finalNode?.log()
        //        print("OPTIMIZED")
        //        optimized.finalNode?.log()
        
        //        return optimized.flattened
    }
    
}
