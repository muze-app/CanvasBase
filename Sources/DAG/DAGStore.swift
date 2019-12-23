//
//  DAGStore.swift
//  muze
//
//  Created by Greg Fajen on 9/3/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import UIKit
import muze_prelude

public class DAGStore<Collection: NodeCollection> {
    
    let lock = NSRecursiveLock()
    var modLock: NSRecursiveLock { return lock }
    
    var tempSubgraphKey: SubgraphKey?
    
    typealias Snapshot = InternalDirectSnapshot<Collection>
    
    var latest: DAGSnapshot<Collection>!
    var commits = WeakDict<CommitKey, Snapshot>()
    
    private var internalRetainedCommitsBag = Bag<CommitKey>()
    private var externalRetainedCommitsBag = Bag<CommitKey>()
    var retainedCommitsSet: Set<CommitKey> {
        return internalRetainedCommitsBag.asSet + externalRetainedCommitsBag.asSet
    }
    var retainedCommits = ThreadSafeDict<CommitKey, Snapshot>()
    private var commitTimes = [CommitKey: Date]()
    
    var externalCommits: [Snapshot] {
        return externalRetainedCommitsBag.asSet.map {
            let key = $0
            let commit = commits[key]!
            
            if commit.key != key {
                // shouldn't happen but we'll just let it slide for now.
                // pretty sure keys are going to get removed from the commits themselves
                return commit.modify(as: key, level: commit.level) { _ in }
            }
            
            assert(commit.key == key)
//            commits[$0]!
            return commit
        }
    }
    
    var sortedExternalCommits: [Snapshot] {
        var pairs = externalCommits.map { ($0, commitTimes[$0.key]!) }
        pairs.sort { $0.1 < $1.1 }
        return pairs.map { $0.0 }
    }
    
    weak var delegate: AnyObject?
    
    init(delegate: AnyObject? = nil) {
        self.delegate = delegate
        
        let graph = Snapshot(store: self, level: 0)
        commit(graph)
    }
    
    func doNothing() {
        // just to keep in memory
    }
    
    // MARK: - Threading
    
    func sync(_ block: ()->()) {
        lock.lock()
        block()
        lock.unlock()
    }
    
    func async(_ block: @escaping ()->()) {
        DispatchQueue.global().async { self.sync(block) }
    }
    
    // MARK: - Commits
    
    func commit(for key: CommitKey) -> Snapshot? {
        var commit: Snapshot?
        sync { commit = commits[key] }
        return commit
    }
    
    @discardableResult
    func commit(_ snapshot: Snapshot, process: Bool = true) -> CommitKey {
        return commit(snapshot, setLatest: true, process: process)
    }
    
    @discardableResult
    private func commit(_ snapshot: Snapshot, setLatest: Bool, process: Bool = true) -> CommitKey {
        let key: CommitKey = snapshot.key
        
//        if isLayer {
//            print("commit \(snapshot.key) (processed: \(!process))")
//        }
        
        sync {
            let snapshotToCommit = snapshot
//            if process, let processed = self.process(commit: snapshot) {
//                snapshotToCommit = processed
//            }
            
            assert(snapshotToCommit.key == key)
//            let key = snapshotToCommit.key
            
//            let snapshot = (snapshot.metaNode is CanvasMetaNode) ? snapshot.flattened : snapshot
            
            self.commits[key] = snapshotToCommit
            self.commitTimes[key] ?= Date()
            self.latest = DAGSnapshot(store: self, key: key, .externalReference)
            
            if self.retainedCommitsSet.contains(key) {
                self.retainedCommits[key] = snapshotToCommit
            }
            
//            if process, let processed = self.process(commit: snapshot) {
//                self.commit(processed, setLatest: false, process: false)
//            }
        }
        
        //        if snapshot.depth > 100 {
        //        if snapshot.depth > 12 {
        //            vacuum()
        //        }
        
        return key
    }
    
    func retain(commitFor key: CommitKey, mode: DAGSnapshot<Collection>.Mode) {
        sync {
            guard let commit = commits[key] else { fatalError() }
            guard commitTimes[key].exists else { fatalError() }
            
            switch mode {
                case .externalReference: externalRetainedCommitsBag.insert(key)
                case .internalReference: internalRetainedCommitsBag.insert(key)
            }
            
            retainedCommits[key] = commit
        }
    }
    
