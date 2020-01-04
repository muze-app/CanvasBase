//
//  CanvasManager+Merging.swift
//  muze
//
//  Created by Greg Fajen on 2/18/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

// swiftlint:disable shorthand_operator
import MuzePrelude
import MuzeMetal
import CanvasDAG

extension CanvasManager {
    
    public typealias Node = GenericNode<CanvasNodeCollection>
    
    func didEnterBackground() {
        
    }
    
    func checkMemory() {
        reduceMemory()
    }
    
//    var memoryHash: MemoryHash {
////        return undoManager.memoryHash + canvas.memoryHash + RenderManager.shared.memoryHash
//    }
    
    var memorySize: MemorySize {
        return MetalHeapManager.shared.allocatedSize
    }
    
    func didReceiveMemoryWarning() {
        print("Canvas received memory warning!")
        
        maxMemorySize = maxMemorySize * 0.9
        if memorySize < maxMemorySize {
            maxMemorySize = memorySize * 0.9
        }
        
        reduceMemory()
    }
    
    public var shouldReduceMemory: Bool {
//        return false
        return (undoManager.undoCount + undoManager.redoCount) > 5
//        return (undoManager.undoCount > 60) || (memorySize > maxMemorySize)
    }
    
    // MARK: - THE PURGE ITSELF
    
    private func _purge() {
        print("PURGE!!!")

        print("UNDOS/REDOS: \(undoManager.undoCount) / \(undoManager.redoCount)")
        print("COMMITS: \(store.sortedCommits.count)")
        for commit in store.sortedCommits {
            print(" - \(commit.key)")
//            commit.verify()
        }
        
        removeUndoStates()
        
//        store.sortedCommits.head.verify()
        
//        print("simplifying tail")
        store.simplifyTail()
        let sortedCommits = store.sortedCommits
//        print("head: \(sortedCommits.head.pointerString)")
        
//        let snapshots = DAGSnapshot<CanvasNodeCollection>.all()
        
        let validCommits = Set(undoManager.undoList.flatMap {
            [$0.before.key, $0.after.key]
        })
        
        for commit in sortedCommits {
            let time = store.commitTimes[commit.key]!
            print("\(commit.key) - \(-time.timeIntervalSinceNow)")
            if !validCommits.contains(commit.key) {
                print("    INVALID!")
            }
//            for snapshot in snapshots where snapshot.key == commit.key {
//                print("   - \(snapshot.pointerString)")
//            }
        }
        
        print("UNDOS/REDOS: \(undoManager.undoCount) / \(undoManager.redoCount)")

//        print("COMMITS: \(sortedCommits.count)")
//        for commit in sortedCommits {
//            print(" - \(commit.key) \(commit.pointerString)")
////            commit.verify()
//        }
        
        let oldNodes = determineNodesToRemove(sortedCommits)
        
        var replacements: [NodeKey] = []
        
        let newHead = autoreleasepool {
            sortedCommits.head.alias { graph in
                for (key, node) in renderReplacements(graph, oldNodes) {
                    //                guard let (texture, transform) = value else { fatalError() }
                    
                    replacements.append(node.key)
                    graph.replace(key, with: node)
                }
            } .flattened
        }
        
//        newHead.verify()
        
        store.commit(newHead)
        
        for commit in sortedCommits.tail {
            for k in replacements {
                commit.setReplacementType(.replacement, for: k)
//                commit.verify()
            }
        }
        
        print("NODES TOUCHED")
        for commit in store.sortedCommits {
            print("commit \(commit.key)")
            for node in commit.nodesTouchedSincePredecessor {
                print(" - \(node)")
            }
        }
        
//        for commit in store.sortedCommits {
//            
//            for (k, _) in replacements {
//                if let type = commit.type(for: k, expectingReplacement: true) {
//                    if type != .replacement {
//                        fatalError()
//                    }
//                }
//            }
//            
////            let patched = commit.modify(as: commit.key) { graph in
////                for (k, _) in replacements {
////                graph.setType(.replacement, for: k)
////                }
////            }
//            
////            store.commit(patched)
////            patched.verify()
//            
////            commit.verify()
//        }
        
//        for commit in store.sortedCommits.reversed() {
//            commit.verify()
//
//            let commit = commit.modify(as: commit.key) { graph in
//                for (old, new) in replacements {
//                    graph.replace(old, with: new)
//                }
//                updateCanvasSubgraph(in: graph)
//            }
//
//            commit.verify()
//
//            store.commit(commit, setLatest: false)
//        }
        
//        let newHead = sortedCommits.head.modify(as: sortedCommits.head.key) { graph in
////            print("BEFORE:")
////            for subgraph in graph.allSubgraphs {
////                subgraph.finalNode?.log()
////            }
////            print(" ")
//
//            for (oldKey, newStuff) in replacements {
//
//                guard let (texture, transform) = newStuff else { continue } // for now, rare case but should remove old stuff
//                let imagePayload = ImagePayload.init(texture, transform)
//                let imageNode = ImageNode.init(graph: graph, payload: imagePayload)
//
//                graph.replace(oldKey, with: imageNode)
//
////                print("REPLACING \(oldKey) with \(imageNode)")
//            }
//
////            print("AFTER:")
////            for subgraph in graph.allSubgraphs {
////                subgraph.finalNode?.log()
////            }
////
////            print(" ")
//        } .flattened
//
//        store.commit(newHead)
        
//        store.simplifyHead()
//        store.simplifyTail()
//        store.simplifyTail() // to do: we can replace this by making the preds of the tail into snapshots
        
        reducingMemory = false
    }
    
