//
//  MetalBuffer.swift
//  muze
//
//  Created by Greg Fajen on 5/24/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation
import Metal
import MuzePrelude

public protocol MetalBuffer {
    
    var length: Int { get }
    var asData: Data { get }
    
    func transformed(by transform: AffineTransform) -> Self
    
}

//extension MetalBuffer {
//
//    public func transformed(by transform: AffineTransform) -> Self { return self }
//
//}

extension Data: MetalBuffer {
    
    public var length: Int {
        return self.count
    }
    
    public var asData: Data {
        return self
    }
    
    public func transformed(by transform: AffineTransform) -> Self { self }
    
}

extension Array: MetalBuffer where Element: MetalBuffer {
    
    public var length: Int {
        return reduce(into: 0) { $0 += $1.length }
    }
    
    public var asData: Data {
        reduce(into: Data(capacity: length)) { $0.append($1.asData) }
    }
    
    public func transformed(by transform: AffineTransform) -> [Element] {
        return map { $0.transformed(by: transform) }
    }
    
}

extension Float: MetalBuffer {
    
    public var length: Int { 4 }
    public var asData: Data { Data(from: self) }
    
    public func transformed(by transform: AffineTransform) -> Float {
        return self
    }
    
}

extension AffineTransform: MetalBuffer {
    
    public var length: Int { 32 }
    public var asData: Data { cg.asPaddedFloats.asData }
    
    public func transformed(by transform: AffineTransform) -> AffineTransform {
        return self * transform
    }
    
}

extension MTLBuffer {
    
    fileprivate var data: Data {
       return Data(bytes: contents(), count: length)
    }
    
}