    func release(commitFor key: CommitKey, mode: DAGSnapshot<Collection>.Mode) {
        sync {
            switch mode {
            case .externalReference: externalRetainedCommitsBag.remove(key)
            case .internalReference: internalRetainedCommitsBag.remove(key)
            }
            
            if !retainedCommitsSet.contains(key) {
//                print("removing commit \(key)")
                
                autoreleasepool {
//                    if let oldSnapshot = self.retainedCommits[key] {
//                        let c = CFGetRetainCount(oldSnapshot)
                        
//                        let unsafe = Unmanaged.passUnretained(oldSnapshot).toOpaque()
//                        print("    pointer: \(unsafe)")
//                        print("    retain count: \(c)")
//                    }
                    
                    self.removeRetainedCommit(key)
                }
            }
        }
    }
    
    private func removeRetainedCommit(_ key: CommitKey) {
        retainedCommits.remove(key)
    }
  
    func process(commit: DAGBase<Collection>) -> Snapshot? {
//        let commit = commit.modify(as: commit.key, level: 0) { _ in }
        
//        assert(commit.level == 0)
        fatalError()
//        guard let processed = delegate?.processCommit(commit: commit) else { return nil }
//        let key = commit.key.with("processed")
        
//        assert(processed.level == 1)
        
//        let after = processed.modify(level: 0) { _ in }
        
//        if let subgraphKey = self.tempSubgraphKey {
//            let f: (String, DAG)->() = { (message, graph) in
//                print("\(message):  (lv\(graph.level)")
//                graph.subgraph(for: subgraphKey).finalNode!.log()
//            }
            
//            f("BEFORE", commit)
//            f("PROCESSED", processed)
//            f("AFTER", after)
//        }
        
//        print("    processed \(commit.key)")
//        return processed.with(key: commit.key, level: 1)
    }
    
    // MARK: - Misc
    
//    let cacheStore = CacheStore()
    
}

