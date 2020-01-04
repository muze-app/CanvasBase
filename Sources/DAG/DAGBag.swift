//
//  DAGBag.swift
//  CanvasBase
//
//  Created by Greg Fajen on 1/4/20.
//

import Foundation

class DAGBag {
    
    typealias Token = DAGReferenceToken
    
    private(set) var tokens: [Token] = []
    
    func retain(_ key: CommitKey, _ holder: AnyObject) -> Token {
        let token = Token(key, holder)
        tokens.append(token)
        return token
    }
    
    func release(_ token: Token) {
        tokens.removeAll {
            if !$0.holder.exists { return false }
            
            return $0.holder === token.holder && $0.key == token.key
        }
    }
    
    var keys: Set<CommitKey> {
        tokens.removeAll { $0.holder == nil }
        return Set(tokens.map { $0.key })
    }
    
}

struct DAGReferenceToken {
    
    let key: CommitKey
    weak var holder: AnyObject?
    
    init(_ key: CommitKey, _ holder: AnyObject) {
        self.key = key
        self.holder = holder
    }
    
}
