//
//  ThreadSafeDict.swift
//  muze
//
//  Created by Greg Fajen on 6/25/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation

final class ThreadSafeDict<Key: Hashable, Value>: AltDict {
    
    let lock = NSRecursiveLock()
    
    private var _dict: [Key:Value]
    
    init() { _dict = [:] }
    
    init(dict: [Key:Value] = [:]) { _dict = dict }
    
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
    
    func remove(_ key: Key) {
        sync { _dict.removeValue(forKey: key) }
    }
    
    var dict: [Key:Value] {
        var result: [Key:Value]?
        sync {
            result = _dict
        }
        return result!
    }
    
    var keys: [Key] { return [Key](dict.keys) }
    var values: [Value] { return [Value](dict.values) }
    
    func filter(isIncluded: ((Key,Value))->Bool) -> ThreadSafeDict<Key,Value> {
        return ThreadSafeDict(dict: dict.filter(isIncluded))
    }
    
    func sync(_ block: ()->()) {
          lock.lock()
              block()
        lock.unlock()
    }
    
}