    private func removeUndoStates() {
        autoreleasepool {
            undoManager.pop(keeping: 3)
        }
    }
    
    typealias InternalSnapshot = InternalDirectSnapshot<CanvasNodeCollection>
    
    private func determineNodesToRemove(_ sortedCommits: HeadAndTail<InternalSnapshot>) -> [NodeKey] {
        let changedNodes = Set( sortedCommits.tail.flatMap { $0.nodesTouchedSincePredecessor } )
        
//        for subgraph in sortedCommits.head.importantSubgraphs {
//            print("SUBGRAPH: \(subgraph.key)")
//            subgraph.finalNode?.log()
//        }
        
//        print("CHANGED NODES")
//        for node in changedNodes {
//            print("- \(node)")
//        }
//
//        print("UNCHANGED NODES:")
        
        let r = sortedCommits.head.importantSubgraphs.flatMap { $0.finalNode?.nodes(thatDoNotContain: changedNodes) ?? [] }
//        for node in r {
//            print("- \(node)")
//        }
        
//        #if DEBUG
//
//        let nodes = r.map { sortedCommits.head.node(for: $0) }
//
//        let intersection = changedNodes.intersection(r)
//        if !intersection.isEmpty {
//            print("uh oh")
//        }
//
//        for a in nodes {
//            for b in nodes where b !== a {
//                if a.contains(b.key) {
//                    print("uh oh")
//                }
//
//                if b.contains(a.key) {
//                    print("uh oh")
//                }
//            }
//        }
//
//        #endif
        
//        if let first = r.last { return [first] } else { return [] }
        
        return r
//
//        for subgraph in sortedCommits.head.allSubgraphs {
//            guard let x = subgraph.finalNode?.nodes(thatDoNotContain: changedNodes) else { continue }
//
//            for node in x {
//                print("- \(x)")
//            }
//
//            print("")
//        }
//
//
//        let allNodes = sortedCommits.head.allNodes
//
////        for subgraph in so
//
//        let oldNodes = allNodes - changedNodes
//        print("OLD NODES")
//        for node in oldNodes {
//            print("- \(node)")
//        }
//
//
//        return .init(oldNodes)
    }
    