//extension DAGStore {
//
//    static func tempTexture(_ color: RenderColor2 = .red) -> MetalTexture {
//        let texture = MetalSolidColorTexture(color).texture
//        return texture.resized(to: CGSize(16))
//    }
//
////    static func iterate(_ graph: MutableDAG, _ subgraphKey: SubgraphKey) -> InternalDirectSnapshot {
////        var graph = graph.modify(level: 0) { graph in
////
////        }
////
////        graph = graph.modify(level: 1) { graph in
//////            let subgraph = graph.key
////        }
////    }
//
//    static func test6() {
//
//        let canvas = CanvasManager()
//        let layer = canvas.manager(for: LayerKey())
//        let store = canvas.store
//
//        autoreleasepool {
//            let graph = store.latest.modify(level: 0) { graph in
//                let layerSubgraph = graph.subgraph(for: layer.subgraphKey)
//                let layerMetadata = LayerMetadata()
//                layerSubgraph.metaNode = LayerMetaNode(graph: graph, payload: layerMetadata)
//
//                let canvasSubgraph = graph.subgraph(for: canvas.subgraphKey)
//                let canvasMetaNode = canvasSubgraph.metaNode as! CanvasMetaNode
//                canvasMetaNode.payload.layers = [layer.key]
//                canvasMetaNode.payload.layerSubgraphs[layer.key] = layer.subgraphKey
//            }
//
//            canvas.current = graph.externalReference
//            canvas.display = graph.externalReference
//
//            store.commit(graph)
//        }
//
//        weak var originalImage: Image?
//        let transformKey = NodeKey()
//
//        autoreleasepool {
//            canvas.newTransaction(identifier: "a") { transaction in
//                transaction.modify(description: "a") { graph in
//                    let subgraph = graph.subgraph(for: layer.subgraphKey)
//                    let transformNode = TransformNode(transformKey, graph: graph, payload: .scaling(2))
//
//                    let tex = tempTexture(.red)
//                    let node = ImageNode(texture: tex, graph: graph)
//
//                    transformNode.input = node
//
//                    subgraph.finalNode = transformNode
//                    originalImage = node.image
//                }
//            }
//
//            canvas.newTransaction(identifier: "b") { transaction in
//                transaction.modify(description: "b") { graph in
//                    let transformNode = TransformNode(transformKey, graph: graph, payload: .scaling(2))
//                    transformNode.input = SolidColorNode(graph: graph, payload: .blue)
//                }
//            }
//
//            canvas.newTransaction(identifier: "c") { transaction in
//                transaction.modify(description: "c") { graph in
//                    let transformNode = TransformNode(transformKey, graph: graph, payload: .scaling(2))
//                    transformNode.input = SolidColorNode(graph: graph, payload: .green)
//                }
//            }
//
//            massert(originalImage.exists)
//        }
//
//        autoreleasepool {
//            canvas.undoManager.pop(keeping: 1)
//
//            print("undo count: \(canvas.undoManager.undoCount)")
//            print("image count: \(InternalImage.instances.values.count)")
//            store.vacuumSync()
//            print("undo count: \(canvas.undoManager.undoCount)")
//            print("image count: \(InternalImage.instances.values.count)")
//        }
//
//        print("undo count: \(canvas.undoManager.undoCount)")
//        print("image count: \(InternalImage.instances.values.count)")
//        massert(!originalImage.exists)
//
//        massert(store.latest.allSubgraphKeys.count == 2)
//
//        store.latest.subgraph(for: layer.subgraphKey).finalNode!.log()
//
//        print("ok")
//    }
//
//    static func test5() {
//        let store = DAGStore()
//        let subgraphKey = SubgraphKey()
//
//        let a0 = store.latest.modify(level: 0) { (graph) in
//            let subgraph = graph.subgraph(for: subgraphKey)
//
//            subgraph.finalNode = SolidColorNode(graph: graph, payload: .red)
//        }
//
//        let a1 = a0.modify(level: 1) { (graph) in
//            let subgraph = graph.subgraph(for: subgraphKey)
//            subgraph.finalNode = SolidColorNode(graph: graph, payload: .green)
//        }
//
//        let b0 = a1.modify(level: 0) { (graph) in
//            let subgraph = graph.subgraph(for: subgraphKey)
//
//            let transform = TransformNode(graph: graph, payload: .identity)
//
//            transform.input = subgraph.finalNode
//            subgraph.finalNode = transform
//        }
//
//        let b1 = b0.modify(level: 1) { (graph) in
//            let subgraph = graph.subgraph(for: subgraphKey)
//
//            let final = subgraph.finalNode as! TransformNode
//            let color = final.input as! SolidColorNode
//            massert(color.color == .red)
//        }
//
//        print("a0:")
//        a0.subgraph(for: subgraphKey).finalNode!.log()
//        print("a1:")
//        a1.subgraph(for: subgraphKey).finalNode!.log()
//        print("b0:")
//        b0.subgraph(for: subgraphKey).finalNode!.log()
//        print("b1:")
//        b1.subgraph(for: subgraphKey).finalNode!.log()
//
//        print(" ")
//    }
//
//
//    static func test4() {
//        let store = DAGStore()
//
//        let subgraphKey = SubgraphKey()
//        var subgraphZero: Subgraph!
//        var subgraphOne: Subgraph!
//
//        let blendKey = NodeKey()
//
//        print("ZERO")
//        let zero = InternalDirectSnapshot(store: store, level: 0).modify { graph in
//            let color = SolidColorNode(graph: graph, payload: .red)
//            let blend = BlendNode(blendKey, graph: graph, payload: .init(.normal, 1))
//
//            blend.source = color
//
//            subgraphZero = Subgraph(key: subgraphKey, graph: graph)
//            subgraphZero.finalNode = blend
//            subgraphZero.finalNode!.log()
//        }
//
//        print("ONE")
//        let one = zero.modify(level: 1) { graph in
//            let color = SolidColorNode(graph: graph, payload: .green)
//            let blend = BlendNode(blendKey, graph: graph)
//            let transform = TransformNode(graph: graph, payload: .identity)
//
//            blend.destination = color
//            transform.input = blend
//
//            massert(blend.inputs.count == 2)
//
//            subgraphOne = Subgraph(key: subgraphKey, graph: graph)
//            subgraphOne.finalNode = transform
//            subgraphOne.finalNode!.log()
//        }
//
//        let mod = one.modify(level: 0) { graph in
//            let subgraph = Subgraph(key: subgraphKey, graph: graph)
//            let transform = TransformNode(graph: graph, payload: .scaling(2))
//
//            transform.input = subgraph.finalNode
//            subgraph.finalNode = transform
//        }
//
//        let diff = mod.diff(from: one)
//        let dZero = diff.modify(level: 0) { _ in }
//
//        let m0 = mod.modify(level: 0) { _ in }
//        let m1 = mod.modify(level: 1) { _ in }
//
//        print("ZERO")
//        Subgraph(key: subgraphKey, graph: m0).finalNode?.log()
//
//        print("ONE")
//        Subgraph(key: subgraphKey, graph: m1).finalNode?.log()
//
//        print("ZERO DIFF")
//        Subgraph(key: subgraphKey, graph: dZero).finalNode?.log()
//
//        print("ONE DIFF")
//        Subgraph(key: subgraphKey, graph: diff).finalNode?.log()
//
//        print(" ")
//    }
//
//    static func test3() {
//        let store = DAGStore()
//
//        let subgraphKey = SubgraphKey()
//        var subgraphZero: Subgraph!
//        var subgraphOne: Subgraph!
//
//        let blendKey = NodeKey()
//
//        print("ZERO")
//        let zero = InternalDirectSnapshot(store: store, level: 0).modify { graph in
//            let color = SolidColorNode(graph: graph, payload: .red)
//            let blend = BlendNode(blendKey, graph: graph, payload: .init(.normal, 1))
//
//            blend.source = color
//
//            subgraphZero = Subgraph(key: subgraphKey, graph: graph)
//            subgraphZero.finalNode = blend
//            subgraphZero.finalNode!.log()
//        }
//
//        print("ONE")
//        let one = zero.modify(level: 1) { graph in
//            let color = SolidColorNode(graph: graph, payload: .green)
//            let blend = BlendNode(blendKey, graph: graph)
//            let transform = TransformNode(graph: graph, payload: .identity)
//
//            blend.destination = color
//            transform.input = blend
//
//            massert(blend.inputs.count == 2)
//
//            subgraphOne = Subgraph(key: subgraphKey, graph: graph)
//            subgraphOne.finalNode = transform
//            subgraphOne.finalNode!.log()
//        }
//
//        let oneFlat = one.flattened
//        let zeroFlat = oneFlat.modify(level: 0) { _ in }
//
//        let zeroFlatSub = zeroFlat.subgraph(for: subgraphKey)
//        let oneFlatSub = oneFlat.subgraph(for: subgraphKey)
//
//        print("ZERO")
//        subgraphZero.finalNode?.log()
//
//        print("ONE")
//        subgraphOne.finalNode?.log()
//
//        print("ZERO FLAT")
//        zeroFlatSub.finalNode?.log()
//
//        print("ONE FLAT")
//        oneFlatSub.finalNode?.log()
//
//        print("ONE FLAT PS")
//        print("\(oneFlat.payloadMap.keys)")
//
//        print("ONE FLAT PRED PS")
//        print("\((oneFlat.predecessor! as! InternalDirectSnapshot).payloadMap.keys)")
//
//
//        print(" ")
//    }
//
//    static func test2() {
//        let store = DAGStore()
//
//        let subgraphKey = SubgraphKey()
//        var subgraphZero: Subgraph!
//        var subgraphOne: Subgraph!
//        var subgraphBack: Subgraph!
//
//        let blendKey = NodeKey()
//
//        print("ZERO")
//        let zero = InternalDirectSnapshot(store: store, level: 0).modify { graph in
//            let color = SolidColorNode(graph: graph, payload: .red)
//            let blend = BlendNode(blendKey, graph: graph, payload: .init(.normal, 1))
//
//            blend.source = color
//
//            subgraphZero = Subgraph(key: subgraphKey, graph: graph)
//            subgraphZero.finalNode = blend
//            subgraphZero.finalNode!.log()
//        }
//
//        print("ONE")
//        let one = zero.modify(level: 1) { graph in
//            subgraphOne = Subgraph(key: subgraphKey, graph: graph)
//            subgraphOne.finalNode = subgraphOne.finalNode?.optimize(throughCacheNodes: true)
//            subgraphOne.finalNode!.log()
//        }
//
//        print("BACK")
//        let back = one.modify(level: 0) { graph in
//            subgraphBack = Subgraph(key: subgraphKey, graph: graph)
//            subgraphBack.finalNode!.log()
//        }
//
//        print("ZERO")
//        print("level: \(zero.level)")
//        print("edgeMaps: \(zero.edgeMaps)")
//
//        print("ONE")
//        print("level: \(one.level)")
//        print("edgeMaps: \(one.edgeMaps)")
//
//        print("BACK")
//        print("level: \(back.level)")
//        print("edgeMaps: \(back.edgeMaps)")
//
//        print("ZERO")
//        subgraphZero.finalNode!.log()
//
//        print("ONE")
//        subgraphOne.finalNode!.log()
//
//        print("BACK")
//        subgraphBack.finalNode!.log()
//
//        print(" ")
//    }
//
//    static func test() {
//        let store = DAGStore()
//
//        let subgraphKey = SubgraphKey()
//        var subgraphZero: Subgraph!
//        var subgraphOne: Subgraph!
//        var subgraphBack: Subgraph!
//
//        let blendKey = NodeKey()
//
//        print("ZERO")
//        let zero = InternalDirectSnapshot(store: store, level: 0).modify { graph in
//            let color = SolidColorNode(graph: graph, payload: .red)
//            let blend = BlendNode(blendKey, graph: graph, payload: .init(.normal, 1))
//
//            blend.source = color
//
//            subgraphZero = Subgraph(key: subgraphKey, graph: graph)
//            subgraphZero.finalNode = blend
//            subgraphZero.finalNode!.log()
//        }
//
//        print("ONE")
//        let one = zero.modify(level: 1) { graph in
//            let color = SolidColorNode(graph: graph, payload: .green)
//            let blend = BlendNode(blendKey, graph: graph)
//            let transform = TransformNode(graph: graph, payload: .identity)
//
//            blend.destination = color
//            transform.input = blend
//
//            massert(blend.inputs.count == 2)
//
//            subgraphOne = Subgraph(key: subgraphKey, graph: graph)
//            subgraphOne.finalNode = transform
//            subgraphOne.finalNode!.log()
//        }
//
//        print("BACK")
//        let back = one.modify(level: 0) { graph in
//            subgraphBack = Subgraph(key: subgraphKey, graph: graph)
//            subgraphBack.finalNode!.log()
//        }
//
//        print("ZERO")
//        print("level: \(zero.level)")
//        print("edgeMaps: \(zero.edgeMaps)")
//
//        print("ONE")
//        print("level: \(one.level)")
//        print("edgeMaps: \(one.edgeMaps)")
//
//        print("BACK")
//        print("level: \(back.level)")
//        print("edgeMaps: \(back.edgeMaps)")
//
//        print("ZERO")
//        subgraphZero.finalNode!.log()
//
//        print("ONE")
//        subgraphOne.finalNode!.log()
//
//        print("BACK")
//        subgraphBack.finalNode!.log()
//
//        print(" ")
//    }
//
//    static func obnoxiousTest() {
//        var canvas: CanvasManager!
//        var layer: LayerManager!
//
//        #warning("fix me")
////        autoreleasepool {
////            canvas = CanvasManager()
////            layer = canvas.manager(for: LayerKey())
////
////            let layerCommit = layer.subgraph.latest.modify { (graph) in
////                graph.metaNode = LayerMetaNode(graph: graph, payload: LayerMetadata(), nodeType: .layerMeta)
////                graph.finalNode = SolidColorNode(graph: graph, payload: RenderColor2.red)
////            }
////
////            layer.subgraph.commit(layerCommit)
////
////            let canvasCommit = canvas.current.modify { (graph) in
////                let metaNode = CanvasMetaNode(graph: graph, payload: CanvasMetadata(width: 8, height: 8), nodeType: .canvasMeta)
////                metaNode.payload.layers = [layer.key]
////                metaNode.payload.rawSnapshots[layer.key] = layerCommit.externalReference
////                graph.metaNode = metaNode
////            }
////
////            canvas.subgraph.commit(canvasCommit)
////            canvas.current = canvasCommit.externalReference
////            canvas.display = canvas.current
////
////            print("current: \(canvas.currentMetadata)")
////
////        }
//        fatalError()
//
//        while true {
//            autoreleasepool {
//                let trans = canvas.newTransaction(identifier: "test")
//                trans.modify(description: "test", layer: layer, with: { (subgraph) in
//                    let color = subgraph.finalNode as! SolidColorNode
//                    color.payload = RenderColor2(.random)
//                })
//                trans.commit()
//            }
//
//            autoreleasepool {
//                canvas.reduceMemory()
//            }
//        }
//
//    }
//
//}

