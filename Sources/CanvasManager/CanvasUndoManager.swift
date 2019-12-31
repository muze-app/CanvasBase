//
//  CanvasUndoManager.swift
//  muze
//
//  Created by Grant Davis on 11/13/18.
//  Copyright © 2018 MUZE LLC. All rights reserved.
//

import MuzePrelude
import MuzeMetal

public class CanvasUndoManager {
    
    public typealias ActionType = CanvasAction
    
    public let undoList = LinkedList<ActionType>()
    public let redoList = LinkedList<ActionType>()
    
    public var undoCount: Int { return undoList.nodeCount }
    public var redoCount: Int { return redoList.nodeCount }
    
    public var canUndo: Bool { return undoCount > 0 }
    public var canRedo: Bool { return redoCount > 0 }
    
    public func push(_ undo: ActionType) {
        undoList.push(undo)
        redoList.removeAll()
    }
    
    public func pop(keeping count: Int) {
        while undoCount > count {
            undoList.poop()
        }
    }
    
    public func pop(where predicate: (ActionType)->Bool) {
        undoList.pop(where: predicate)
    }
    
    public func undo() -> (ActionType, Snapshot)? {
        if let action = undoList.pull() {
            redoList.push(action)
//            action.undo(&canvas)
            return (action, action.before)
        }
        
        return nil
    }
    
    public func redo() -> (ActionType, Snapshot)? {
        if let action = redoList.pull() {
            undoList.push(action)
            return (action, action.after)
        }
        
        return nil
    }
    
}

extension CanvasUndoManager: MemoryManagee {
    
    public var memoryHash: MemoryHash {
        return MemoryHash()
//        return undoList.memoryHash + redoList.memoryHash
    }
    
}
