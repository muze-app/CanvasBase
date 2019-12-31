//
//  CanvasTransaction.swift
//  muze
//
//  Created by Greg on 2/2/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import UIKit

class CanvasTransaction {
    
    let identifier: String
    
    weak var manager: CanvasTransactionParent! = nil
    let initialCanvas: Snapshot
    var currentCanvas: Snapshot
    
    var currentTransaction: CanvasTransaction?
    
    var actions: [CanvasAction] = []
    var redos = [CanvasAction]()
    var numberOfActions: Int { return actions.count }
    var undoCount: Int {
        if let t = currentTransaction, !t.isFrozen, t.actions.count > 0 {
            return actions.count + 1
        } else {
            return actions.count
        }
    }
    var redoCount: Int {
        if let t = currentTransaction, t.isFrozen {
            return redos.count + 1
        } else {
            return redos.count
        }
    }
    
    var before: Snapshot? { actions.first?.before }
    var after:  Snapshot? { actions.last?.after }
    
    var isFrozen = false
    var freezingDelegate: CanvasTransactionFreezingDelegate?
    
    
    var superActionName: String? = nil
    
    init(manager: CanvasTransactionParent, identifier: String) {
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
    
    func modify(description: String, with block: (MutableGraph)->()) {
        let action = CanvasAction(description, before: currentCanvas, block)
        push(action)
    }
    
    func modify(description: String,
                layer: LayerManager,
                with block: (Subgraph<CanvasNodeCollection>)->()) {
        let action = LayerAction(description, before: currentCanvas, layerManager: layer, block)
        push(action)
    }
    
    func modifyDisplay(layer: LayerManager,
                       with block: (Subgraph<CanvasNodeCollection>)->()) {
        let action = LayerAction("", before: currentCanvas, layerManager: layer, block)
        displayCanvas = action.after
    }
    
    var hasCommitted = false
    var hasCancelled = false
    var hasCommittedOrCancelled: Bool { return hasCommitted || hasCancelled }
    
    var hasActions: Bool { return !actions.isEmpty }
    
    func commitOrCancel() {
        if hasActions {
            commit()
        } else {
            cancel()
        }
    }
    
    func commit() {
        precondition(!currentTransaction.exists)
        
        print("COMMIT TRANSACTION")
        
        if let name = superActionName {
            let superAction = CanvasAction(name: name, actions: actions)
            actions = [superAction]
        } else {
            print("not a super action...")
        }
        
        manager.commit(transaction: self)
        manager.activeNode = nil
        hasCommitted = true
    }
    
    func cancel() {
        precondition(!currentTransaction.exists)
        
        manager?.cancel(transaction: self)
        manager?.activeNode = nil
        hasCancelled = true
    }
    
    var disableDisplayUpdates = false {
        didSet {
            if !disableDisplayUpdates {
//                manager.displayCanvas = _currentCanvas.copy()
            }
        }
    }
    
    func push(_ action: CanvasAction) {
        precondition(!currentTransaction.exists)
        precondition(!hasCommittedOrCancelled)
        
        clearRedos()
//        undoDummy()
        
//        let oldCanvas = currentCanvas
        let newCanvas = action.after
        
//        print("OLD:")
//        if let manager = manager as? CanvasManager {
//            let meta = (oldCanvas.metaNode as! CanvasMetaNode).payload
//            let smapshot = meta.layerSnapshots[manager.tempLayerManager.key]!
//            let commit = smapshot.internalSnapshot
//            commit.finalNode.log()
//        }
//
//        print("NEW:")
//        if let manager = manager as? CanvasManager {
//            let meta = (newCanvas.metaNode as! CanvasMetaNode).payload
//            let key = meta.layerSnapshots[manager.tempLayerManager.key]!
//            let commit = key.internalSnapshot
////            commit.finalNode.log()
//        }
        
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
    
    func setUseSuperAction(withName name: String) {
        superActionName = name
    }
    
}

class InitializingTransaction: CanvasTransaction {
    
    init(manager: CanvasManager, identifier: String) {
//        guard manager.canvas.layerCount == 0 else {
//            fatalError("Can only create an initializing transaction on an empty canvas")
//        }
        
        super.init(manager: manager, identifier: identifier)
    }
    
//    var canvas: Canvas {
//        get { return _currentCanvas }
//        set { _currentCanvas = newValue }
//    }
    
    override func commit() {
//        massert(actions.isEmpty)
        super.commit()
    }
    
    override func push(_ action: CanvasAction) {
//        fatalError()
    }
    
}

