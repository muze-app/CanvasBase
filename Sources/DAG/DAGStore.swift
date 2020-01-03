//
//  DAGStore.swift
//  muze
//
//  Created by Greg Fajen on 9/3/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation
import MuzePrelude
 
typealias StoreKey = Key<DAGStore<MockNodeCollection>>

private let keyKey = DispatchSpecificKey<StoreKey>()

public class DAGStore<Collection: NodeCollection> {
    
    var payloadBuffers = PayloadBufferSet()
    
    let key = StoreKey()
    let queue = DispatchQueue(label: "DAG",
                              qos: .userInteractive,
                              attributes: .concurrent,
                              autoreleaseFrequency: .workItem,
                              target: nil)
    
    private var _isWriting = false
    
    public var excludedSubgraphKeys: Set<SubgraphKey> = Set()
    
    var tempSubgraphKey: SubgraphKey?
    
    public typealias Snapshot = InternalDirectSnapshot<Collection>
    
//    @available(*, deprecated)
//    public var latest: DAGSnapshot<Collection>!
    var commits = WeakDict<CommitKey, Snapshot>()
    
    private var internalRetainedCommitsBag = Bag<CommitKey>() {
        willSet { preconditionWriting() }
    }
    private var externalRetainedCommitsBag = Bag<CommitKey>() {
        willSet { preconditionWriting() }
    }
    var retainedCommitsSet: Set<CommitKey> {
        return internalRetainedCommitsBag.asSet + externalRetainedCommitsBag.asSet
    }
    var retainedCommits = ThreadSafeDict<CommitKey, Snapshot>()
    public var commitTimes = [CommitKey: Date]() {
        willSet { preconditionWriting() }
    }

    var externalCommits: [Snapshot] {
        read {
            externalRetainedCommitsBag.asSet.map {
                let key = $0
                let commit = commits[key]!
                
                if commit.key != key {
                    // shouldn't happen but we'll just let it slide for now.
                    // pretty sure keys are going to get removed from the commits themselves
                    return commit.modify(as: key) { _ in }
                }
                
                assert(commit.key == key)
                //            commits[$0]!
                return commit
            }
        }
    }
    
    var sortedExternalCommits: [Snapshot] {
        read {
        var pairs = externalCommits.map { ($0, commitTimes[$0.key]!) }
        pairs.sort { $0.1 < $1.1 }
        return pairs.map { $0.0 }
        }
    }
    
    public var sortedCommits: HeadAndTail<Snapshot> { HeadAndTail(sortedExternalCommits)! }
    
    public func simplifyHead() {
        preconditionWriting()
        autoreleasepool {
            let head = sortedCommits.head.flattened
            self.commit(head, setLatest: false)
        }
    }
    
    public func simplifyTail() {
        preconditionWriting()
        autoreleasepool {
            let sorted = sortedCommits
            let head = sorted.head.internalReference
            for commit in sorted.tail {
                let diff = commit.diff(from: head)
                self.commit(diff, setLatest: false)
            }
        }
    }
        
    weak var delegate: AnyObject?
    
    public init(delegate: AnyObject? = nil) {
        self.delegate = delegate
        
        queue.setSpecific(key: keyKey, value: key)
        
        let graph = Snapshot(store: self)
        commit(graph)
    }
    
    public func doNothing() {
        // just to keep in memory
    }
    
    // MARK: - Threading
    
    public var isOnQueue: Bool { key == currentKey }
    public var isReading: Bool { isOnQueue }
    public var isWriting: Bool { _isWriting && isOnQueue }
    
    public var isOnAnotherQueue: Bool {
        guard let currentKey = currentKey else { return false }
        return currentKey != key
    }
    
    var currentKey: StoreKey? { DispatchQueue.getSpecific(key: keyKey) }
    
    public func read<T>(_ f: () -> T) -> T {
        if isReading { return f() }
        
        precondition(!isOnAnotherQueue, "You can't comingle different stores")
        
        return queue.sync(execute: f)
    }
    
    @discardableResult
    public func readAsync<T>(_ f: @escaping () -> T) -> Future<T> {
        let promise = Promise<T>()
        queue.async {
            promise.succeed(f())
        }
        
        return promise.future
    }
    
    public func write<T>(_ f: () -> T) -> T {
        if isOnQueue {
            guard _isWriting else {
                fatalError("cannot promote read access to write access")
            }
            
            return f()
        }
        
        precondition(!isOnAnotherQueue, "You can't comingle different stores")
        
        return queue.sync(flags: .barrier) {
            _isWriting = true
            let t = f()
            _isWriting = false
            return t
        }
    }
    
