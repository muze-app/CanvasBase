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
    
//    public weak var tempAltStore: DAGStore?
    
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
        
        let graph = InternalSnapshot(store: store).modify { graph in
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
    
    public convenience init(canvasSize: CGSize = CanvasManager.defaultSize) {
        let metadata = CanvasMetadata(width: Int(round(canvasSize.width)), height: Int(round(canvasSize.height)))
        self.init(metadata)
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
            
            store.read {
                informObservers(old: metadata(for: oldValue),
                                new: metadata(for: display))
            }
        }
    }
    
    public func metaNode(for commit: Graph) -> CanvasMetaNode {
        store.read { commit.metaNode(for: subgraphKey) as! CanvasMetaNode }
    }
    
    public func metadata(for commit: Graph) -> CanvasMetadata {
        store.read { metaNode(for: commit).payload }
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
    
    public weak var currentTransaction: CanvasTransaction?
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
    
    var activeNode: NodePath?
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
            print("    commit: \(display.key)")
            return action
        } else  if let (action, graph) = undoManager.undo() {
            current = graph
            display = graph
            print("UNDO \(action.description)")
            print("    commit: \(display.key)")
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
            print("    commit: \(display.key)")
            return action
        } else if let action = currentTransaction?.redo() {
            print("REDO \(action.description)")
            print("    commit: \(display.key)")
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
        var manager: LayerManager?
        queue.sync { manager = layerManagers[key] }
        return manager
    }
    
    public func manager(for key: LayerKey) -> LayerManager {
        var manager: LayerManager?
        
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
        set {
            let graph = newValue.modify { updateCanvasSubgraph(in: $0) }
            store.commit(graph)
            
            display = graph.externalReference
        }
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
        
        print("DISPLAY: \(display.key)")
        store.read { display.subgraph(for: subgraphKey).finalNode?.log() }
        
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
