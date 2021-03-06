//
//  Drawable.swift
//  muze
//
//  Created by Greg on 1/10/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation
#if os(iOS)
import UIKit
#endif

import MuzePrelude

public protocol Drawable: class, MemoryManageeLeaf {

    var width: Int { get }
    var height: Int { get }
    var size: CGSize { get }
    
    init(width: Int, height: Int)
    
    static var fullscreenPool: DrawablePool<Self> { get }
    
    func clear()
    
    var pool: DrawablePool<Self>? { get set }
    func releaseToPool()
    func stealFromPool()
    
}

extension Drawable {
    
    #if os(macOS)
    public init(size: CGSize = CGSize(width: 1, height: 1),
                scale: CGFloat = 1) {
        let s = size * scale
        let w = Int(round(s.width))
        let h = Int(round(s.height))
        self.init(width: w, height: h)
    }
    #else
    public init(size: CGSize = UIScreen.main.bounds.size,
                scale: CGFloat = UIScreen.main.nativeScale) {
        let s = size * scale
        let w = Int(round(s.width))
        let h = Int(round(s.height))
        self.init(width: w, height: h)
    }
    #endif
    
    static var fullscreen: Self {
        return fullscreenPool.acquire()
    }
    
    public var memorySize: MemorySize {
        return MemorySize(width * height * 4)
    }
    
    public func releaseToPool() {
        pool?.release(self)
    }
    public   
    func stealFromPool() {
        pool?.forget(self)
    }
    
}
