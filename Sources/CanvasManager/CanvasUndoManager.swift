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
    
    public private(set) var undoList = [CanvasAction]()
    public let redoList = LinkedList<ActionType>()
    
    public var undoCount: Int { undoList.count }
    public var redoCount: Int { return redoList.nodeCount }
    
    public var canUndo: Bool { undoCount > 0 }
    public var canRedo: Bool { redoCount > 0 }
    
    public func push(_ undo: ActionType) {
        undoList.append(undo)
        redoList.removeAll()
    }
    
    public func pop(keeping count: Int) {
        undoList = undoList.suffix(count)
    }
    
//    public func pop(where predicate: (ActionType) -> Bool) {
//        undoList.pop(where: predicate)
//    }
    
    public func undo() -> (ActionType, Snapshot)? {
        if let action = undoList.last {
            undoList.removeLast()
            redoList.push(action)
//            action.undo(&canvas)
            return (action, action.before)
        }
        
        return nil
    }
    
    public func redo() -> (ActionType, Snapshot)? {
        if let action = redoList.pull() {
            undoList.append(action)
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