    private func renderReplacements(_ graph: MutableGraph, _ keys: [NodeKey]) -> [NodeKey:ReplacementNode] {
        return .init(keys) { key in
            let (hash, pair) = renderReplacement(graph, key)
            guard let (texture, transform) = pair else {
                fatalError()
            }
            
            return .init(key, hash, graph, texture, transform)
        }
    }
    
    private func renderReplacement(_ graph: Graph, _ key: NodeKey) -> (Int, TextureAndTransform?) {
//        let graph = graph.optim
        
        #if targetEnvironment(simulator)
        
            let result = RenderManager.shared.mockRenderSync()
            
            print("rendered: \(result)")
            print(" ")
            
            return result
       
        #elseif os(macOS)
        return (0, (.mock, .identity))
        #else
        let node = graph.node(for: key)
        let hash = node.contentHash
        let options = RenderOptions("purge", mode: .usingExtent, format: .float16, time: 0)
        if let payload = node.renderPayload(for: options) {
            let result = RenderManager.shared.renderSync(payload, options)
            
            print("rendered: \(result)")
            print(" ")
            
            return (hash, result)
        } else {
            print(" ")
            return (hash, nil)
        }
        #endif
    }
    
    private func cleanupDataStore() {
        autoreleasepool {
            
        }
    }
    
    // MARK: - MESSY FLATTEN
    
//    func flatten(at nodeKey: NodeKey, then completion: @escaping (Bool)->()) {
//
//
//        fatalError()
//
//        guard let node = canvasManager?.canvas[key][nodeKey] else {
//            print("unable to find node!!!")
//            completion(false)
//            return
//        }
//
//        print("REPLACING NODE")
//        node.log(with: "\t")
//
//        if let node = node as? BlendNode {
//            if let image = node.source as? ImageNode {
//                let number = NSNumber(value: image.key.hashValue)
//                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//                    NotificationCenter.default.post(name: NSNotification.Name("VagrantCheck"),
//                                                    object: number)
//                }
//
//                //                print("   getting rid of texture \(image.texture) \(image.texture.pointerString)")
//            }
//        }
//
//
//        renderReplacement(for: node) { (textureAndTransform) in
//            assert(textureAndTransform!.0.colorSpace.exists)
//            self.received(textureAndTransform, for: node)
//            completion(true)
//        }
//    }
//    //
//    func received(_ textureAndTransform: TextureAndTransform?, for node: Node) {
//        guard let (texture, transform) = textureAndTransform else {
//            fatalError()
//        }
//
//        guard let canvasManager = canvasManager else {
//            fatalError()
//        }
//
//        fatalError()
//        //
//        var canvas = canvasManager.canvas
//        let layer = currentLayer.copy()
//
//        //        print("received replacement for \(node)")
//        //
//        //        print("REPLACING:")
//        //        layer.node!.log(with: "\t")
//
//        //        drawable.texture.uiImage.save(to: "~/Documents/replacement \(node.key).png")
//
////        assert(texture.colorSpace! == .cam16)
//        let newNode = ImageNode(texture, transform, .identity)
//        layer.node?.replace(node.key, with: newNode)
//        //layer.node = AnyNode(forcing: layer.node?.replacing(node.key, with: newNode) )
//
//        canvas[layer.key] = layer
//
//        //        print("WITH:")
//        //        layer.node!.log(with: "\t")
//
//        if canvas[layer.key] != layer {
//            print("WTF")
//            print(" ")
//        }
//
//        let undoManager = canvasManager.undoManager
//        //        let oldCount = undoManager.undoCount
//
//        canvasManager.invalidatedNodes.insert(node.key)
//        canvasManager.updateCanvasForMemory(canvas)
//
//        canvasManager.undoManager.pop {
//            //            print("is \(node.key) in \($0)?")
//            //            for key in $0.associatedNodeKeys {
//            //                print("    \(key)")
//            //            }
//            if $0.associatedNodeKeys.contains(node.key) {
//                //                print("YES!")
//                return true
//            } else {
//                //                print("NO!")
//                return false
//            }
//        }
//
//        for action in Array(undoManager.undoList) + Array(undoManager.redoList) {
//            //            print("ACTION \(action)")
//            action.replace(node.key, with: newNode.copy())
//        }
//
//        //        let newCount = undoManager.undoCount
//        //        print("UNDO COUNT: \(newCount) (was: \(oldCount))")
//    }
//
//    func renderReplacement(for node: Node, completion: @escaping (TextureAndTransform?)->()) {
//        //        fatalError()
////        mergeContext!.render(intermediateNode: node, format: .float16,
////                             colorSpace: .cam16) { result in
////                                completion(result)
////        }
//    }
    
