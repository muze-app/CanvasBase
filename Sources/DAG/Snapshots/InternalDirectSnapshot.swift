//
//  InternalDirectSnapshot.swift
//  muze
//
//  Created by Greg Fajen on 9/1/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation
import MuzePrelude

public struct NodeRevData {
    
    init() { }
    
//    var renderExtent: RenderExtent?
//    var userExtent: UserExtent?
    var hash: Int?
    
    mutating func reset() {
//        renderExtent = nil
//        userExtent = nil
        hash = nil
    }
    
}

public class InternalDirectSnapshot<Collection: NodeCollection>: DAGBase<Collection> {
    
    weak var _store: DAGStore<Collection>?
    override public var store: DAGStore<Collection> { _store! }
    let predecessor: DAGBase<Collection>?
    
    var payloadBuffers: PayloadBufferSet { store.payloadBuffers }
    
    public init(predecessor: DAGBase<Collection>? = nil, store: DAGStore<Collection>, key: CommitKey = CommitKey()) {
        self.predecessor = predecessor
        self._store = store
        
        self.pTypeMap = predecessor?.typeMap ?? [:]
            
        super.init(key)
    }
    
    public func with(key: CommitKey) -> InternalDirectSnapshot {
        let snapshot = InternalDirectSnapshot(predecessor: self, store: store, key: key)
        snapshot.becomeImmutable()
        return snapshot
    }
    
    var payloadMap: [NodeKey:PayloadBufferAllocation] = [:]
    
//    var hotSubgraphs = Set<SubgraphKey>() // 'hot' more or less means retained
    var subgraphs: [SubgraphKey:SubgraphData] = [:]
    var _typeMap: [NodeKey:Collection] = [:]
    let pTypeMap: [NodeKey:Collection] 
    var edgeMaps: [NodeKey:[Int:NodeKey]] = [:]
    var reverseEdges: [NodeKey:Bag<NodeKey>] = [:]
    var revData: [NodeKey:NodeRevData] = [:]
    
    override public var depth: Int { return (predecessor?.depth ?? -1) + 1 }
    
    private var isMutable = true
    
    func becomeImmutable() {
        isMutable = false
    }
    
    var hasChanges: Bool {
        if _typeMap.isEmpty,
           edgeMaps.isEmpty,
           payloadMap.isEmpty,
           subgraphs.isEmpty /*,
           hotSubgraphs */ {
            return false
        }
        
        return true
    }
    
    var address: UnsafeMutableRawPointer {
        return Unmanaged.passUnretained(self).toOpaque()
    }
    
    // MARK: Types
    
    override var typeMap: [NodeKey:Collection] {
        return _typeMap.merging(pTypeMap) { (_, b) in b }
    }
    
    func setType(_ type: Collection, for key: NodeKey) {
        preconditionWriting()
        assert(isMutable)
        if self.type(for: key) == type { return }
        _typeMap[key] = type
    }
    
    // MARK: Edges
    
    override public func edgeMap(for key: NodeKey) -> [Int:NodeKey]? {
        if let edgeMap = edgeMaps[key] {
            return edgeMap
        }
        
        return predecessor?.edgeMap(for: key)
    }
    
    public func setEdgeMap(_ edgeMap: [Int:NodeKey], for key: NodeKey) {
        preconditionWriting()
        precondition(isMutable)
        
        edgeMaps[key] = edgeMap
    }
    
    public func setInput(for parent: NodeKey, index: Int, to child: NodeKey?) {
        precondition(isMutable)
        precondition(child != parent)
        
        let oldChild = self.input(for: parent, index: index)
        
        if oldChild == child { return }
        
        var map = edgeMap(for: parent) ?? [:]
        map[index] = child
        edgeMaps[parent] = map
        
        if let oldChild = oldChild {
            if let reverse = reverseEdges(for: oldChild) {
                setReverseEdges(reverse - parent, for: oldChild)
            }
        }
        
        if let newChild = child {
            let reverse = reverseEdges(for: newChild) ?? .init()
            setReverseEdges(reverse + parent, for: newChild)
        }
        
        //        assert(input(for: parent, index: index) == child)
    }
    
    // MARK: - Subgraphs
    
    override public var allSubgraphKeys: Set<SubgraphKey> {
        let mine = Set(subgraphs.keys)
        guard let pred = predecessor?.allSubgraphKeys else { return mine }
//        guard let alt = alt?.allSubgraphKeys else { return pred + mine }
        return pred + mine //+ alt
    }

    override public func subgraphData(for key: SubgraphKey) -> SubgraphData? {
        subgraphs[key] ?? predecessor?.subgraphData(for: key)
    }
    
    func updateSubgraph(_ key: SubgraphKey, _ block: (inout SubgraphData)->()) {
//        die
        assert(isMutable)

        let old = subgraphData(for: key) ?? SubgraphData(key: key)
//        let alt = subgraphData(for: key) ?? SubgraphData(key: key)
        var new = old

        block(&new)

        if new != old /*|| old != alt*/ {
            subgraphs[key] = new
        }
        
//        #if DEBUG
//        
//        let subgraphCount = allSubgraphKeys.count
//        assert(subgraphCount == 1)
//    
//        #endif
    }
    
    override public func finalKey(for subgraphKey: SubgraphKey) -> NodeKey? {
        return subgraphData(for: subgraphKey)?.finalKey
    }
    
    override public func metaKey(for subgraphKey: SubgraphKey) -> NodeKey? {
        return subgraphData(for: subgraphKey)?.metaKey
    }
    
