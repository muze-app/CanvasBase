//
//  WeakThreadSafeSet.swift
//  muze
//
//  Created by Greg Fajen on 10/10/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation

final class WeakThreadSafeSet<Element: AnyObject & Hashable>: AltSet {
   
    private var _set: WeakSet<Element>
    let lock = NSRecursiveLock()
    
    init() { _set = .init() }
    
    
    func sync<R>(_ block: ()->R) -> R {
            lock.lock()
        let r = block()
          lock.unlock()
        
        return r
    }
    
    func insert(_ element: WeakThreadSafeSet<Element>.Element) {
        sync { _set.insert(element) }
    }
    
    func remove(_ element: WeakThreadSafeSet<Element>.Element) {
        sync { _set.remove(element) }
    }
    
    func removeAll(where predicate: (Element) -> Bool) {
        sync {
            _set.removeAll(where: predicate)
        }
    }
    
    func contains(_ element: WeakThreadSafeSet<Element>.Element) -> Bool {
        return sync { _set.contains(element) }
    }
    
    var count: Int {
        return sync { _set.count }
    }
    
    func makeIterator() -> Set<Element>.Iterator {
        let set = sync { Set(_set) }
        return set.makeIterator()
    }
    
}