protocol DAGStoreDelegate: class {
    
    associatedtype Collection: NodeCollection
    
    func hotlist(for graphs: [DAGBase<Collection>]) -> Set<SubgraphKey>?
    func processCommit(commit: DAGBase<Collection>) -> InternalDirectSnapshot<Collection>?
    func considerPurging(_ nodes: [(GenericNode<Collection>, Subgraph<Collection>)])
    
}

/*
extension DAGStore {
    
    func vacuum(handler: @escaping (NodeKey, DAG)->() = {(_,_) in}) {
        async { self.vacuumSync(handler: handler) }
    }
    
    func vacuumSync(allocations: Set<PayloadBufferAllocation> = [], texturesToPurge: Set<MetalTexture> = [], flattenAll: Bool = false, handler: (NodeKey,DAG)->() = {(_,_) in}) {
//        fatalError()
//        if latest.metaNode( is CanvasMetaNode { return }
        
        sync {
            let retainedCommitsSet = self.retainedCommitsSet
            commitTimes = commitTimes.filter { retainedCommitsSet.contains($0.key) }
            
            // to do: use diff against oldest commit
            // will require us to save dates to efficiently find the oldest
            
            let sorted = self.sortedExternalCommits
            
            let hotlist = self.delegate?.hotlist(for: sorted)
            
            let head = sorted.first!.flattened(with: hotlist)
            let tail = sorted.dropFirst()
            
            for graph in [head] {
                print("graph \(graph) \(graph.key)")
                
                if graph.contains(allocations: Set(allocations)) {
                    print("wtf")
                }
                
                if graph.contains(textures: Set(texturesToPurge)) {
                    print("wtf")
                }
            }
//            print("HEAD OLD:")
//            sorted.first!.finalNode?.log()
//            print("HEAD NEW:")
//            head.finalNode?.log()
//
//            if let node = sorted.first!.metaNode {
//                print("META: \(node)")
//            }
            
            print("current commits: \(1+tail.count)")
            
            var nodesChanged = Set<NodeKey>()
            
            autoreleasepool {
                self.commit(head, setLatest: false, process: false)
                print(" ")
                
                for commit in tail {
                    autoreleasepool {
                        let diff = commit.flattened(with: hotlist)
                        
                        for graph in [diff] {
                            print("graph \(graph) \(graph.key)")
                            
                            if graph.contains(allocations: Set(allocations)) {
                                print("wtf")
                            }
                            
                            if graph.contains(textures: Set(texturesToPurge)) {
                                print("wtf")
                            }
                        }
                        
                        self.commit(diff, setLatest: false, process: false)
                        
                        let touched = diff.nodesTouchedSincePredecessor
                        print("commit \(diff.key))")
                        
                        //                print("OLD")
                        //                commit.finalNode?.log()
                        //                print("NEW")
                        //                diff.finalNode?.log()
                        
                        print("   payload keys: \(diff.payloadMap.keys)")
                        print("   edgemap keys: \(diff.edgeMaps.keys)")
                        print("   touched: \(touched)")
                        
                        nodesChanged += touched
                    }
                }
            }
            
            var pairsToConsider = [(DNode,Subgraph)]()
            
            for subgraphKey in hotlist ?? head.allSubgraphKeys {
                let subgraph = head.subgraph(for: subgraphKey)
                guard let final = subgraph.finalNode else { continue }
                let unchanged = final.nodes(thatDoNotContain: nodesChanged)
                
                for key in unchanged {
                    let node = head.node(for: key)
                    pairsToConsider.append((node, subgraph))
                }
            }
            
            delegate?.considerPurging(pairsToConsider)
            
            print(" ")
            
            
//            let unchanged = Set(head.finalNode!.nodes(thatDoNotContain: nodesChanged))
            
//            print("  changed: \(nodesChanged)")
//            print("unchanged: \(unchanged)")
//            
//            for key in unchanged {
//                let node = head.node(for: key)
//                
//                
//                //                if node.inputCount == 0 {
//                //                    continue
//                //                }
//                
//                print("SHOULD FLATTEN:")
//                node.log(with: "\t")
//                
//                handler(key, head)
//            }
            
        }
    }
    
}*/

infix operator ?= : AssignmentPrecedence
func ?= <T>(l: inout T?, r: T) { l = l ?? r }
