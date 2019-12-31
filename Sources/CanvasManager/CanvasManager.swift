//
//  CanvasManager.swift
//  muze
//
//  Created by Greg on 2/2/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

@_exported import MuzePrelude
@_exported import MuzeMetal
@_exported import CanvasDAG

public typealias Graph = DAG.DAGBase<CanvasNodeCollection>
public typealias MutableGraph = DAG.MutableDAG<CanvasNodeCollection>
public typealias DAGStore = DAG.DAGStore<CanvasNodeCollection>

public protocol TempCanvasVC: class {
    func updateUndoButtons()
}

public class CanvasManager {
    
//    weak var canvasView: CanvasMetalView?
    public weak var delegate: CanvasManagerDelegate?
    
    public weak var tempAltStore: DAGStore?
    
    public let store: DAGStore
    public let subgraphKey: SubgraphKey
    
    public let context = RenderContext()
    
    public weak var canvasVC: TempCanvasVC?
    
//    @available(*, deprecated)
//    lazy var tempLayerManager = LayerManager(canvasManager: self)
    
    public var selectedLayerManager: LayerManager {
        return manager(for: displayMetadata.selectedLayer)
    }
    
    let queue = DispatchQueue(label: "CanvasManager", qos: .userInteractive)
    static let mergeQueue = DispatchQueue(label: "CanvasManagerMerge", qos: .default)
    
    public init(_ metadata: CanvasMetadata) {
        let store = DAGStore()
        let subgraphKey = SubgraphKey()
        
        let graph = store.latest.modify { (graph) in
            let metaNode = CanvasMetaNode(graph: graph, payload: metadata)
            graph.setMetaNode(metaNode, for: subgraphKey)
        }
        
        store.commit(graph)
        
        self.store = store
        self.subgraphKey = subgraphKey
        store.excludedSubgraphKeys = Set(subgraphKey)
        
        let ref = graph.externalReference
        self.current = ref
        self.display = ref
        
//        store.delegate = self
    }
    
    // Snapshots and Metadata
    
    public typealias Graph = CanvasGraph
    public typealias Snapshot = CanvasDAG.DAGSnapshot<CanvasNodeCollection>
    
    public var current: Snapshot
    public internal(set) var display: Snapshot {
        didSet {
//            print("UPDATE DISPLAY")
//
//            for subgraph in display.allSubgraphs {
//                print("SUBGRAPH \(subgraph.key)")
//                subgraph.metaNode?.log()
//                subgraph.finalNode?.log()
//            }
            
            informObservers(old: metadata(for: oldValue),
                            new: metadata(for: display))
        }
    }
    
    public func metaNode(for commit: Graph) -> CanvasMetaNode {
        return commit.metaNode(for: subgraphKey) as! CanvasMetaNode
    }
    
    public func metadata(for commit: Graph) -> CanvasMetadata {
        return metaNode(for: commit).payload
    }
    
    public func set(_ metadata: CanvasMetadata, in graph: MutableGraph) {
        metaNode(for: graph).payload = metadata
    }
    
    public func modifyMetadata(in graph: MutableGraph,
                        _ f: (inout CanvasMetadata) -> ()) {
        var m = metadata(for: graph)
        f(&m)
        set(m, in: graph)
    }
    
    public var currentMetadata: CanvasMetadata { return metadata(for: current) }
    public var displayMetadata: CanvasMetadata { return metadata(for: display) }
    
    public var displayLayerKeys: [LayerKey] { return displayMetadata.layers }
//    @available(*, deprecated)
//    var displayLayerDAGs: [DAGSnapshot] { return displayMetadata.sortedRawSnapshots }
//    @available(*, deprecated)
//    var displayLayerMetaNodes: [LayerMetaNode] { return displayLayerDAGs.map { $0.metaNode as! LayerMetaNode} }
//    @available(*, deprecated)
//    var displayLayerMetadatas: [LayerMetadata] { return displayLayerMetaNodes.map { $0.payload } }
    
