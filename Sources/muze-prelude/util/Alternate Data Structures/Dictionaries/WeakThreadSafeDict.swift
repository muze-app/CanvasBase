//
//  WeakThreadSafeDict.swift
//  muze
//
//  Created by Greg Fajen on 10/8/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

// forgive the WETness

import Foundation

public final class WeakThreadSafeDict<Key: Hashable, Value: AnyObject>: AltDict {
    
    let lock = NSRecursiveLock()
    
    private var _dict: WeakDictionary<Key, Value>
    
    public init() { _dict = .init() }
    
    public init(dict: [Key:Value] = [:]) {
        self._dict = WeakDictionary(dict)
    }
    
    public subscript(key: Key) -> Value? {
        get {
            var result: Value? = nil
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
    
    public var dict: [Key:Value] {
        var result: [Key:Value]?
        sync {
            result = _dict.dict
        }
        return result!
    }
    
    public var keys: [Key] { return [Key](dict.keys) }
    public var values: [Value] { return [Value](dict.values) }
    
//    func filter(isIncluded: ((Key,Value))->Bool) -> ThreadSafeDict<Key,Value> {
//        return ThreadSafeDict(dict: dict.filter(isIncluded))
//    }
    
    func sync(_ block: ()->()) {
        lock.lock()
        block()
        lock.unlock()
    }
    
}
