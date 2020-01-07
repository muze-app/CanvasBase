//
//  CanvasTransaction.swift
//  muze
//
//  Created by Greg on 2/2/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import MuzePrelude

public class CanvasTransaction {
    
    public let identifier: String
    
    public weak var manager: CanvasTransactionParent!
    public let initialCanvas: Snapshot
    public var currentCanvas: Snapshot
    
    var actualManager: CanvasManager {
        while true {
            if let manager = manager as? CanvasManager {
                return manager
            } else if let transaction = manager as? CanvasTransaction {
                return transaction.actualManager
            } else {
                fatalError()
            }
        }
    }
    
    public var currentTransaction: CanvasTransaction?
    
    public internal(set) var actions: [CanvasAction] = []
    public var redos = [CanvasAction]()
    public var numberOfActions: Int { return actions.count }
    public var undoCount: Int {
        if let t = currentTransaction, !t.isFrozen, t.actions.count > 0 {
            return actions.count + 1
        } else {
            return actions.count
        }
    }
    public var redoCount: Int {
        if let t = currentTransaction, t.isFrozen {
            return redos.count + 1
        } else {
            return redos.count
        }
    }
    
    public var before: Snapshot? { actions.first?.before }
    public var after:  Snapshot? { actions.last?.after }
    
    public var isFrozen = false
    public weak var freezingDelegate: CanvasTransactionFreezingDelegate?
    
    var superActionName: String?
    
    public init(manager: CanvasTransactionParent, identifier: String) {
        self.manager = manager

        let canvas: DAGSnapshot = manager.currentCanvas
        initialCanvas = canvas
        currentCanvas = canvas

        self.identifier = identifier
    }
    
    deinit {
        if !hasCommittedOrCancelled {
            print("transaction \(identifier) deallocated without being committed or cancelled!")
            
            print(" ")
            DispatchQueue.global().sync {
                self.cancel()
            }
        }
    }
    
    public func modify(description: String, with block: (MutableGraph)->()) {
        let action = CanvasAction(description, actualManager, before: currentCanvas, block)
        push(action)
    }
    
    public func modify(description: String,
                       layer: LayerManager,
                       with block: (Subgraph<CanvasNodeCollection>)->()) {
        let action = LayerAction(description, before: currentCanvas, layerManager: layer, block)
        push(action)
    }
    
    public func modifyDisplay(layer: LayerManager,
                              with block: (Subgraph<CanvasNodeCollection>)->()) {
        let action = LayerAction("", before: currentCanvas, layerManager: layer, block)
        displayCanvas = action.after
    }
    
    public var hasCommitted = false
    public var hasCancelled = false
    public var hasCommittedOrCancelled: Bool { return hasCommitted || hasCancelled }
    
    public var hasActions: Bool { return !actions.isEmpty }
    
    public func commitOrCancel() {
        if hasActions {
            commit()
        } else {
            cancel()
        }
    }
    
    public func commit() {
        precondition(!currentTransaction.exists)
        
//        print("COMMIT TRANSACTION")
        
        if let name = superActionName {
            let superAction = CanvasAction(name: name, actions: actions)
            actions = [superAction]
        } else {
//            print("not a super action...")
        }
        
        manager.commit(transaction: self)
//        manager.activeNode = nil
        hasCommitted = true
    }
    
    public func cancel() {
        precondition(!currentTransaction.exists)
        
        manager?.cancel(transaction: self)
//        manager?.activeNode = nil
        hasCancelled = true
    }
    
    public var disableDisplayUpdates = false {
        didSet {
            if !disableDisplayUpdates {
//                manager.displayCanvas = _currentCanvas.copy()
            }
        }
    }
    
    public func push(_ action: CanvasAction) {
        precondition(!currentTransaction.exists)
        precondition(!hasCommittedOrCancelled)
        
        clearRedos()
//        undoDummy()
        
        let oldCanvas = currentCanvas
        let newCanvas = action.after
        
        let manager = actualManager
      
        manager.store.read {
            print("OLD:")
            oldCanvas.subgraph(for: manager.subgraphKey).finalNode?.log()

            print("NEW:")
            newCanvas.subgraph(for: manager.subgraphKey).finalNode?.log()
        }
            
        actions.append(action)
        
        currentCanvas = newCanvas
        
        if !disableDisplayUpdates {
            manager.displayCanvas = newCanvas
        }
        
//        
//        let oldCanvas = _currentCanvas
//        var newCanvas = oldCanvas.copy()
//        newCanvas >> action
//        
////        var backAgain = newCanvas.copy()
////        backAgain << action
////        
////        if (backAgain != oldCanvas) {
////            print("Something when wrong. Good thing we checked!")
////            print("   action: \(action)")
////
////            drillDownInequality(oldCanvas, backAgain)
////            fatalError()
////        }
//        
////        if let pushAction = action as? SomePushNodeAction {
////            manager.activeNode = pushAction.nodePath
////        }
//        
//        _actions.append(action)
//        _currentCanvas = newCanvas
//        
//        if !disableDisplayUpdates {
////        manager.displayCanvas = _currentCanvas.copy()
//        }
//        
//        coalesceActions(canvas: initialCanvas, options: coalescingOptions)
    }
    
    func push(dummy: CanvasAction) {
//        assert(!currentTransaction.exists)
//        assert(!hasCommittedOrCancelled)
//        
//        clearRedos()
//        undoDummy()
//        
////        if let action = dummy as? TransformAction {
////            print("    transform: \(action.transform)")
////        }
//         
//        var canvas = _currentCanvas.copy()
//        canvas >> dummy
//        
//        manager.displayCanvas = canvas.copy()
//        
//        self.dummy = dummy
    }
    
//    func push(_ easyAction: EasyCanvasAction) {
////        push(easyAction.action(for: currentCanvas))
//    }
//    
//    func push(dummy easyAction: EasyCanvasAction) {
////        push(dummy: easyAction.action(for: currentCanvas))
//    }
    
    var dummy: CanvasAction?
    
    func undoDummy() {
//        guard let dummy = dummy else { return }
//        let _ = currentCanvas << dummy
//        self.dummy = nil
    }
    
    public func setUseSuperAction(withName name: String) {
        superActionName = name
    }
    
}

public class InitializingTransaction: CanvasTransaction {
    
    public init(manager: CanvasManager, identifier: String) {
//        guard manager.canvas.layerCount == 0 else {
//            fatalError("Can only create an initializing transaction on an empty canvas")
//        }
        
        super.init(manager: manager, identifier: identifier)
    }
    
//    var canvas: Canvas {
//        get { return _currentCanvas }
//        set { _currentCanvas = newValue }
//    }
    
    override public func commit() {
//        massert(actions.isEmpty)
        super.commit()
    }
    
    override public func push(_ action: CanvasAction) {
//        fatalError()
    }
    
}
