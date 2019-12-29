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

//private let tempDict = WeakThreadSafeDict<Int, InternalDirectSnapshot<MockNodeCollection>>()
//private var i = 0

public class InternalDirectSnapshot<Collection: NodeCollection>: DAGBase<Collection> {
    
//    class var tempDict
    
    weak var _store: DAGStore<Collection>?
    override public var store: DAGStore<Collection> { _store! }
    let predecessor: DAGBase<Collection>?
    
    var modLock: NSRecursiveLock? { return store.lock }
    
    deinit {
        print("InternalDirectSnapshot go byebye")
    }
    
    public init(predecessor: DAGBase<Collection>? = nil, store: DAGStore<Collection>, key: CommitKey = CommitKey()) {
        self.predecessor = predecessor
        self._store = store
        
        super.init(key)
        
//        tempDict[i] = (self as! InternalDirectSnapshot<Collection>)
//        i += 1
    }
    
    public func with(key: CommitKey) -> InternalDirectSnapshot {
        let snapshot = InternalDirectSnapshot(predecessor: self, store: store, key: key)
        snapshot.becomeImmutable()
        return snapshot
    }
    
//    @available(*, deprecated)
//    override public func parent(at level: Int = 0) -> DAGBase<Collection>? {
//        return predecessor
//        if let pred = predecessor as? InternalDirectSnapshot {
//            if pred.level == level {
//                return pred
//            } else {
//                return pred.parent(at: level)
//            }
//        }
//
//        return nil
//    }
    
    var _payloadBuffers: PayloadBufferSet?
    override var payloadBuffers: PayloadBufferSet? { _payloadBuffers }
    var payloadMap: [NodeKey:PayloadBufferAllocation] = [:]
    
//    deinit {
//        let unsafe = Unmanaged.passUnretained(self).toOpaque()
//        print("InternalSnapshot \(key) \(unsafe) deinit")
//    }
    
    var hotSubgraphs = Set<SubgraphKey>() // 'hot' more or less means retained
    var subgraphs: [SubgraphKey:SubgraphData] = [:]
    var typeMap: [NodeKey:Collection] = [:]
    var edgeMaps: [NodeKey:[Int:NodeKey]] = [:]
    var reverseEdges: [NodeKey:Bag<NodeKey>] = [:]
    var revData: [NodeKey:NodeRevData] = [:]
    
    override public var depth: Int { return (predecessor?.depth ?? -1) + 1 }
    
    private var isMutable = true
    
    func becomeImmutable() {
        isMutable = false
    }
    
    var hasChanges: Bool {
        if typeMap.isEmpty,
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
    
    override public func type(for key: NodeKey) -> Collection? {
        return typeMap[key] ?? predecessor?.type(for: key)
    }
    
    func setType(_ type: Collection, for key: NodeKey) {
        assert(isMutable)
        if self.type(for: key) == type { return }
        typeMap[key] = type
    }
    
    // MARK: Edges
    
    override public func edgeMap(for key: NodeKey) -> [Int:NodeKey]? {
        if let edgeMap = edgeMaps[key] {
            return edgeMap
        }
        
        return predecessor?.edgeMap(for: key)
    }
    
    public func setEdgeMap(_ edgeMap: [Int:NodeKey], for key: NodeKey) {
        assert(isMutable)
        edgeMaps[key] = edgeMap
    }
    
    public func setInput(for parent: NodeKey, index: Int, to child: NodeKey?) {
        assert(isMutable)
        assert(child != parent)
        
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
        payloadMap[key] ?? predecessor?.payloadAllocation(for: key)
    }
    
    func setPayload<T: NodePayload>(_ payload: T, for key: NodeKey) {
        assert(isMutable)
//        print("\(address) setPayload \(payload) for \(key)")
        
        if self.payload(for: key, of: T.self) == payload { return }
        
        if let allocation = payloadMap[key] {
            allocation.pointer.assumingMemoryBound(to: T.self).assign(repeating: payload, count: 1)
            return
        }
        
        if !payloadBuffers.exists {
            _payloadBuffers = predecessor?.payloadBuffers ?? PayloadBufferSet()
        }
        
        guard let allocation = payloadBuffers!.new(payload) else {
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
