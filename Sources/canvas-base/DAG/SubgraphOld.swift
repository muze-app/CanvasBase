////
////  SubgraphOld.swift
////  muze
////
////  Created by Greg Fajen on 9/3/19.
////  Copyright © 2019 Ergo Sum. All rights reserved.
////
//
//import Foundation
//
//@available(*, deprecated)
//class SubgraphOld {
//    
//    let key: NodeKey
//    weak var store: DAGStore?
//    weak var delegate: DAGStoreDelegate?
//    
//    let lock = NSRecursiveLock()
//    var modLock: NSRecursiveLock { return lock }
//    
//    var latest: DAGSnapshot!
//    var commits = WeakDict<CommitKey,InternalDirectSnapshot>()
//    
//    private var internalRetainedCommitsBag = Bag<CommitKey>()
//    private var externalRetainedCommitsBag = Bag<CommitKey>()
//    var retainedCommitsSet: Set<CommitKey> {
//        return internalRetainedCommitsBag.asSet + externalRetainedCommitsBag.asSet
//    }
//     var retainedCommits = ThreadSafeDict<CommitKey,InternalDirectSnapshot>()
//    private var commitTimes = [CommitKey: Date]()
//    
//    init(_ key: NodeKey = NodeKey(), store: DAGStore) {
//        self.key = key
//        self.store = store
//        
//        let snapshot = InternalDirectSnapshot(store: store, level: 0)
//        let key = commit(snapshot)
//        latest = DAGSnapshot(store: store, key: key, .externalReference)
//    }
//    
//    func commit(for key: CommitKey) -> InternalDirectSnapshot? {
//        var commit: InternalDirectSnapshot? = nil
//        sync {
//            commit = commits[key]
//        }
//        return commit
//    }
//    
//    @discardableResult
//    func commit(_ snapshot: InternalDirectSnapshot) -> CommitKey {
//        return commit(snapshot, setLatest: true)
//    }
//    
//    var isCanvas: Bool {
//        fatalError()
////        return latest?.metaNode is CanvasMetaNode
//    }
//    
//    var isLayer: Bool {
//        fatalError()
////        return latest?.metaNode is LayerMetaNode
//    }
//    
//    @discardableResult
//    private func commit(_ snapshot: InternalDirectSnapshot, setLatest: Bool, process: Bool = true) -> CommitKey {
//        let key: CommitKey = snapshot.key
//        
//        if isLayer {
//        print("commit \(snapshot.key) (processed: \(!process))")
//        }
//        
//        sync {
//            let snapshot = (snapshot.metaNode is CanvasMetaNode) ? snapshot.flattened : snapshot
//            
//            self.commits[key] = snapshot
//            self.latest = DAGSnapshot(store: store!, key: key, .externalReference)
//            
//            if self.retainedCommitsSet.contains(key) {
//                self.retainedCommits[key] = snapshot
//            }
//            
//            self.commitTimes[key] = self.commitTimes[key] ?? Date()
//            
//            if process, let processed = self.process(commit: snapshot) {
//                self.commit(processed, setLatest: false, process: false)
//            }
//        }
//        
////        if snapshot.depth > 100 {
////        if snapshot.depth > 12 {
////            vacuum()
////        }
//        
//        return key
//    }
//    
//    func process(commit: DAG) -> InternalDirectSnapshot? {
//        guard let processed = delegate?.processCommit(commit: commit) else { return nil }
//        let key = commit.key.with("processed")
//        print("    processed \(commit.key) -> \(key)")
//        return processed.with(key: key, level: 1).flattened
//    }
//    
//    func retain(commitFor key: CommitKey, mode: DAGSnapshot.Mode) {
//        sync {
//            guard let commit = commits[key] else {
//                fatalError()
//            }
//            
//            switch mode {
//            case .externalReference: externalRetainedCommitsBag.insert(key)
//            case .internalReference: internalRetainedCommitsBag.insert(key)
//            }
//            
//            retainedCommits[key] = commit
//        }
//    }
//    
//    func release(commitFor key: CommitKey, mode: DAGSnapshot.Mode) {
//        sync {
//            switch mode {
//            case .externalReference: externalRetainedCommitsBag.remove(key)
//            case .internalReference: internalRetainedCommitsBag.remove(key)
//            }
//            
//            if !retainedCommitsSet.contains(key) {
//                print("removing commit \(key)")
//                
//                autoreleasepool {
//                    if let oldSnapshot = self.retainedCommits[key] {
//                        let c = CFGetRetainCount(oldSnapshot)
//                        
//                        let unsafe = Unmanaged.passUnretained(oldSnapshot).toOpaque()
//                        print("    pointer: \(unsafe)")
//                        print("    retain count: \(c)")
//                    }
//                    
//                    self.retainedCommits[key] = nil
//                }
//            }
//        }
//    }
//    
//    func sync(_ block: ()->()) {
//        lock.lock()
//        block()
//        lock.unlock()
//    }
//    
//    func async(_ block: @escaping ()->()) {
//        DispatchQueue.global().async { self.sync(block) }
//    }
//    
//    func vacuum(handler: @escaping (NodeKey, DAG)->() = {(_,_) in}) {
//        async { self.vacuumSync(handler: handler) }
//    }
//    
//    func vacuumSync(flattenAll: Bool = false, handler: (NodeKey,DAG)->() = {(_,_) in}) {
//        fatalError()
////        if latest.metaNode is CanvasMetaNode { return }
////
////        sync {
////            let retainedCommitsSet = self.retainedCommitsSet
////            commitTimes = commitTimes.filter { retainedCommitsSet.contains($0.key) }
////
////            // to do: use diff against oldest commit
////            // will require us to save dates to efficiently find the oldest
////
////            let sorted = self.sortedExternalCommits
////            let head = sorted.first!.flattened
////            let tail = sorted.dropFirst()
////
////            print("HEAD OLD:")
////            sorted.first!.finalNode?.log()
////            print("HEAD NEW:")
////            head.finalNode?.log()
////
////            if let node = sorted.first!.metaNode {
////                print("META: \(node)")
////            }
////
////            var nodesChanged = Set<NodeKey>()
////
////            autoreleasepool {
////            self.commit(head, setLatest: false)
////            print(" ")
////
////            for commit in tail {
////                autoreleasepool {
////                let diff = commit.flattened
////                self.commit(diff, setLatest: false)
////
////                let touched = diff.nodesTouchedSincePredecessor
////                print("commit \(diff.key))")
////
//////                print("OLD")
//////                commit.finalNode?.log()
//////                print("NEW")
//////                diff.finalNode?.log()
////
////                print("   payload keys: \(diff.payloadMap.keys)")
////                print("   edgemap keys: \(diff.edgeMaps.keys)")
////                print("   touched: \(touched)")
////
////                nodesChanged += touched
////                }
////            }
////            }
////
////            let unchanged = Set(head.finalNode!.nodes(thatDoNotContain: nodesChanged))
////
////            print("  changed: \(nodesChanged)")
////            print("unchanged: \(unchanged)")
////
////            for key in unchanged {
////                let node = head.node(for: key)
////
////
//////                if node.inputCount == 0 {
//////                    continue
//////                }
////
////                print("SHOULD FLATTEN:")
////                node.log(with: "\t")
////
////                handler(key, head)
////            }
////
////        }
//    }
//    
//    var externalCommits: [InternalDirectSnapshot] {
//        return externalRetainedCommitsBag.asSet.map { commits[$0]! }
//    }
//    
//    var sortedExternalCommits: [InternalDirectSnapshot] {
//        var pairs = externalCommits.map { ($0, commitTimes[$0.key]!) }
//        pairs.sort { $0.1 < $1.1 }
//        return pairs.map { $0.0 }
//    }
//    
//}
//
//extension Set {
//    
//    static func += (l: inout Set<Element>, r: Set<Element>) {
//        l = l + r
//    }
//    
//    static func += <S: Sequence>(l: inout Set<Element>, r: S) where S.Element == Element {
//        l = l.union(r)
//    }
//    
//}
