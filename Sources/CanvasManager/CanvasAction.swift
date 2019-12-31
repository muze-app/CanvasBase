//
//  CanvasAction.swift
//  muze
//
//  Created by Greg on 1/17/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation

public class CanvasAction {
    
    public let description: String
    
    public let before: Snapshot
    public let after: Snapshot
    
    public init(_ description: String, before: Snapshot, _ block: (MutableGraph)->()) {
        self.description = description
        self.before = before
        
        let store = before.store
        let afterInternal = before.internalSnapshot.modify(block)
        store.commit(afterInternal)
        
        self.after = afterInternal.externalReference
    }
    
    public init(_ description: String, before: Snapshot, after: Snapshot) {
        self.description = description
        self.before = before
        self.after = after
    }
    
    public convenience init(name: String, actions: [CanvasAction]) {
        self.init(name, before: actions.first!.before, after: actions.last!.after)
    }
    
}
