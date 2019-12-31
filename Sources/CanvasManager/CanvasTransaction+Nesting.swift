//
//  CanvasTransaction+Nesting.swift
//  muze
//
//  Created by Greg Fajen on 6/28/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation

extension CanvasTransaction: CanvasTransactionParent {
    
    public var displayCanvas: Snapshot {
        get { manager.displayCanvas }
        set { manager.displayCanvas = newValue }
    }
    
    public func newTransaction(identifier: String) -> CanvasTransaction {
        guard !currentTransaction.exists else {
            fatalError("tried creating a transaction when one already exists")
        }
        
        let transaction = CanvasTransaction(manager: self, identifier: identifier)
        currentTransaction = transaction
        
        return transaction
    }
    
    public func commit(transaction: CanvasTransaction) {
        precondition(currentTransaction === transaction)
        currentTransaction = nil
        
        disableDisplayUpdates = true
        
        for action in transaction.actions {
            push(action)
        }
        
        disableDisplayUpdates = false
    }
    
    public func cancel(transaction: CanvasTransaction) {
        precondition(currentTransaction === transaction)
        currentTransaction = nil
    }
    
//    var activeNode: NodePath? {
//        get { return manager.activeNode }
//        set { manager.activeNode = newValue }
//    }
    
//    var displayCanvas: Canvas {
//        get { return manager.displayCanvas }
//        set { manager.displayCanvas = newValue }
//    }
    
    public func undo() -> CanvasAction? {
        if let transaction = currentTransaction, !transaction.isFrozen {
            return transaction.freeze()
        }
        
        if actions.isEmpty { return nil }

        let action = actions.removeLast()
        redos.append(action)

        currentCanvas = action.before
        displayCanvas = action.before

        return action
    }
    
    public func redo() -> CanvasAction? {
        if redos.isEmpty {
            if let transaction = currentTransaction, transaction.isFrozen {
                return transaction.unfreeze()
            } else {
                return nil
            }
        }
        
        let action = redos.removeLast()
        actions.append(action)
        
        currentCanvas = action.after
        displayCanvas = action.after

        return action
    }
    
    public func clearRedos() {
        redos = []
        
        if let t = currentTransaction {
            if t.isFrozen {
                t.freezingDelegate!.frozenSubtransactionCancelled(t)
            }
            
            t.cancel()
        }
    }
    
}

public extension CanvasAction {
    
    var pointer: UnsafeMutableRawPointer {
        return Unmanaged.passUnretained(self).toOpaque()
    }
    
}
