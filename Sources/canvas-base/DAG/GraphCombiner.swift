//
//  GraphCombiner.swift
//  muze
//
//  Created by Greg Fajen on 9/3/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation

//@available(*, deprecated)
//class GraphCombiner: DAG {
//    var allSubgraphKeys: Set<SubgraphKey> { fatalError() }
//    
//    
//    var maxLevel: Int { fatalError() }
//    
//    
//    func subgraphData(for key: SubgraphKey, level: Int) -> SubgraphData? {
//        return nil
//    }
//    
//    var level: Int = 0
//    
//    func subgraph(for key: SubgraphKey) -> SubgraphData? {
//        return nil
//    }
//    
//    func finalKey(for subgraph: SubgraphKey) -> NodeKey? {
//        return nil
//    }
//    
//    func metaKey(for subgraph: SubgraphKey) -> NodeKey? {
//        return nil
//    }
//    
//    weak var store: DAGStore?
//    let graphs: [DAGSnapshot]
//    let key = CommitKey()
//    
//    var subgraph: SubgraphOld? { fatalError() }
//    var modLock: NSRecursiveLock? { return nil }
//    
//    init(store: DAGStore, graphs: [DAG]) {
//        fatalError()
////        self.store = store
////        self.graphs = graphs.map { $0.internalReference }
//    }
//    
//    init(store: DAGStore, subgraphs: [NodeKey:CommitKey]) {
//        fatalError()
////        self.store = store
////        self.graphs = subgraphs.map { store.subgraph(for: $0.key).commit(for: $0.value)!.internalReference }
//    }
//    
//    var finalKey: NodeKey? { return nil }
//    var metaKey: NodeKey? { return nil }
//    
//    var snapshotToModify: DAG { return self }
//    
//    var depth: Int {
//        return (graphs.map { $0.depth }).max
//    }
//    
//    func type(for key: NodeKey) -> DNodeType? {
//        for graph in graphs {
//            if let type = graph.type(for: key) {
//                return type
//            }
//        }
//        
//        return nil
//    }
//    
//    func payloadPointer(for key: NodeKey) -> UnsafeMutableRawPointer? {
//        for graph in graphs {
//            if let pointer = graph.payloadPointer(for: key) {
//                return pointer
//            }
//        }
//        
//        return nil
//    }
//    
//    func edgeMap(for key: NodeKey, level: Int) -> [Int:NodeKey]? {
//        for graph in graphs {
//            if let map = graph.edgeMap(for: key, level: level) {
//                return map
//            }
//        }
//        
//        return nil
//    }
//    
//    func reverseEdges(for key: NodeKey) -> Bag<NodeKey>? {
//        for graph in graphs {
//            if let rev = graph.reverseEdges(for: key) {
//                return rev
//            }
//        }
//        
//        return nil
//    }
//    
//    func revData(for key: NodeKey) -> NodeRevData? {
//        for graph in graphs {
//            if let data = graph.revData(for: key) {
//                return data
//            }
//        }
//        
//        return nil
//    }
//    
//    func setRevData(_ data: NodeRevData, for key: NodeKey) {
//        fatalError()
//    }
//    
//}

extension Array where Element == Int {
    
    var max: Int {
        return reduce(0) { Swift.max($0,$1) }
    }
    
}
