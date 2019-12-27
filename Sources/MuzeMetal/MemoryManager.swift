//
//  MemoryManager.swift
//  muze
//
//  Created by Greg on 1/11/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation

class MemoryManager {
    
    static let shared = MemoryManager()
    
    init() {
        #if os(iOS)
        let center = NotificationCenter.default
        _ = center.addObserver(for: UIApplication.didReceiveMemoryWarningNotification, using: didReceiveMemoryWarning)
        #endif
    }
    
    func didReceiveMemoryWarning(_ note: Notification) {
        for observer in observers {
            observer.didReceiveMemoryWarning()
        }
    }
    
    func didEnterBackground() {
        for observer in observers {
            observer.didEnterBackground()
        }
    }
    
    // MARK: Memory Info
    
    let physicalMemory: MemorySize = MemorySize(ProcessInfo.processInfo.physicalMemory)
    
    // MARK: Observers
    
    let queue = DispatchQueue(label: "MemoryManagerQueue")
    
    private var _observers = NSHashTable<AnyObject>.weakObjects()
    var observers: [MemoryManagerObserver] {
        return queue.sync {
            return _observers.allObjects.compactMap { $0 as? MemoryManagerObserver }
        }
    }
    
    func add(observer: MemoryManagerObserver) {
        queue.sync {
            self._observers.add(observer)
        }
    }
    
    func remove(observer: MemoryManagerObserver) {
        queue.sync {
            self._observers.remove(observer)
        }
    }

}

protocol MemoryManagerObserver: class {
    
    func didReceiveMemoryWarning()
    func didEnterBackground()
    
}

extension NotificationCenter {
    
    func addObserver(for name: NSNotification.Name,
                     object: Any? = nil,
                     queue: OperationQueue? = nil,
                     using block: @escaping (Notification) -> ()) -> NSObjectProtocol {
        return addObserver(forName: name, object: object, queue: queue, using: block)
    }
    
}
