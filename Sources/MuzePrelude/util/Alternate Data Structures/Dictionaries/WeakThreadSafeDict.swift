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
        get { sync { _dict[key] } }
        set { sync { _dict[key] = newValue } }
    }
    
    public var dict: [Key:Value] { sync { _dict.dict } }
    
    public var keys: [Key] { [Key](dict.keys) }
    public var values: [Value] { [Value](dict.values) }
    
//    func filter(isIncluded: ((Key,Value))->Bool) -> ThreadSafeDict<Key,Value> {
//        return ThreadSafeDict(dict: dict.filter(isIncluded))
//    }
    
    func sync<T>(_ block: () -> (T)) -> T {
        lock.lock()
        let t = block()
        lock.unlock()
        return t
    }
    
}