    @discardableResult
    public func writeAsync<T>(_ f: @escaping () -> T) -> Future<T> {
        let promise = Promise<T>()
        queue.async(flags: .barrier) {
            self._isWriting = true
            promise.succeed(f())
            self._isWriting = false
        }
        return promise.future
    }
    
    func preconditionReading() {
        dispatchPrecondition(condition: .onQueue(queue))
    }
    
    func preconditionWriting() {
        dispatchPrecondition(condition: .onQueue(queue))
        precondition(_isWriting)
    }
    
    // MARK: - Commits
    
    public func commit(for key: CommitKey) -> Snapshot? {
        read { commits[key] }
    }
    
    @discardableResult
    public func commit(_ snapshot: Snapshot, process: Bool = true) -> CommitKey {
        return commit(snapshot, setLatest: true, process: process)
    }
    
    @discardableResult
    public func commit(_ snapshot: Snapshot, setLatest: Bool, process: Bool = true) -> CommitKey {
        let key: CommitKey = snapshot.key
        
        write {
            var snapshot = snapshot
            if snapshot.depth > 20 {
                snapshot = snapshot.flattened
            }
            
            let snapshotToCommit = snapshot
//            if process, let processed = self.process(commit: snapshot) {
//                snapshotToCommit = processed
//            }
            
            assert(snapshotToCommit.key == key)
//            let key = snapshotToCommit.key
            
//            let snapshot = (snapshot.metaNode is CanvasMetaNode) ? snapshot.flattened : snapshot
            
            commits[key] = snapshotToCommit
            commitTimes[key] ?= Date()
//            self.latest = DAGSnapshot(store: self, key: key, .externalReference)
            
            retain(commitFor: key, mode: .externalReference)
            writeAsync { self.release(commitFor: key, mode: .externalReference) }
            
//            self.retainedCommitsSet.insert(key)
//            self.retainedCommits[key]
//
//            if self.retainedCommitsSet.contains(key) {
//                self.retainedCommits[key] = snapshotToCommit
//            }
            
//            if process, let processed = self.process(commit: snapshot) {
//                self.commit(processed, setLatest: false, process: false)
//            }
        }
        
        //        if snapshot.depth > 100 {
        //        if snapshot.depth > 12 {
        //            vacuum()
        //        }
        
        return key
    }
    
    func retain(commitFor key: CommitKey, mode: DAGSnapshot<Collection>.Mode) {
        write {
            guard let commit = commits[key] else { fatalError() }
            guard commitTimes[key].exists else { fatalError() }
            
            switch mode {
                case .externalReference: externalRetainedCommitsBag.insert(key)
                case .internalReference: internalRetainedCommitsBag.insert(key)
            }
            
            retainedCommits[key] = commit
        }
    }
    
    func release(commitFor key: CommitKey, mode: DAGSnapshot<Collection>.Mode) {
        write {
            switch mode {
                case .externalReference: externalRetainedCommitsBag.remove(key)
                case .internalReference: internalRetainedCommitsBag.remove(key)
            }
            
            if !retainedCommitsSet.contains(key) {
                autoreleasepool {
                    removeRetainedCommit(key)
                }
            }
        }
    }
    
    private func removeRetainedCommit(_ key: CommitKey) {
        retainedCommits.remove(key)
    }

}

protocol DAGStoreDelegate: class {
    
    associatedtype Collection: NodeCollection
    
    func hotlist(for graphs: [DAGBase<Collection>]) -> Set<SubgraphKey>?
    func processCommit(commit: DAGBase<Collection>) -> InternalDirectSnapshot<Collection>?
    func considerPurging(_ nodes: [(GenericNode<Collection>, Subgraph<Collection>)])
    
}

infix operator ?= : AssignmentPrecedence
func ?= <T>(l: inout T?, r: T) { l = l ?? r }

public struct HeadAndTail<T>: Sequence {
    
    public let head:  T
    public let tail: [T]

    public init?(_ array: [T]) {
        if array.isEmpty { return nil }
        
        head = array.first!
        tail = .init(array.dropFirst())
    }
    
    public var count: Int { 1 + tail.count }
    public var asArray: [T] { [head] + tail }
    
    public func makeIterator() -> IndexingIterator<[T]> { asArray.makeIterator() }

}