    // MARK: - unsorted
    
//    fileprivate var canvasSize = UIScreen.main.nativeBounds.size
    fileprivate var isProperlyCommittingCanvas = false
    
//    @available(*, deprecated)
//    fileprivate lazy var _canvas: Canvas = {
//        let canvas = Canvas(size: canvasSize, layers: [])
//        return canvas
//    }()
    
//    @available(*, deprecated)
//    fileprivate lazy var _displayCanvas: Canvas = {
//        let canvas = Canvas(size: canvasSize, layers: [])
//        return canvas
//    }()

//    @available(*, deprecated)
//    var canvas: Canvas {
//        get { return _canvas }
//        set { set(canvas: newValue) }
//    }
//
//    @available(*, deprecated)
//    var displayCanvas: Canvas {
//        get { return _displayCanvas }
//        set { set(display: newValue) }
//    }
    
    public var size: CGSize { return displayMetadata.size }
    public var canvasScale: CGFloat {
        #if os(iOS)
        return size.width / CGRect.screen.width
        #else
        return 1
        #endif
    }
    
    public weak var currentTransaction: CanvasTransaction? = nil
//    let transactionSemaphore = DispatchSemaphore(value: 1)
//    var semaphoreValue: Int = 1
    
    public let undoManager = CanvasUndoManager()
    
    var maxMemorySize: MemorySize = 500000000 // min(MemoryManager.shared.physicalMemory * 0.25, 500000000)
    var reducingMemory = false
    
//    var _mergeContext: RenderContext?
//    var mergeContext: RenderContext! { return _mergeContext ?? canvasView?.context }
    
    public static var defaultSize: CGSize {
        #if os(iOS)
        return UIScreen.main.nativeBounds.size
        #else
        return CGSize(2048)
        #endif
    }
    
    public convenience init(canvasSize: CGSize = CanvasManager.defaultSize) {
        let metadata = CanvasMetadata(width: Int(round(canvasSize.width)), height: Int(round(canvasSize.height)))
        self.init(metadata)
    }
    
    var activeNode: NodePath? = nil
//    var activeCaptionPath: CaptionPath? = nil
    var memoryReductionDisabled = false
//    let activeCaptionOverlay = BlendNode()
//    let topAlphaNode = AlphaNode(1)
//    let bottomAlphaNode = AlphaNode(0)
//    let captionBlurNode = BlurPreviewNode(.init(15))
//    var backgroundNode = SolidColorNode(.white)
    
    // MARK: Undo/Redo
    
    public func undo() -> CanvasAction? {
        if let action = currentTransaction?.undo() {
            print("UNDO \(action.description)")
            return action
        } else  if let (action, graph) = undoManager.undo() {
            current = graph
            display = graph
            print("UNDO \(action.description)")
            return action
        }
        
        return nil
    }
    
    public func redo() -> CanvasAction? {
        print("REDO")
        if let (action, graph) = undoManager.redo() {
            current = graph
            display = graph
            print("REDO \(action.description)")
            return action
        } else if let action = currentTransaction?.redo() {
            print("REDO \(action.description)")
            return action
        }
        
        return nil
    }
    
    public var undoCount: Int {
        var count = undoManager.undoCount
        if let t = currentTransaction {
            count += t.undoCount
        }
        
        return count
    }
    
    public var redoCount: Int {
        var count = undoManager.redoCount
        if let t = currentTransaction {
            count += t.redoCount
        }
        
        return count
    }

    public func clearRedos() {
        undoManager.redoList.removeAll()
        currentTransaction?.clearRedos()
    }
    
    // MARK: Set Canvas
    
    var invalidatedNodes = Set<NodeKey>()
    
    func checkForInvalidNodes() -> Bool {
//        for layer in canvas.layers {
//            for invalid in invalidatedNodes {
//                if layer.contains(invalid) {
//                    print("OOPS! Found invalid node \(invalid)")
//                    layer.node!.log()
//
//                    return true
//                }
//            }
//        }
        
        return false
    }
    
    
    func updateCanvasForMemory(_ new: One) {
//        isProperlyCommittingCanvas = true
//        set(canvas: new)
//        isProperlyCommittingCanvas = false
//
//        set(display: new)
    }
    
