//
//  Future.swift
//  MuzePrelude
//
//  Created by Greg Fajen on 12/30/19.
//

public class Future<Value> {
    
    public typealias R = Result<Value, Error>
    
    // can be removed if we can guarantee to be on a certain queue w/o precondition(.onQueue)
    public let lock = NSRecursiveLock()
    public let queue: DispatchQueue
    
    private(set) var result: R?
    public var exists: Bool { result.exists }
    private var blocks = [(R) -> ()]()
    
    public var value: Value? { result?.success }
    public var error: Error? { result?.failure }
    
    fileprivate init(on queue: DispatchQueue) {
        let label = queue.label
        print("queue: \(label)")
        self.queue = queue
    }
    
    @inlinable
    func sync(_ block: ()->()) {
        lock.lock()
        block()
        lock.unlock()
    }
    
    fileprivate func _succeed(_ value: Value) {
        _complete(.success(value))
    }
    
    fileprivate func _fail(_ error: Error) {
        _complete(.failure(error))
    }
    
    fileprivate func _complete(_ result: R) {
        sync {
            self.result = result
            
            for block in blocks {
                queue.async { block(result) }
            }
            
            blocks = []
        }
    }
    
    public func cascade(to promise: Promise<Value>) {
        await { promise.complete($0) }
    }
    
    public func await(_ block: @escaping (R) -> () = { _ in }) {
        if let result = result { block(result); return }
        
        sync {
            if let result = result { block(result); return }
            blocks.append(block)
        }
    }
    
    @inlinable
    public func flatMap<T>(_ f: @escaping (Value) -> Future<T>) -> Future<T> {
        let promise = Promise<T>(on: queue)
        
        self.onSuccess { f($0).cascade(to: promise) }
        self.onFailure { promise.fail($0) }
        
        return promise.future
    }
    
    @inlinable
    public func map<T>(_ f: @escaping (Value) throws -> (T)) -> Future<T> {
        let promise = Promise<T>(on: queue)
        
        self.onSuccess {
            do {
                promise.succeed(try f($0))
            } catch let e {
                promise.fail(e)
            }
        }
        
        self.onFailure { promise.fail($0) }
        
        return promise.future
    }
    
    @inlinable
    public func mapResult<T>(_ f: @escaping (R) throws -> T) -> Future<T> {
        let promise = Promise<T>(on: queue)
        await {
            do {
                promise.succeed(try f($0))
            } catch let e {
                promise.fail(e)
            }
        }
        return promise.future
    }
    
    @inlinable
    public func mapError(_ f: @escaping (Error) throws -> Value) -> Future<Value> {
        mapResult { result -> Value in
            switch result {
                case .success(let value): return value
                case .failure(let error):
                    do {
                        return try f(error)
                    } catch let e {
                        throw e
                }
            }
        }
    }
    
}

public extension Result {
    
    var success: Success? {
        switch self {
            case .success(let s): return s
            case .failure: return nil
        }
    }
    
    var failure: Failure? {
        switch self {
            case .success: return nil
            case .failure(let f): return f
        }
    }
    
}

// a tiny wrapper around Future to allow us to set it
// once we get rid of the promises, the Future becomes immutable
// generally, you keep promises to yourself and pass around futures
// the preferred way of creating futures if you have one already is to use a function like flatmap
public struct Promise<Value> {
    
    public let future: Future<Value>
    
    public typealias R = Result<Value, Error>
    
    public init(on queue: DispatchQueue = .global()) {
        future = .init(on: queue)
    }
    
    public func succeed(_ value: Value) {
        future._succeed(value)
    }
    
    public func fail(_ error: Error) {
        future._fail(error)
    }
    
    public func complete(_ result: R) {
        future._complete(result)
    }
    
}

public extension Future {
    
    func hop(to queue: DispatchQueue) -> Future<Value> {
        let promise = Promise<Value>(on: queue)
        cascade(to: promise)
        return promise.future
    }
    
    static func succeeded<Value>(_ value: Value) -> Future<Value> {
        let p = Promise<Value>()
        p.succeed(value)
        return p.future
    }
    
    static func failed<Value>(_ error: Error) -> Future<Value> {
        let p = Promise<Value>()
        p.fail(error)
        return p.future
    }
    
}

public extension Future {
    
    func log() -> Future<Value> {
        return mapResult { result -> Value in
            switch result {
                case .success(let value):
                    print("value: \(value)")
                    return value
                
                case .failure(let error):
                    print("error: \(error)")
                    throw error
            }
        }
    }
    
}

public extension Future {
    
    func onSuccess(_ f: @escaping (Value)->()) {
        self.await {
            switch $0 {
                case .success(let value): f(value)
                case .failure: break
            }
        }
    }
    
    func onFailure(_ f: @escaping (Error)->()) {
        self.await {
            switch $0 {
                case .success: break
                case .failure(let error): f(error)
            }
        }
    }
    
    // WARNING: currently produces results out of order
    static func reducing<Value>(_ futures: [Future<Value>]) -> Future<[Value]> {
        let promise = Promise<[Value]>()
        
        let tempLock = NSLock() // this will go soon but here for now
        var remaining = futures.count
        var results: [Value] = []
        
        var hasFailed = false
        
        for future in futures {
            future.onSuccess { result in
                tempLock.lock()
                guard !hasFailed else { return }
                
                results.append(result)
                remaining -= 1
                
                if remaining == 0 {
                    promise.succeed(results)
                }
                
                tempLock.unlock()
            }
            
            future.onFailure { error in
                tempLock.lock()
                if !hasFailed {
                    hasFailed = true
                    promise.fail(error)
                }
                tempLock.unlock()
            }
        }
        
        return promise.future
    }
    
}
