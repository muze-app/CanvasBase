//
//  CanvasAction.swift
//  muze
//
//  Created by Greg on 1/17/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation

class CanvasAction {
    
    let description: String
    
    let before: Snapshot
    let after: Snapshot
    
    init(_ description: String, before: Snapshot, _ block: (MutableGraph)->()) {
        self.description = description
        self.before = before
        
        let store = before.store
        let afterInternal = before.internalSnapshot.modify(block)
        store.commit(afterInternal)
        
        self.after = afterInternal.externalReference
    }
    
    init(_ description: String, before: Snapshot, after: Snapshot) {
        self.description = description
        self.before = before
        self.after = after
    }
    
    convenience init(name: String, actions: [CanvasAction]) {
        self.init(name, before: actions.first!.before, after: actions.last!.after)
    }
    
}
