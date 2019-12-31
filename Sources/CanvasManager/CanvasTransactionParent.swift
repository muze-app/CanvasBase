//
//  CanvasTransactionParent.swift
//  muze
//
//  Created by Greg on 2/3/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation

protocol CanvasTransactionParent: class {
    
    var currentTransaction: CanvasTransaction? { get }
    func newTransaction(identifier: String) -> CanvasTransaction
    
    func commit(transaction: CanvasTransaction)
    func cancel(transaction: CanvasTransaction)
    
    var activeNode: NodePath? { get set }
    
    func undo() -> CanvasAction?
    func redo() -> CanvasAction?
    
    var currentCanvas: Snapshot { get }
    var displayCanvas: Snapshot { get set }
    
    func clearRedos()
    
}
