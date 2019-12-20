//
//  DAG+Flatten.swift
//  muze
//
//  Created by Greg Fajen on 9/4/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation

extension DAG {
    
    func copy(usingFreshKeys: Bool = false, hotlist: Set<SubgraphKey>? = nil) -> InternalDirectSnapshot {
        var pred: InternalDirectSnapshot?
        
        for level in 0...maxLevel {
            let newKey = usingFreshKeys ? CommitKey() : key
            let snapshot = InternalDirectSnapshot(predecessor: pred, store: store, level: level, key: newKey)
            
            let this = self.modify(level: level) { _ in }
            
//            print("LEVEL \(level)")
//            print("   subgraphs: \(this.allSubgraphKeys)")
            
            for subgraphKey in hotlist ?? this.allSubgraphKeys {
                let sourceSubgraph = this.subgraph(for: subgraphKey)
                let targetSubgraph = snapshot.subgraph(for: subgraphKey)
                
                if let finalNode = sourceSubgraph.finalNode {
                    let key = finalNode.add(to: snapshot, useFreshKeys: usingFreshKeys)
                    targetSubgraph.finalKey = key
                }
                
                if let metaNode = sourceSubgraph.metaNode {
                    let key = metaNode.add(to: snapshot, useFreshKeys: usingFreshKeys)
                    targetSubgraph.metaKey = key
                }
            }
            
//            print("PAYLOAD MAP: \(snapshot.payloadMap.keys)")
            
            snapshot.becomeImmutable()
            pred = snapshot
        }
        
        return pred!
    }
    
    var duplicated: InternalDirectSnapshot {
        return copy(usingFreshKeys: true)
    }
    
    var flattened: InternalDirectSnapshot {
       return copy(usingFreshKeys: false)
    }
    
    func flattened(with hotlist: Set<SubgraphKey>?) -> InternalDirectSnapshot {
       return copy(usingFreshKeys: false, hotlist: hotlist)
    }
    
    func diff(from parent: InternalDirectSnapshot, hotlist: Set<SubgraphKey>? = nil) -> InternalDirectSnapshot {
        var pred = parent
        
        for level in 0...max(maxLevel, parent.maxLevel) {
            let snapshot = InternalDirectSnapshot(predecessor: pred, store: store, level: level, key: key)
            
            let this = self.modify(level: level) { _ in }
            let parent = parent.modify(level: level) { _ in }
            
//            print("LEVEL \(level)")
//            print("   subgraphs: \(this.allSubgraphKeys)")
            
            for subgraphKey in hotlist ?? this.allSubgraphKeys {
                let sourceSubgraph = this.subgraph(for: subgraphKey)
                let targetSubgraph = snapshot.subgraph(for: subgraphKey)
                
                if let finalNode = sourceSubgraph.finalNode {
                    finalNode.add(diffTo: snapshot, parent: parent)
                    targetSubgraph.finalNode = finalNode
                    
                    targetSubgraph.finalNode?.log()
                }
                
                if let metaNode = sourceSubgraph.metaNode {
                    metaNode.add(diffTo: snapshot, parent: parent)
                    targetSubgraph.metaNode = metaNode
                }
            }
            
//            print("PAYLOAD MAP: \(snapshot.payloadMap.keys)")
            
            snapshot.becomeImmutable()
            pred = snapshot
        }
        
        return pred
    }
    
}

extension PayloadBufferAllocation: Hashable {
    
    func hash(into hasher: inout Hasher) {
        fatalError()
//        hasher.combine("\(debugDescription)")
    }
    
    static func == (l: PayloadBufferAllocation, r: PayloadBufferAllocation) -> Bool {
        return l === r
    }
    
}
