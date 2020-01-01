//
//  ReadWriteLock.swift
//  CanvasBase
//
//  Created by Greg Fajen on 12/31/19.
//

import MuzePrelude

public typealias RWLock = ReadWriteLock

public class ReadWriteLock {
    
    var lock = pthread_rwlock_t()
    
    public init() {
        pthread_rwlock_init(&lock, nil)
    }
    
    deinit {
        pthread_rwlock_destroy(&lock)
    }
    
    public func lockForRead() {
        pthread_rwlock_rdlock(&lock)
    }
    
    public func lockForWrite() {
        pthread_rwlock_wrlock(&lock)
    }
    
    public func unlock() {
        pthread_rwlock_unlock(&lock)
    }
    
    public func syncRead<T>(_ f: () -> T) -> T {
        lockForRead()
        defer { unlock() }
        return f()
    }
    
    public func syncWrite<T>(_ f: () -> T) -> T {
        lockForWrite()
        defer { unlock() }
        return f()
    }
    
    @discardableResult
    public func asyncRead<T>(_ f: @escaping () -> T) -> Future<T> {
        let promise = Promise<T>()
        
        DispatchQueue.global().async {
            promise.succeed(self.syncRead(f))
        }
        
        return promise.future
    }
    
    @discardableResult
    public func asyncWrite<T>(_ f: @escaping () -> T) -> Future<T> {
        let promise = Promise<T>()
        
        DispatchQueue.global().async {
            promise.succeed(self.syncWrite(f))
        }
        
        return promise.future
    }
    
}
