//
//  RenderExtent.swift
//  muze
//
//  Created by Greg Fajen on 5/2/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import UIKit
import muze_prelude

public typealias BasicExtent = RenderCrop

public enum RenderExtent: Equatable {
    
    case nothing
    case infinite
    case basic(BasicExtent)
    case union(BasicExtentSet)
    
    func contains(_ extent: RenderExtent) -> Bool {
        switch (self, extent) {
        case (_, .nothing): return true
        case (.nothing, _): return false
            
        case (.infinite, _): return true
        case (_, .infinite): return false
            
        case let (.basic(a), .basic(b)):
            return a.contains(b)
            
        case let (.basic(b), .union(u)):
            for e in u {
                if !b.contains(e) {
                    return false
                }
            }
            
            return true
            
        case let (.union(u), .basic(b)):
           return u.contains(b)
            
        case let (.union(aa), .union(bb)):
            var contained = false
            
            if bb.extents.count == 0 {
                contained = true
            }
            
            for b in bb {
                if aa.contains(b) {
                    contained = true
                    break
                }
            }

            return contained
        }
    }
    
    func union(with extent: RenderExtent) -> RenderExtent {
        switch (self, extent) {
        case (.nothing, let e): return e
        case (let e, .nothing): return e
           
        // temp: this really should be in a separate union
            case (.infinite, _): return .infinite
            case (_, .infinite): return .infinite
//        case (.infinite, _): return .infinite
//        case (_, .infinite): return .infinite
            
        case let (.basic(a), .basic(b)):
            return BasicExtentSet([a,b]).renderExtent
            
        case let (.union(a), .union(b)):
            return a.union(with: b).renderExtent
            
        case let (.basic(b), .union(u)):
            return u.union(with: b).renderExtent
            
        case let (.union(u), .basic(b)):
            return u.union(with: b).renderExtent
        }
    }
    
    var simplified: RenderExtent {
        switch self {
        case .union(let u):
            switch u.extents.count {
            case 0: return .nothing
            case 1: return .basic(u.extents[0])
            default: return self
            }
            
        default:
            return self
        }
    }
    
    func transformed(by transform: AffineTransform) -> RenderExtent {
        switch self {
            case .nothing: return .nothing
            case .infinite: return .infinite
            
            case .basic:
                fatalError()
    //            return .basic(e.transformed(by: transform))
            
            case .union(let e):
                return .union(e.transformed(by: transform))
        }
    }
    
    
}

extension BasicExtent {
    
    func contains(_ point: CGPoint) -> Bool {
        for line in shadedLines {
            if !line.pointIsInShade(point) {
                return false
            }
        }
        
        return true
    }
    
    func contains(_ extent: BasicExtent) -> Bool {
        for point in extent.corners {
            if !contains(point) {
                return false
            }
        }
        
        return true
    }
    
}

public struct BasicExtentSet: Sequence, Equatable {
    
    var extents: [BasicExtent]
    
    init() {
        extents = []
    }
    
    init(_ extents: [BasicExtent]) {
        var set = BasicExtentSet()
        
        for extent in extents {
            set = set.union(with: extent)
        }
        
        self = set
    }
    
    private init(unchecked extents: [BasicExtent]) {
        self.extents = extents
    }
    
    func contains(_ point: CGPoint) -> Bool {
        for e in self {
            if e.contains(point) {
                return true
            }
        }
        
        return false
    }
    
    func contains(_ extent: BasicExtent) -> Bool {
        for e in self {
            if e.contains(extent) {
                return true
            }
        }
        
        return false
    }
    
    func union(with extent: BasicExtent) -> BasicExtentSet {
        let extents = self.filter { !extent.contains($0) }
        
        for e in extents {
            if e.contains(extent) {
                return BasicExtentSet(unchecked: extents)
            }
        }
        
        return BasicExtentSet(unchecked: extents + [extent])
    }
    
    func union(with extents: [BasicExtent]) -> BasicExtentSet {
        var copy = self
        
        for extent in extents {
            copy = copy.union(with: extent)
        }
        
        return copy
    }
    
    func union(with extents: BasicExtentSet) -> BasicExtentSet {
        return union(with: extents.extents)
    }
    
    public func makeIterator() -> IndexingIterator<[BasicExtent]> {
        return extents.makeIterator()
    }
    
    var renderExtent: RenderExtent {
        if extents.count == 0 {
            return .nothing
        } else if extents.count == 1 {
            return .basic(extents[0])
        } else {
            return .union(self)
        }
    }
    
    func transformed(by transform: AffineTransform) -> BasicExtentSet {
        fatalError()
//        let transformed = extents.map { $0.transformed(by: transform) }
//        return BasicExtentSet(unchecked: transformed)
    }
    
}

extension RenderExtent {
    
    var basic: BasicExtent? {
        switch self {
        case .basic(let b): return b
        case .union(let s): return s.basic
            
        default: return nil
        }
    }
    
}

extension BasicExtent {
    
    static let zero = BasicExtent(size: .zero, transform: .identity)
    
}

extension BasicExtentSet {
    
    var basic: BasicExtent? {
        if extents.count == 0 {
            return nil
        }
        
        if extents.count == 1 {
            return extents[0]
        }
        
        return BasicExtent(rect: points.containingRect)
    }
    
    var points: [CGPoint] {
        return extents.flatMap { $0.corners }
    }
    
}

// like a render extent, but for users
public struct UserExtent {
    
    public let level: Level
    public let extent: RenderExtent
    
    public static let nothing: UserExtent = .brush & .nothing
    
    public enum Level: Comparable, Equatable {
        
        case photo, brush
        
        public static func < (lhs: UserExtent.Level, rhs: UserExtent.Level) -> Bool {
            return (lhs == .brush) && (rhs == .photo)
        }
    
    }
    
    init(level: Level, extent: RenderExtent) {
        self.level = level
        self.extent = extent
    }
    
    func union(with other: UserExtent) -> UserExtent {
        if other.level == self.level {
            return level & (extent.union(with: other.extent))
        }
        
        return (other.level < self.level) ? self : other
    }
    
    var basic: BasicExtent? {
        return extent.basic
    }
    
    func transformed(by transform: AffineTransform) -> UserExtent {
        return level & extent.transformed(by: transform)
    }
    
}

public func & (l: UserExtent.Level, e: RenderExtent) -> UserExtent {
    return UserExtent(level: l, extent: e)
}