    func informObservers(old: CanvasMetadata, new: CanvasMetadata) {
        canvasVC?.updateUndoButtons()
        
        if observers.count == 0 { return }
        
        let permutations = Permutations(from: old.layers, to: new.layers, log: false)
        
        if !permutations.moves.isEmpty {
            informObservers { $0.canvasDidReorderLayers() }
        } else {
            for remove in permutations.removes {
                informObservers { $0.canvasRemoved(layer: remove.element, at: remove.oldIndex) }
            }
            
            for insert in permutations.inserts {
                informObservers { $0.canvasInserted(layer: insert.element, at: insert.newIndex) }
            }
        }
        
        if old.layerCount > 0 {
            if old.selectedLayer != new.selectedLayer {
                informObservers { $0.canvasSelected(layer: new.selectedLayer, at: new.selectedIndex) }
            }
        }
        
//        if old.backgroundIsHidden != new.backgroundIsHidden {
//            informObservers { $0.canvasBackground(hidden: new.backgroundIsHidden) }
//        }
        
        for manager in allLayerManagers {
            manager.updatePreview()
        }
    }
    
    func informObservers(_ block: (CanvasObserver)->()) {
        for observer in observers {
            block(observer)
        }
    }
    
    func informBasicObservers(_ block: (BasicCanvasObserver)->()) {
        for observer in basicObservers {
            block(observer)
        }
    }
    
    // MARK: Layers
    
    private var layerManagers: [LayerKey:LayerManager] = [:]
    
    public var allLayerManagers: [LayerManager] {
        var managers: [LayerManager] = []
        queue.sync { managers = Array(layerManagers.values) }
        return managers
    }
    
    public func existingManager(for key: LayerKey) -> LayerManager? {
        var manager: LayerManager? = nil
        queue.sync { manager = layerManagers[key] }
        return manager
    }
    
    public func manager(for key: LayerKey) -> LayerManager {
        var manager: LayerManager? = nil
        
        queue.sync {
            if let man = layerManagers[key] {
                manager = man
            } else {
                let man = LayerManager(key, canvasManager: self)
                layerManagers[key] = man
                manager = man
            }
        }
        
        
        return manager!
    }
    
    func purgeOldManagers() {
        queue.sync {
//            let layerKeys = canvas.layerKeys
//            let managerKeys = layerManagers.keys
//            
//            let oldKeys = managerKeys - layerKeys
//            
//            for key in oldKeys {
//                layerManagers.removeValue(forKey: key)
//            }
        }
    }
    
    // MARK: Transactions
    
    public func newTransaction(identifier: String) -> CanvasTransaction {
        return newTransactionBlocking(identifier: identifier)
    }
    
    public func newTransaction(identifier: String, commit: Bool = true, block: (CanvasTransaction)->()) {
        let transaction = self.newTransactionBlocking(identifier: identifier)
        block(transaction)
        
        if commit {
            transaction.commit()
        }
    }
    
    public func newTransactionBlocking(identifier: String) -> CanvasTransaction {
//        transactionSemaphore.wait()
//        semaphoreValue -= 1
        
//        print("new transaction!")
        
        if let current = currentTransaction {
            print("SEMAPHORE ERROR")
            print("transaction \(current.identifier) already exists")
            fatalError("transaction \(current.identifier) already exists")
        }
        
        let transaction = CanvasTransaction(manager: self, identifier: identifier)
        currentTransaction = transaction
        
        return transaction
    }
    
    public func initializingTransaction() -> InitializingTransaction {
        guard currentTransaction == nil else {
            fatalError("Tried to create a new transaction, but one is already pending!")
        }
        
//        transactionSemaphore.wait()
//        semaphoreValue -= 1
        
        let transaction = InitializingTransaction(manager: self, identifier: "initial")
        currentTransaction = transaction
        
        return transaction
    }
    
    public func push(_ canvasAction: CanvasAction) {
        let transaction = newTransaction(identifier: "\(canvasAction)")
        transaction.push(canvasAction)
        transaction.commit()
    }
    
//    func push(_ easyAction: EasyCanvasAction) {
//        let transaction = newTransaction(identifier: "\(easyAction)")
//        transaction.push(easyAction)
//        transaction.commit()
//    }
    
//    @available(*, deprecated)
//    var currentCanvas: Canvas {
//        return canvas.copy()
//    }
    
