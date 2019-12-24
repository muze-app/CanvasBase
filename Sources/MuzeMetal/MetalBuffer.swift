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

protocol MetalBuffer {
    
    var length: Int { get }
    var asData: Data { get }
    
    func transformed(by transform: AffineTransform) -> Self
    
}

extension MetalBuffer {
    
    func transformed(by transform: AffineTransform) -> Self { return self }
    
}

extension Data: MetalBuffer {
    
    var length: Int {
        return self.count
    }
    
    var asData: Data {
        return self
    }
    
}

extension Array: MetalBuffer where Element: MetalBuffer {
    
    var length: Int {
        return reduce(into: 0) { $0 += $1.length }
    }
    
    var asData: Data {
        return reduce(into: Data(capacity: length)) { $0.append($1.asData) }
    }
    
    func transformed(by transform: AffineTransform) -> [Element] {
        return map { $0.transformed(by: transform) }
    }
    
}

extension Float: MetalBuffer {
    
    var length: Int { return 4 }
    var asData: Data { /*return Data(from: self)*/ fatalError() }
    
    public func transformed(by transform: AffineTransform) -> Float {
        return self
    }
    
}

extension AffineTransform: MetalBuffer {
    
    var length: Int {
        return 32
    }
    
    var asData: Data {
        fatalError()
//        return asPaddedFloats.asData
    }
    
}

extension MTLBuffer {
    
    fileprivate var data: Data {
       return Data(bytes: contents(), count: length)
    }
    
}
