//
//  ThreadSafeDict.swift
//  muze
//
//  Created by Greg Fajen on 6/25/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation

public final class ThreadSafeDict<Key: Hashable, Value>: AltDict {
    
    let lock = NSRecursiveLock()
    
    private var _dict: [Key:Value]
    
    public init() { _dict = [:] }
    
    public init(dict: [Key:Value] = [:]) { _dict = dict }
    
    public subscript(key: Key) -> Value? {
        get {
            var result: Value? 
            sync {
                result = _dict[key]
            }
            return result
        }
        
        set {
            sync {
                _dict[key] = newValue
            }
        }
    }
    
    public func remove(_ key: Key) {
        sync { _dict.removeValue(forKey: key) }
    }
    
    public var dict: [Key:Value] {
        var result: [Key:Value]?
        sync {
            result = _dict
        }
        return result!
    }
    
    public var keys: [Key] { return [Key](dict.keys) }
    public var values: [Value] { return [Value](dict.values) }
    
    public func filter(isIncluded: ((Key, Value)) -> Bool) -> ThreadSafeDict<Key, Value> {
        return ThreadSafeDict(dict: dict.filter(isIncluded))
    }
    
    func sync(_ block: ()->()) {
          lock.lock()
              block()
        lock.unlock()
    }
    
}
