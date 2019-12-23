//
//  ArrayExtensions.swift
//  muze
//
//  Created by Greg Fajen on 5/19/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import UIKit

public extension Array where Element: OptionalProtocol {
    
    var compact: [Element.Wrapped] {
        return compactMap { $0.asOptional }
    }
    
}

public protocol OptionalProtocol {
    
    associatedtype Wrapped
    
    var asOptional: Optional<Wrapped> { get }
    
}

extension Optional: OptionalProtocol {
    
    public var asOptional: Optional<Wrapped> {
        return self
    }
    
}

public extension Optional {
    
    var array: [Wrapped] {
        if let s = self {
            return [s]
        } else {
            return []
        }
    }
    
    var exists: Bool {
        return self != nil
    }
    
}

extension Array where Element == CGFloat {
    
    var minimum: CGFloat {
        if count == 1 { return first! }
        return reduce(CGFloat.greatestFiniteMagnitude) { Swift.min($0, $1) }
    }
    
    var maximum: CGFloat {
        if count == 1 { return first! }
        return reduce(-CGFloat.greatestFiniteMagnitude) { Swift.max($0, $1) }
    }
    
}
