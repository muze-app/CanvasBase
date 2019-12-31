//
//  CanvasManager+Merging.swift
//  muze
//
//  Created by Greg Fajen on 2/18/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

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
    
    var shouldReduceMemory: Bool {
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
        }
        
        removeUndoStates()
        
        print("simplifying tail")
        store.simplifyTail()
        let sortedCommits = store.sortedCommits
        
        print("UNDOS/REDOS: \(undoManager.undoCount) / \(undoManager.redoCount)")
        
        print("COMMITS: \(sortedCommits.count)")
        for commit in sortedCommits {
            print(" - \(commit.key) \(commit.pointerString)")
        }
        
        let oldNodes = determineNodesToRemove(sortedCommits)
        
        var replacements: [NodeKey:Node] = [:]
        
        let newHead = sortedCommits.head.modify(as: sortedCommits.head.key) { graph in
            replacements = renderReplacements(sortedCommits.head, oldNodes).mapValues {
                guard let (texture, transform) = $0 else { fatalError() }
                return ImageNode(graph: graph, payload: .init(texture, transform, .identity))
            }
        }
        
        store.commit(newHead, setLatest: true)
        
        for commit in store.sortedCommits {
            let commit = commit.modify(as: commit.key) { graph in
                for (old, new) in replacements {
                    graph.replace(old, with: new)
                }
            }
            
            store.commit(commit, setLatest: true)
        }
        
        
        
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
        
        store.simplifyHead()
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
        
        print("CHANGED NODES")
        for node in changedNodes {
            print("- \(node)")
        }
        
        print("UNCHANGED NODES:")
        
        let r = sortedCommits.head.allSubgraphs.flatMap { $0.finalNode?.nodes(thatDoNotContain: changedNodes) ?? [] }
        for node in r {
            print("- \(node)")
        }
        
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
    
    private func renderReplacements(_ graph: Graph, _ keys: [NodeKey]) -> [NodeKey:TextureAndTransform?] {
//        print("RENDERING REPLACEMENTS")
//        for key in keys {
//            let node = graph.node(for: key)
//            node.log()
//        }
        
//        print("")
        
//        for key in keys {
//            renderReplacement(graph, key)
//        }
        
        return .init(keys) { renderReplacement(graph, $0) }
        
//        context.render(graph: <#T##Graph#>, subgraph: <#T##SubgraphKey#>, canvasSize: <#T##CGSize#>, time: <#T##TimeInterval#>, format: <#T##RenderOptions.PixelFormat#>, colorSpace: <#T##RenderOptions.ColorSpace#>, completion: <#T##RenderContext.CompletionType##RenderContext.CompletionType##(RenderManager.ResultType) -> ()#>)
    }
    
    private func renderReplacement(_ graph: Graph, _ key: NodeKey) -> TextureAndTransform? {
//        let graph = graph.optim
        
        #if targetEnvironment(simulator)
        return (.mock, .identity)
        #else
        let node = graph.node(for: key)
        let options = RenderOptions("purge", mode: .usingExtent, format: .float16, time: 0)
        if let payload = node.renderPayload(for: options) {
            let result = RenderManager.shared.renderSync(payload, options)
            
            print("rendered: \(result)")
            print(" ")
            
            return result
        } else {
            print(" ")
            return nil
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
    
    func tempReportHolder(_ holder: DAGSnapshot) {
        let unsafe = Unmanaged.passUnretained(holder).toOpaque()
        print("  - \(holder.key) \(unsafe)")
    }

//    #warning("fix me")
    func reduceMemory(force: Bool = false, _ callback: @escaping (Bool)->() = { _ in }) {
        if !force, memoryReductionDisabled || reducingMemory || !shouldReduceMemory {
            callback(false)
            return
        }
        
        print("reducing!")
        reducingMemory = true
        
        CanvasManager.mergeQueue.async { [weak self] in
            guard let self = self else { return }
            self.store.sync { self._purge() }
        }
        
        return
        
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
    
//    if let payload = node.renderPayload(for: options) {
//        RenderManager.shared.render(payload, options) { result in
//            print("rendered: \(result)")
//            print(" ")
//        }
//    } else {
//    print(" ")
//    }
    
}