    // MARK: - OLD AND UNSORTED
    
    @available(*, deprecated)
    func layerKey(for node: NodeKey) -> LayerKey? {
        fatalError()
//        for layer in canvas.layers {
//            if layer.contains(node) {
//                return layer.key
//            }
//        }
//
//        return nil
    }
    
    @available(*, deprecated)
    func layerManager(for node: NodeKey) -> LayerManager? {
        guard let key = layerKey(for: node) else { return nil }
//        return layerManagers[key]!
        return manager(for: key)
    }
    
    func tempReportHolder(_ holder: Snapshot) {
        let unsafe = Unmanaged.passUnretained(holder).toOpaque()
        print("  - \(holder.key) \(unsafe)")
    }

//    #warning("fix me")
    public func reduceMemory(force: Bool = false, _ callback: @escaping (Bool)->() = { _ in }) {
        if !force, memoryReductionDisabled || reducingMemory || !shouldReduceMemory {
            callback(false)
            return
        }
        
        print("reducing!")
        reducingMemory = true
        
        store.write { self._purge() }
        
//        CanvasManager.mergeQueue.async { [weak self] in
//            guard let self = self else { return }
//            self.store.sync {
//                self._purge()
//            }
//        }
//
//        return
        
//        fatalError()
        
//        CanvasManager.mergeQueue.async { [weak self] in
//            guard let self = self else { return }
//
////            let manager = self.allLayerManagers[0]
////            let layerSubgraph = manager.subgraph
////            let oldest = autoreleasepool {
////                return layerSubgraph.sortedExternalCommits.first!.key
////            }
//
//            autoreleasepool {
////                print("sorted commits before: \(self.store.sortedExternalCommits.map { $0.key })")
//            }
//
//            autoreleasepool {
//                self.undoManager.pop(keeping: force ? 1 : 1)
//            }
//
//            print("huh?")
//            print("about to vacuum canvas subgraph")
//            print("hmmm")
//
//            autoreleasepool {
////                self.store.modLock.lock()
////                self.store.vacuumSync(flattenAll: true)
////                self.store.modLock.unlock()
//            }
//
//            autoreleasepool {
////                print("sorted commits after: \(self.store.sortedExternalCommits.map { $0.key })")
//            }
//
////            autoreleasepool {
////            print("EXPECTED CANVAS COMMITS")
////            for commit in self.subgraph.retainedCommitsSet {
////                print("    - \(commit)")
////            }
////            }
//
////            autoreleasepool {
////            print("ALL RETAINED CANVAS COMMITS")
////            for commit in self.subgraph.retainedCommits.values {
////                let pointer = Unmanaged.passUnretained(commit).toOpaque()
////                print("   - \(commit.key) \(pointer)")
////            }
////            }
//
////            print("ALL EXISTING CANVAS COMMITS")
////            for commit in self.subgraph.commits.values {
////                let pointer = Unmanaged.passUnretained(commit).toOpaque()
////                print("   - \(commit.key) \(pointer)")
////            }
//
////            DAGSnapshot.tempQueue.sync {
////                autoreleasepool {
////                    let holders = DAGSnapshot.tempDict.values //.filter { $0.key == oldest }
////
////                    print("EXTERNAL SNAPSHOT REFS")
////                    for holder in holders {
////                        if holder.store !== self.store { continue }
////                        switch holder.mode {
////                        case .externalReference: self.tempReportHolder(holder)
////                        default: continue
////                        }
////                    }
////
////                    print("INTERNAL SNAPSHOT REFS")
////                    for holder in holders {
////                        if holder.store !== self.store { continue }
////                        switch holder.mode {
////                        case .internalReference: self.tempReportHolder(holder)
////                        default: continue
////                        }
////                    }
////                }
////            }
//
//            print("about to vacuum layer subgraphs")
//
////            for subgraph in self.store.subgraphs.values {
////                if subgraph === self.subgraph { continue }
////
////                subgraph.modLock.lock()
////
////                subgraph.vacuumSync { (key, graph) in
////                    print("should merge \(key)")
////                    let node = graph.node(for: key)
////                    node.log()
////                    print(" ")
////                }
////
////                subgraph.modLock.unlock()
////            }
//
//            print("done!")
//        }
    }
    
