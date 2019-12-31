//
//  CanvasUndoManager.swift
//  muze
//
//  Created by Grant Davis on 11/13/18.
//  Copyright © 2018 MUZE LLC. All rights reserved.
//

import UIKit
import MuzeMetal

class CanvasUndoManager {
    
    typealias ActionType = CanvasAction
    
    let undoList = LinkedList<ActionType>()
    let redoList = LinkedList<ActionType>()
    
    var undoCount: Int { return undoList.nodeCount }
    var redoCount: Int { return redoList.nodeCount }
    
    var canUndo: Bool { return undoCount > 0 }
    var canRedo: Bool { return redoCount > 0 }
    
    func push(_ undo: ActionType) {
        undoList.push(undo)
        redoList.removeAll()
    }
    
    func pop(keeping count: Int) {
        while undoCount > count {
            undoList.poop()
        }
    }
    
    func pop(where predicate: (ActionType)->Bool) {
        undoList.pop(where: predicate)
    }
    
    func undo() -> (ActionType, Snapshot)? {
        if let action = undoList.pull() {
            redoList.push(action)
//            action.undo(&canvas)
            return (action, action.before)
        }
        
        return nil
    }
    
    func redo() -> (ActionType, Snapshot)? {
        if let action = redoList.pull() {
            undoList.push(action)
            return (action, action.after)
        }
        
        return nil
    }
    
}

extension CanvasUndoManager: MemoryManagee {
    
    var memoryHash: MemoryHash {
        return MemoryHash()
//        return undoList.memoryHash + redoList.memoryHash
    }
    
}
