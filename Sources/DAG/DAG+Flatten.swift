//
//  DAG+Flatten.swift
//  muze
//
//  Created by Greg Fajen on 9/4/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation

public extension DAGBase {
    
    func copy(usingFreshKeys: Bool = false, hotlist: Set<SubgraphKey>? = nil) -> InternalDirectSnapshot<Collection> {
        let newKey = usingFreshKeys ? CommitKey() : key
        let source = self
        let target = InternalDirectSnapshot<Collection>(predecessor: nil,
                                                          store: store,
                                                          key: newKey)
        
        for subgraphKey in hotlist ?? source.allSubgraphKeys {
            let sourceSubgraph = source.subgraph(for: subgraphKey)
            let targetSubgraph = target.subgraph(for: subgraphKey)
            
            if let finalNode = sourceSubgraph.finalNode {
                let key = finalNode.add(to: target, useFreshKeys: usingFreshKeys)
                targetSubgraph.finalKey = key
            }
            
            if let metaNode = sourceSubgraph.metaNode {
                let key = metaNode.add(to: target, useFreshKeys: usingFreshKeys)
                targetSubgraph.metaKey = key
            }
        }
        
        target.becomeImmutable()
        
        return target
    }
    
    var duplicated: InternalDirectSnapshot<Collection> {
        return copy(usingFreshKeys: true)
    }
    
    var flattened: InternalDirectSnapshot<Collection> {
       return copy(usingFreshKeys: false)
    }
    
    func flattened(with hotlist: Set<SubgraphKey>?) -> InternalDirectSnapshot<Collection> {
       return copy(usingFreshKeys: false, hotlist: hotlist)
    }
    
    func diff(from parent: DAGBase<Collection>, hotlist: Set<SubgraphKey>? = nil) -> InternalDirectSnapshot<Collection> {
        let source = self
        let target = InternalDirectSnapshot<Collection>(predecessor: parent,
                                                        store: store,
                                                        key: key)
        
        for subgraphKey in hotlist ?? allSubgraphKeys {
            let sourceSubgraph = source.subgraph(for: subgraphKey)
            let targetSubgraph = target.subgraph(for: subgraphKey)
            
            if let finalNode = sourceSubgraph.finalNode {
                finalNode.add(diffTo: target, parent: parent)
                targetSubgraph.finalNode = finalNode
                
                targetSubgraph.finalNode?.log()
            }
            
            if let metaNode = sourceSubgraph.metaNode {
                metaNode.add(diffTo: target, parent: parent)
                targetSubgraph.metaNode = metaNode
            }
        }
        
        target.becomeImmutable()
        
        return target
    }
    
}

extension PayloadBufferAllocation: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        fatalError()
//        hasher.combine("\(debugDescription)")
    }
    
    public static func == (l: PayloadBufferAllocation, r: PayloadBufferAllocation) -> Bool {
        return l === r
    }
    
}
