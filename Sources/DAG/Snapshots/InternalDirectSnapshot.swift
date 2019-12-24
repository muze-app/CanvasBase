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

private let tempDict = WeakThreadSafeDict<Int, InternalDirectSnapshot<MockNodeCollection>>()
private var i = 0

public class InternalDirectSnapshot<Collection: NodeCollection>: DAGBase<Collection> {
    
    weak var _store: DAGStore<Collection>?
    override public var store: DAGStore<Collection> { _store! }
    let predecessor: DAGBase<Collection>?
    let _level: Int
    override var level: Int { _level }
    
    var modLock: NSRecursiveLock? { return store.lock }
    
    init(predecessor: DAGBase<Collection>? = nil, store: DAGStore<Collection>, level: Int, key: CommitKey = CommitKey()) {
        self.predecessor = predecessor
        self._store = store
        self._level = level
        
        super.init(key)
        
        tempDict[i] = (self as! InternalDirectSnapshot<MockNodeCollection>)
        i += 1
    }
    
    func with(key: CommitKey, level: Int) -> InternalDirectSnapshot {
        let snapshot = InternalDirectSnapshot(predecessor: self, store: store, level: level, key: key)
        snapshot.becomeImmutable()
        return snapshot
    }
    
    override func parent(at level: Int) -> DAGBase<Collection>? {
        if let pred = predecessor as? InternalDirectSnapshot {
            if pred.level == level {
                return pred
            } else {
                return pred.parent(at: level)
            }
        }
        
        return nil
    }
    
    var payloadBuffers: PayloadBufferSet?
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
    
    override public var depth: Int { return (predecessor?.depth ?? 0) + 1 }
    
    override var maxLevel: Int {
        guard let p = predecessor?.maxLevel else { return level }
        return max(p, level)
    }
    
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
    
    override func type(for key: NodeKey) -> Collection? {
        return typeMap[key] ?? predecessor?.type(for: key)
    }
    
    func setType(_ type: Collection, for key: NodeKey) {
        assert(isMutable)
        if self.type(for: key) == type { return }
        typeMap[key] = type
    }
    
    // MARK: Edges
    
    override public func edgeMap(for key: NodeKey, level: Int) -> [Int:NodeKey]? {
        if level >= self.level, let edgeMap = edgeMaps[key] {
            return edgeMap
        }
        
        return predecessor?.edgeMap(for: key, level: level)
    }
    
    func setEdgeMap(_ edgeMap: [Int:NodeKey], for key: NodeKey) {
        assert(isMutable)
        edgeMaps[key] = edgeMap
    }
    
    func setInput(for parent: NodeKey, index: Int, to child: NodeKey?) {
        assert(isMutable)
        assert(child != parent)
        
        let oldChild = self.input(for: parent, index: index)
        
        if oldChild == child { return }
        
        var map = edgeMap(for: parent, level: level) ?? [:]
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

    override public func subgraphData(for key: SubgraphKey, level: Int) -> SubgraphData? {
        if level >= self.level, let subgraph = subgraphs[key] {
            return subgraph
        }

        return predecessor?.subgraphData(for: key, level: level)
    }
    
    func updateSubgraph(_ key: SubgraphKey, _ block: (inout SubgraphData)->()) {
//        die
        assert(isMutable)

        let old = subgraphData(for: key, level: level) ?? SubgraphData(key: key)
        let alt = subgraphData(for: key, level: 99999) ?? SubgraphData(key: key)
        var new = old

        block(&new)

        if new != old || old != alt {
            subgraphs[key] = new
        }
    }
    
    override public func finalKey(for subgraphKey: SubgraphKey) -> NodeKey? {
        return subgraphData(for: subgraphKey, level: level)?.finalKey
    }
    
    override public func metaKey(for subgraphKey: SubgraphKey) -> NodeKey? {
        return subgraphData(for: subgraphKey, level: level)?.metaKey
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
    
    func payloadAllocation(for key: NodeKey, level: Int) -> PayloadBufferAllocation? {
        if level >= self.level, let pointer = payloadMap[key] {
            return pointer
        }
        
        die
//        return predecessor?.payloadAllocation(for: key, level: level)
    }
    
    override public func payloadPointer(for key: NodeKey, level: Int) -> UnsafeMutableRawPointer? {
        if level >= self.level, let pointer = payloadMap[key]?.pointer {
            return pointer
        }
        
//        die
        return predecessor?.payloadPointer(for: key, level: level)
    }
    
    override public func payload<T>(for key: NodeKey, of type: T.Type) -> T? {
        guard let raw = payloadPointer(for: key, level: level) else { return nil }
        let pointer = raw.assumingMemoryBound(to: T.self)
        return pointer.pointee
    }
    
    func setPayload<T: NodePayload>(_ payload: T, for key: NodeKey) {
        
        assert(isMutable)
//        print("\(address) setPayload \(payload) for \(key)")
        
        if self.payload(for: key, of: T.self) == payload { return }
        
        if let allocation = payloadMap[key] {
            allocation.pointer.assumingMemoryBound(to: T.self).assign(repeating: payload, count: 1)
            return
        }
        
        if !payloadBuffers.exists { payloadBuffers = PayloadBufferSet() }
        
        guard let allocation = payloadBuffers!.new(payload) else {
            fatalError("out of memory")
        }
        
        payloadMap[key] = allocation
    }
    
    // MARK: Reverse Edges
    
    override func reverseEdges(for key: NodeKey) -> Bag<NodeKey>? {
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
    
    var nodesTouchedSincePredecessor: Set<NodeKey> {
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
    
    func contains(allocations: Set<PayloadBufferAllocation>) -> Bool {
        die
//        let mine = Set(payloadMap.values)
//
//        let intersection = mine.intersection(allocations)
//
//        if intersection.count > 0 {
//            return true
//        }
//
//        if let predecessor = predecessor {
//            return predecessor.contains(allocations: allocations)
//        }
//
//        return false
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
