//
//  DAGStore.swift
//  muze
//
//  Created by Greg Fajen on 9/3/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation
import MuzePrelude

public class DAGStore<Collection: NodeCollection> {
    
    public let lock = NSRecursiveLock()
    public var modLock: NSRecursiveLock { return lock }
    
    public var excludedSubgraphKeys: Set<SubgraphKey> = Set()
    
    var tempSubgraphKey: SubgraphKey?
    
    public typealias Snapshot = InternalDirectSnapshot<Collection>
    
    public var latest: DAGSnapshot<Collection>!
    var commits = WeakDict<CommitKey, Snapshot>()
    
    private var internalRetainedCommitsBag = Bag<CommitKey>() {
        willSet { lock.lock() }
        didSet { lock.unlock() }
    }
    private var externalRetainedCommitsBag = Bag<CommitKey>() {
        willSet { lock.lock() }
        didSet { lock.unlock() }
    }
    var retainedCommitsSet: Set<CommitKey> {
        return internalRetainedCommitsBag.asSet + externalRetainedCommitsBag.asSet
    }
    var retainedCommits = ThreadSafeDict<CommitKey, Snapshot>()
    public var commitTimes = [CommitKey: Date]() {
        willSet { lock.lock() }
        didSet { lock.unlock() }
    }

    var externalCommits: [Snapshot] {
        sync {
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
        sync {
        var pairs = externalCommits.map { ($0, commitTimes[$0.key]!) }
        pairs.sort { $0.1 < $1.1 }
        return pairs.map { $0.0 }
        }
    }
    
    public var sortedCommits: HeadAndTail<Snapshot> { HeadAndTail(sortedExternalCommits)! }
    
    public func simplifyHead() {
        autoreleasepool {
            let head = sortedCommits.head.flattened
            self.commit(head, setLatest: false)
        }
    }
    
    public func simplifyTail() {
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
        
        let graph = Snapshot(store: self)
        commit(graph)
    }
    
    public func doNothing() {
        // just to keep in memory
    }
    
    // MARK: - Threading
    
    public func sync<T>(_ f: () -> T) -> T {
        lock.lock()
        defer { lock.unlock() }
        
        return f()
    }
    
    public func async(_ block: @escaping ()->()) {
        DispatchQueue.global().async { self.sync(block) }
    }
    
    // MARK: - Commits
    
    public func commit(for key: CommitKey) -> Snapshot? {
        sync { commits[key] }
    }
    
    @discardableResult
    public func commit(_ snapshot: Snapshot, process: Bool = true) -> CommitKey {
        return commit(snapshot, setLatest: true, process: process)
    }
    
    @discardableResult
    public func commit(_ snapshot: Snapshot, setLatest: Bool, process: Bool = true) -> CommitKey {
        let key: CommitKey = snapshot.key
        
//        var snapshot = snapshot
//        if snapshot.depth > 20 {
//            snapshot = snapshot.flattened
//        }
        snapshot.verify()
        
//        if isLayer {
//            print("commit \(snapshot.key) (processed: \(!process))")
//        }
        
        sync {
            let snapshotToCommit = snapshot
//            if process, let processed = self.process(commit: snapshot) {
//                snapshotToCommit = processed
//            }
            
            assert(snapshotToCommit.key == key)
//            let key = snapshotToCommit.key
            
//            let snapshot = (snapshot.metaNode is CanvasMetaNode) ? snapshot.flattened : snapshot
            
            self.commits[key] = snapshotToCommit
            self.commitTimes[key] ?= Date()
            self.latest = DAGSnapshot(store: self, key: key, .externalReference)
            
            if self.retainedCommitsSet.contains(key) {
                self.retainedCommits[key] = snapshotToCommit
            }
            
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
        sync {
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
        sync {
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