    // MARK: Observers
    
    private var _basicObservers = NSHashTable<AnyObject>.weakObjects()
    private var _observers = NSHashTable<AnyObject>.weakObjects()
    var observers: [CanvasObserver] {
        return _observers.allObjects.compactMap { $0 as? CanvasObserver }
    }
    
    var basicObservers: [BasicCanvasObserver] {
        return _basicObservers.allObjects.compactMap { $0 as? BasicCanvasObserver }
    }
    
    public func add(observer: CanvasObserver) {
        _observers.add(observer)
    }
    
    public func remove(observer: CanvasObserver) {
        _observers.remove(observer)
    }
    
    public func add(observer: BasicCanvasObserver) {
        _basicObservers.add(observer)
    }
    
    public func remove(observer: BasicCanvasObserver) {
        _basicObservers.remove(observer)
    }
    
    // MARK: Misc
    
    public func purgeCachesIfNeeded() {
        for manager in layerManagers.values {
            manager.purgeCachesIfNeeded()
        }
    }
    
}
 
extension CanvasManager: CanvasTransactionParent {
    
    public var currentCanvas: Snapshot {
        return current
    }
    
    public var displayCanvas: Snapshot {
        get { return display }
        set { display = newValue.modify { updateCanvasSubgraph(in: $0) } .externalReference }
    }
    
    public func commit(transaction: CanvasTransaction) {
        precondition(transaction === currentTransaction)
        
        activeNode = nil
        
        print("COMMIT TO CANVAS MANAGER")
        for action in undoManager.undoList {
            print(" - \(action.description)")
        }
        
        print("ADDING \(transaction.actions.count) ACTIONS...")
        
        for action in transaction.actions {
            if action.before !== action.after {
                print(" - \(action.description)")
                undoManager.push(action)
            } else {
                print(" - \(action.description) (SKIPPED!)")
            }
        }
        
        if let graph = transaction.after {
            let updated = graph.modify { updateCanvasSubgraph(in: $0) } .externalReference
            
            current = updated
            display = updated
        } else {
            display = current
        }
        
        currentTransaction = nil
        
        delegate?.canvas(changed: currentMetadata)
        
//        transactionSemaphore.signal()
//        semaphoreValue += 1
    }
    
    public func cancel(transaction: CanvasTransaction) {
        precondition(transaction === currentTransaction)
        
        display = current
        
        currentTransaction = nil
//        transactionSemaphore.signal()
//        semaphoreValue += 1
    }
    
}


public protocol CanvasManagerDelegate: class {
    
    func canvas(changed canvas: CanvasMetadata)
    
}

struct NodePath {
    let layerKey: LayerKey
    let nodeKey: NodeKey
    
    init(_ layerKey: LayerKey, _ nodeKey: NodeKey) {
        self.layerKey = layerKey
        self.nodeKey = nodeKey
    }
}

extension MetalTexture: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        return "MetalTexture (\(_texture.pointerString))"
    }
    
}

