//
//  WeakDict.swift
//  muze
//
//  Created by Greg Fajen on 5/17/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import UIKit

public typealias WeakDictionary = WeakDict

public final class WeakDict<Key: Hashable, Value: AnyObject>: AltDict {
    
    var _keys = Set<Key>()
    let table = NSMapTable<NSNumber,Value>(keyOptions: [.strongMemory],
                                           valueOptions: [.weakMemory])
    
    public init() { }
    
    public subscript(key: Key) -> Value? {
        get { return value(for: key) }
        set { set(value: newValue, for: key) }
    }
    
    public func value(for key: Key) -> Value? {
        return table.object(forKey: key.hashValue as NSNumber)
    }
    
    public func set(value: Value?, for key: Key) {
        if let value = value {
            table.setObject(value, forKey: key.hashValue as NSNumber)
            _keys.insert(key)
        } else {
            table.removeObject(forKey: key.hashValue as NSNumber)
            _keys.remove(key)
        }
    }
    
    public var pairs: [(Key,Value)] {
        return _keys.compactMap { (key) -> (Key,Value)? in
            if let value = self[key] {
                return (key,value)
            } else {
                _keys.remove(key)
                return nil
            }
        }
    }
    
    public var dict: [Key:Value] {
        return .init(uniqueKeysWithValues: pairs)
    }
    
    public var keys: [Key] {
        return Array(dict.keys)
    }
    
    public var values: [Value] {
        return table.objectEnumerator()!.map { $0 as! Value }
    }
    
    public func filter(isIncluded: ((key: Key, value: Value))->Bool) {
        for (key, value) in self {
            if !isIncluded((key,value)) {
                self[key] = nil
            }
        }
    }
    
}