    func setFinalKey(_ key: NodeKey?, for subgraphKey: SubgraphKey) {
        updateSubgraph(subgraphKey) {
            $0.finalKey = key
        }
        
//        assert(subgraphData(for: subgraphKey, level: level+0)!.finalKey == key)
//        assert(subgraphData(for: subgraphKey, level: level+1)!.finalKey == key)
    }
    
    func setMetaKey(_ key: NodeKey?, for subgraphKey: SubgraphKey) {
        updateSubgraph(subgraphKey) {
            $0.metaKey = key
        }
    }
    
    // MARK: Payloads
    
    override public func payloadAllocation(for key: NodeKey) -> PayloadBufferAllocation? {
        return payloadMap[key] ?? predecessor?.payloadAllocation(for: key)
    }
    
    func setPayload<T: NodePayload>(_ payload: T, for key: NodeKey) {
        assert(isMutable)
//        print("\(address) setPayload \(payload) for \(key)")
        
        if self.payload(for: key, of: T.self) == payload { return }
        
        if let allocation = payloadMap[key] {
            allocation.pointer.assumingMemoryBound(to: T.self).assign(repeating: payload, count: 1)
            return
        }
        
        guard let allocation = payloadBuffers.new(payload) else {
            fatalError("out of memory")
        }
        
        payloadMap[key] = allocation
    }
    
    // MARK: Reverse Edges
    
    override public func reverseEdges(for key: NodeKey) -> Bag<NodeKey>? {
        return reverseEdges[key] ?? predecessor?.reverseEdges(for: key)
    }
    
    func setReverseEdges(_ bag: Bag<NodeKey>, for key: NodeKey) {
        assert(isMutable)
        
        if self.reverseEdges(for: key) == bag { return }
        
        reverseEdges[key] = bag
    }
    
    func receivers(of key: NodeKey) -> Set<NodeKey> {
        return reverseEdges(for: key)?.asSet ?? Set<NodeKey>()
    }
    
    func invalidateRevData(for key: NodeKey) {
        revData[key] = NodeRevData()
        
        for receiver in receivers(of: key) {
            invalidateRevData(for: receiver)
        }
    }
    
    override func revData(for key: NodeKey) -> NodeRevData? {
        return revData[key] ?? predecessor?.revData(for: key)
    }
    
    func setRevData(_ data: NodeRevData, for key: NodeKey) {
        revData[key] = data
    }
    
    // Changes
    
//    public var allNodes: Set<NodeKey> {
//        var all = Set<NodeKey>()
//
//        for subgraph in allSubgraphs {
//            if let final = subgraph.finalNode {
//                all = all.union(final.allKeys)
//            }
//        }
//
//        return all
//    }
    
    public var nodesTouchedSincePredecessor: Set<NodeKey> {
        return Set(edgeMaps.keys) + Set(payloadMap.keys)
    }
    
    func haveNodesChanged(_ nodes: Set<NodeKey>, sinceParent parent: SnapshotKey) -> Bool {
        die
//        if key == parent { return false }
//
//        let changes = nodesTouchedSincePredecessor
//        for node in nodes {
//            if changes.contains(node) {
//                return true
//            }
//        }
//
//        let pred = predecessor!.snapshotToModify as! InternalDirectSnapshot
//        return pred.haveNodesChanged(nodes, sinceParent: parent)
    }
    
    override public func contains(allocations: Set<PayloadBufferAllocation>) -> Bool {
        let mine = Set(payloadMap.values)

        let intersection = mine.intersection(allocations)

        if intersection.count > 0 {
            return true
        }

        if let predecessor = predecessor {
            return predecessor.contains(allocations: allocations)
        }

        return false
    }
    
    // todo: use rev edges
    public func replace(_ key: NodeKey, with replacement: Node) {
        replacement.add(to: self, useFreshKeys: false)
        
        for subgraph in allSubgraphs {
            subgraph.finalNode = subgraph.finalNode?.replacing(key, with: replacement)
            
//            #if DEBUG
//            if let x = subgraph.finalNode, x.contains(key) {
//                fatalError()
//            }
//            #endif
        }
        
//        guard let rev = self.reverseEdges(for: key)?.asSet else {
//            fatalError()
//        }
//
//        print("rev.count: \(rev.count)")
//        if rev.isEmpty { fatalError() }
//
//        for receiverKey in rev {
//            guard let edges = edgeMap(for: receiverKey) else {
//                fatalError()
//            }
//
//            for (i, k) in edges where k == key {
//                setInput(for: receiverKey, index: i, to: replacement.key)
//            }
//        }
    }
    
//    func contains(textures: Set<MetalTexture>) -> Bool {
//        print("checking if contains textrues. level \(level), depth \(depth)")
//        for (key, type) in typeMap {
//            guard type == .image else { continue }
//            let node = self.node(for: key) as! ImageNode
//            let tex = node.texture
//            print("    - \(tex)")
//            if textures.contains(where: { $0 == tex }) {
//                print("        WOAH")
//                return true
//            }
//        }
//        
//        if let predecessor = predecessor {
//            return predecessor.contains(textures: textures)
//        }
//        
//        return false
//    }
    
}

public extension GenericNode {
    
    var allKeys: Set<Key> {
        var all = Set(key)
        
        for input in inputs {
            all = all.union(input.allKeys)
        }
        
        return all
    }
    
    func replacing(_ old: NodeKey, with new: Node) -> Node {
        if key == old { return new }
        
        for (i, k) in edgeMap {
            self.nodeInputs[i] = graph.node(for: k).replacing(old, with: new)
        }
        
        return self
    }
    
}