//extension CanvasManager: DAGStoreDelegate {
//
//    func hotlist(for graphs: [DAG]) -> Set<SubgraphKey>? {
//        let metadatas = graphs.map { metadata(for: $0) }
//
//        return metadatas.reduce(into: Set(subgraphKey)) { $0 += $1.layerSubgraphs.values }
//    }
//
//    func processCommit(commit: DAG) -> InternalDirectSnapshot? {
//        return commit.modify(level: 1) { graph in
//            let metadata = self.metadata(for: graph)
//            for layer in metadata.layers {
//                let manager = self.manager(for: layer)
//                manager.processCommit(graph: graph)
//            }
//
//            updateCanvasSubgraph(in: graph)
//        }
//    }
//
//    func considerPurging(_ pairs: [(DNode, Subgraph)]) {
//        for (node, subgraph) in pairs {
//            if considerPurging(node, in: subgraph) {
//                return
//            }
//        }
//    }
//
//    func considerPurging(_ node: DNode, in subgraph: Subgraph) -> Bool {
//        if subgraph.key == subgraphKey { return false }
//
//        var node = node
//        if let cache = node as? CacheNode {
//            guard let input = cache.input else { return false }
//            node = input
//        }
//
//        print("SHOULD FLATTEN? (cost: \(node.cost))")
//        node.log(with: "\t")
//
//        if node.cost <= 1 { return false }
//
//        var texturesToPurge = WeakSet( node.all(as: ImageNode.self).map { $0.texture } )
//        var allocations = WeakSet( node.all(as: ImageNode.self).map { subgraph.graph.payloadAllocation(for: $0.key, level: 0)! } )
//
//        let options = RenderOptions("purge", mode: .usingExtent, format: .float16, time: 0)
//        fatalError()
////        RenderManager.shared.render(node, options) { [weak self] in
////            guard let store = self?.store else { return }
////            guard let head = store.sortedExternalCommits.first else { return }
////            let (texture, transform) = $0
////
////            print("purge received: \(texture) \(transform)")
////
//////            let matrix = texture.colorSpace!.matrix(to: .working)
////
////            var purged = head.flattened
////            var replacement: ImageNode!
////
////            print("replacing: \(node)")
////
//////            for subgraphKey in head.allSubgraphKeys {
////            let subgraphKey = subgraph.key
////            for level in 0...head.maxLevel {
////                print("lv \(level)")
////                purged = purged.modify(as: head.key, level: level) { (graph) in
////                    replacement = replacement ?? ImageNode(texture: texture,
////                                                           transform: transform,
////                                                           colorMatrix: .identity,
////                                                           graph: graph)
////
////                    print("    with: \(replacement)")
////
////                    let subgraph = graph.subgraph(for: subgraphKey)
////                    subgraph.finalNode = subgraph.finalNode?.replacing(node.key, with: replacement)
////                }
////            }
//////            }
////
////            purged = purged.modify(as: purged.key, level: 1) { graph in
////                self?.updateCanvasSubgraph(in: graph)
////            }
////
////            purged = purged.flattened
////
////            print("BEFORE \(head.key)")
////            for subgraph in head.allSubgraphs {
////                print("  - \(subgraph.key)")
////                subgraph.finalNode?.log(with: "\t\t")
////            }
////
////            print("AFTER \(purged.key)")
////            for subgraph in purged.allSubgraphs {
////                print("  - \(subgraph.key)")
////                subgraph.finalNode?.log(with: "\t\t")
////            }
////
////            print("max level: \(purged.maxLevel)")
////            print("depth: \(purged.depth)")
////
////            if purged.contains(allocations: Set(allocations)) {
////                fatalError()
////            }
////
////            if purged.contains(textures: Set(texturesToPurge)) {
////                fatalError()
////            }
////
////            massert(purged.key == head.key)
////
////            store.commit(purged, process: false)
////            DispatchQueue.global().async {
////                store.vacuumSync(allocations: Set(allocations), texturesToPurge: Set(texturesToPurge))
////            }
////
////            for committed in store.sortedExternalCommits {
////                print("COMMITTED \(committed.key)")
////                for subgraph in committed.allSubgraphs {
////                    print("  - \(subgraph.key)")
////                    subgraph.finalNode?.log(with: "\t\t")
////                }
////            }
////
////            print("\nSTORE EXTERNAL")
////            for graph in store.sortedExternalCommits {
////                print("graph \(graph) \(graph.key)")
////                if graph.contains(allocations: Set(allocations)) {
////                    print("wtf")
////                }
////
////                if graph.contains(textures: Set(texturesToPurge)) {
////                    print("wtf")
////                }
////            }
////
////            print("\nSTORE ALL")
////            for graph in store.commits.values {
////                print("graph \(graph) \(graph.key)")
////                if graph.contains(allocations: Set(allocations)) {
////                    print("wtf")
////                }
////
////                if graph.contains(textures: Set(texturesToPurge)) {
////                    print("wtf")
////                }
////            }
////
////            let tempKey = self!.layerManagers.values.first!.subgraphKey
////            print("BEFORE:")
////            head.subgraph(for: tempKey).finalNode!.log()
////            print("AFTER:")
////            purged.subgraph(for: tempKey).finalNode!.log()
////
////            DispatchQueue.main.asyncAfter(deadline: .now() + 4) { [weak self] in
////                self?.checkTextures(texturesToPurge, allocations)
////            }
////        }
//
//        return true
//    }
//
//    func checkTextures(_ texturesToPurge: WeakSet<MetalTexture>, _ allocations: WeakSet<PayloadBufferAllocation>) {
//
//        var shouldReturn = false
//        autoreleasepool {
//            if allocations.count == 0, texturesToPurge.count == 0 {
//                shouldReturn = true
//            }
//        }
//        if shouldReturn { return }
//
//        autoreleasepool {
//            if texturesToPurge.count > 0 {
//                print("found lingering textures!")
//
//                for texture in texturesToPurge {
//                    print(" - \(texture) \(texture.size)")
//                }
//            }
//
//            if allocations.count > 0 {
//                print("found lingering allocations!")
//
//                for allocation in allocations {
//                    print(" - \(allocation)")
//                }
//            }
//
//            print("\nSTORE EXTERNAL")
//            for graph in store.sortedExternalCommits {
//                print("graph \(graph) \(graph.key)")
//                if graph.contains(allocations: Set(allocations)) {
//                    print("wtf")
//                }
//
//                if graph.contains(textures: Set(texturesToPurge)) {
//                    print("wtf")
//                }
//            }
//
//            print("\nSTORE ALL")
//            for graph in store.commits.values {
//                print("graph \(graph) \(graph.key)")
//                if graph.contains(allocations: Set(allocations)) {
//                    print("wtf")
//                }
//
//                if graph.contains(textures: Set(texturesToPurge)) {
//                    print("wtf")
//                }
//            }
//
//            print("\nALT STORE EXTERNAL")
//            for graph in tempAltStore?.sortedExternalCommits ?? [] {
//                print("graph \(graph) \(graph.key)")
//                if graph.contains(allocations: Set(allocations)) {
//                    print("wtf")
//                }
//            }
//
//            print("\nALT STORE ALL")
//            for graph in tempAltStore?.commits.values ?? [] {
//                print("graph \(graph) \(graph.key)")
//                if graph.contains(allocations: Set(allocations)) {
//                    print("wtf")
//                }
//            }
//
//            print("\nEVERYTHING!")
//            for graph in InternalDirectSnapshot.tempDict.values {
//                print("graph \(graph) \(graph.key)")
//                if graph.contains(allocations: Set(allocations)) {
//                    print("wtf")
//                }
//
//                for (key, type) in graph.typeMap {
//                    guard type == .image else { continue }
//                    let node = graph.node(for: key) as! ImageNode
//                    let tex = node.texture
//                    print("    - \(tex)")
//                    if Set(texturesToPurge).contains(where: { $0 == tex }) {
//                        print("        WOAH")
//                    }
//                }
//            }
//        }
//
//        print(" ")
//
//        autoreleasepool {
//            guard allocations.count == 0, texturesToPurge.count == 0 else {
//                DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
//                    self?.checkTextures(texturesToPurge, allocations)
//                }
//
//                shouldReturn = true
//                return
//            }
//        }
//        if shouldReturn {
//            return
//        }
//
//        autoreleasepool {
//            allocations.removeAll { _ in true }
//            texturesToPurge.removeAll { _ in true }
//        }
//
//        print(" ")
//    }
//
//}

//extension PayloadBufferAllocation: CustomDebugStringConvertible {
//
//    var debugDescription: String {
//        let unsafe = Unmanaged.passUnretained(self).toOpaque()
//        return "PayloadBufferAllocation (\(unsafe))"
//    }
//
//}

//extension InternalDirectSnapshot: CustomDebugStringConvertible {
//
//    public var debugDescription: String {
//        let unsafe = Unmanaged.passUnretained(self).toOpaque()
//        return "InternalDirectSnapshot \(key) (\(unsafe))"
//    }
//
//}

//extension DNode {
//
//    func replacing(_ oldKey: NodeKey, with replacement: DNode) -> DNode {
//        if key == oldKey { return replacement }
//
//        let graph = dag as! MutableDAG
//        for (i, key) in edgeMap {
//            let n = graph.node(for: key).replacing(oldKey, with: replacement)
//            graph.setInput(for: self.key, index: i, to: n.key)
//        }
//
//        return self
//    }
//
//}
