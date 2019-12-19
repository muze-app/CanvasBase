//
//  WeakThreadSafeDict.swift
//  muze
//
//  Created by Greg Fajen on 10/8/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

// forgive the WETness

import Foundation

final class WeakThreadSafeDict<Key: Hashable, Value: AnyObject>: AltDict {
    
    let lock = NSRecursiveLock()
    
    private var _dict: WeakDictionary<Key, Value>
    
    init() { _dict = .init() }
    
    init(dict: [Key:Value] = [:]) {
        self._dict = WeakDictionary(dict)
    }
    
    subscript(key: Key) -> Value? {
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
    
    var dict: [Key:Value] {
        var result: [Key:Value]?
        sync {
            result = _dict.dict
        }
        return result!
    }
    
    var keys: [Key] { return [Key](dict.keys) }
    var values: [Value] { return [Value](dict.values) }
    
//    func filter(isIncluded: ((Key,Value))->Bool) -> ThreadSafeDict<Key,Value> {
//        return ThreadSafeDict(dict: dict.filter(isIncluded))
//    }
    
    func sync(_ block: ()->()) {
        lock.lock()
        block()
        lock.unlock()
    }
    
}