    // this callback may be called multiple times
    @available(*, deprecated)
    func flatten(_ node: NodeKey, _ manager: LayerManager, _ callback: @escaping (Bool)->()) {
        fatalError()
//        if invalidatedNodes.contains(node) {
//            print("purging already purged node!?!?")
//        }
//
//        reducingMemory = true
//
//        newTransaction(identifier: "merge", commit: false) { (transaction) in
//            manager.flatten(at: node) { [weak self] (success) -> () in
//                if success, let self = self {
//                    self.didFlatten(transaction, callback)
//                } else {
//                    transaction.cancel()
//                }
//            }
//        }
    }
    
    func didFlatten(_ transaction: CanvasTransaction, _ callback: @escaping (Bool)->()) {
        print("did flatten, releasing transaction")
        dispatchPrecondition(condition: .notOnQueue(.main))
        
        reducingMemory = false
        
        MetalHeapManager.shared.collectGarbage(.aggressive, after: 0)
        
        transaction.cancel()
        
        callback(true)
        
        if shouldReduceMemory {
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
                self.reduceMemory(callback)
            }
        }
    }
    
    var nextNodeToMerge: Node? {
        return nil
//        guard let associatedNodes = oldestAssociatedNodes else { return nil }
//
//        let next = canvas.layers.compactMap { return $0.node?.first { associatedNodes.contains( $0.key ) } }
//        return next.first
    }
    
    var oldestAssociatedNodes: Set<NodeKey>? {
        return nil
//        let allAssociatedNodes = undoManager.undoList.lazyReversed.map { $0.associatedNodes }
//        guard let first = (allAssociatedNodes.filter { !$0.isEmpty }).first else { return nil }
//        return Set(first.map { $0.key })
    }
    
}

extension RenderManager {
    
    static let tempLock = NSLock()
    
    func renderSync(_ payload: RenderPayload, _ options: RenderOptions) -> TextureAndTransform {
        let lock = RenderManager.tempLock
        var result: TextureAndTransform?
        
        lock.lock()
        self.render(payload, options) { r in
            result = r
            lock.unlock()
        }
        
        lock.lock()
        lock.unlock()
        
        return result!
    }
    
    func mockRenderSync() -> TextureAndTransform {
        let lock = RenderManager.tempLock
        var result: TextureAndTransform?
        
        lock.lock()
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            result = (.mock, .identity)
            lock.unlock()
        }
        
        lock.lock()
        lock.unlock()
        
        return result!
    }
    
//    if let payload = node.renderPayload(for: options) {
//        RenderManager.shared.render(payload, options) { result in
//            print("rendered: \(result)")
//            print(" ")
//        }
//    } else {
//    print(" ")
//    }
    
}
