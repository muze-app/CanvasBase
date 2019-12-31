
//
//  CanvasTransaction+Freezing.swift
//  muze
//
//  Created by Greg Fajen on 9/12/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation

extension CanvasTransaction {
    
    func freeze() -> CanvasAction {
        precondition(!isFrozen)
        precondition(freezingDelegate.exists)
        
        let before = self.before!
        let after = self.after!
        
        let description = freezingDelegate!.freeze(subtransaction: self)
        let action = CanvasAction(description, before: before, after: after)
        
        currentCanvas = before
        displayCanvas = before
        
        isFrozen = true
        
        return action
    }
    
    func unfreeze() -> CanvasAction {
        precondition(isFrozen)
        precondition(freezingDelegate.exists)
        
        let before = self.before!
        let after = self.after!
        
        let description = freezingDelegate!.unfreeze(subtransaction: self)
        let action = CanvasAction(description, before: before, after: after)
        
        currentCanvas = after
        displayCanvas = after
        
        isFrozen = false
        
        return action
    }
    
}

protocol CanvasTransactionFreezingDelegate {
    
    func freeze(subtransaction: CanvasTransaction) -> String
    func unfreeze(subtransaction: CanvasTransaction) -> String
    
    func frozenSubtransactionCancelled(_ subtransaction: CanvasTransaction)
    
}
