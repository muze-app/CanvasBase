//
//  DrawablePool.swift
//  muze
//
//  Created by Greg on 1/9/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation

class Pool<T: AnyObject & MemoryManagee>: MemoryManagerObserver {
    
    private let queue = DispatchQueue(label: "DrawablePool.\(String(describing: T.self)).Queue")
    private var items = [T]()
    private var lent = [T]()
    let initializer: () -> T
    let refresher: (T) -> ()
    
    init(initializer: @escaping () -> T, refresher: @escaping (T) -> ()) {
        self.initializer = initializer
        self.refresher = refresher
        MemoryManager.shared.add(observer: self)
    }
    
    func create() -> T {
//        print("creating new object!!!")
        return initializer()
    }
    
    func refresh(_ item: T) {
        refresher(item)
    }
    
    func forget(_ item: T) {
        queue.sync {
            lent.removeAll { $0 === item }
            items.removeAll { $0 === item }
        }
    }
    
    func acquire() -> T {
        return queue.sync { () -> T in
            if let item = abandoned {
//                print("    returning abandoned item!")
                refresh(item)
                return item
            }
            
            if self.items.isEmpty {
                let item = self.create()
                lent.append(item)
                return item
            }
            
            let item = self.items.removeFirst()
            lent.append(item)
            refresh(item)
            return item
        }
    }
    
    // NOTE: not strictly necessary since we can catch abandoned objects, but nice to do
    func release(_ object: T) {
        queue.sync {
            lent.removeAll { $0 === object }
            items.append(object)
        }
    }
    
    // WARNING: this is more fragile than I'd like
    private var abandoned: T? {
        return lent.first { CFGetRetainCount($0) < 4 }
    }
    
    private func collectAbandonedItems() {
        while let item = abandoned {
            items.append(item)
            lent.removeAll { $0 === item }
        }
    }
    
    // MARK: Memory Manager Observer
    
    func purge() {
        queue.async {
            autoreleasepool {
                self.lent.removeAll()
                self.items.removeAll()
            }
        }
    }
    
    func didReceiveMemoryWarning() {
        purge()
    }
    
    func didEnterBackground() {
        purge()
    }
    
    var memoryHash: MemoryHash {
        return (items + lent).reduce(into: [:], { (hash, item) in
            hash += item.memoryHash
        })
    }
    
}

class DrawablePool<T: Drawable>: Pool<T> {
    
    static var defaultInitializer: () -> T {
        return { T() }
    }
    
    static var defaultRefresher: (T) -> () {
        return { $0.clear() }
    }
    
    override init(initializer: @escaping () -> T = DrawablePool<T>.defaultInitializer,
                  refresher: @escaping (T)->() = DrawablePool<T>.defaultRefresher ) {
        super.init(initializer: initializer, refresher: refresher)
    }
    
    convenience init(width: Int, height: Int) {
        let initializer: () -> T = {
            return T(width: width, height: height)
        }
        
        self.init(initializer: initializer)
    }
    
    override func create() -> T {
        let item = super.create()
        item.pool = self
        return item
    }
    
}
