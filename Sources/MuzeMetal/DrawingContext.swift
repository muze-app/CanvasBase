//
//  DrawingContext.swift
//  muze
//
//  Created by Greg on 11/1/18.
//  Copyright © 2018 Ergo Sum. All rights reserved.
//

import Foundation
#if !os(macOS)
import UIKit
#endif

import MuzePrelude

public final class DrawingContext: Drawable {
    
    public let context: CGContext
    
    public var pool: DrawablePool<DrawingContext>?
    
    public convenience init(width: Int, height: Int) {
        self.init(width: width, height: height, bgra: false)
    }
    
    public required init(width: Int, height: Int, bgra: Bool, sixteen: Bool = false) {
        let alphaInfo: CGImageAlphaInfo = bgra ? .premultipliedFirst : .premultipliedLast
        let colorInfo: CGBitmapInfo//= bgra ? .byteOrder32Little : []

        switch (bgra, sixteen) {
            case (true, true):
                colorInfo = .byteOrder16Little
            case (true, false):
                colorInfo = .byteOrder32Little
            case (false, true):
                colorInfo = .byteOrder16Little
            case (false, false):
                colorInfo = []
        }
        
        let bitmapInfo: CGBitmapInfo = [colorInfo, CGBitmapInfo(rawValue: alphaInfo.rawValue)]
        
        context = CGContext(data: nil,
                            width: width,
                            height: height,
                            bitsPerComponent: sixteen ? 16 : 8,
                            bytesPerRow: width * (sixteen ? 8 : 4),
                            space: .displayP3Space,
                            bitmapInfo: bitmapInfo.rawValue)!
    }
    
    #if os(macOS)
    public convenience init(size: CGSize = CGSize(8), scale: CGFloat = 1, bgra: Bool = false) {
        let s = size * scale
        let w = Int(round(s.width))
        let h = Int(round(s.height))
        self.init(width: w, height: h, bgra: bgra)
    }
    #else
    public convenience init(size: CGSize = UIScreen.main.bounds.size, scale: CGFloat = UIScreen.main.scale, bgra: Bool = false) {
        let s = size * scale
        let w = Int(round(s.width))
        let h = Int(round(s.height))
        self.init(width: w, height: h, bgra: bgra)
    }
    
    public convenience init(image: UIImage, bgra: Bool = false) {
        self.init(size: image.size, scale: image.scale)
        draw {
            self.flip()
            image.draw(in: bounds)
        }
    }
    #endif
    
    public static var fullscreenPool: DrawablePool<DrawingContext> { return DrawablePool<DrawingContext>() }
    
    public func flip() {
        context.scaleBy(x: 1, y: -1)
        context.translateBy(x: 0, y: -CGFloat(height))
    }
    
    public func draw(_ block: ()->()) {
        #if os(macOS)
        fatalError()
        #else
        UIGraphicsPushContext(context)
        context.saveGState()
        block()
        context.restoreGState()
        UIGraphicsPopContext()
        #endif
    }
    
    public var width: Int {
        return context.width
    }
    
    public var height: Int {
        return context.height
    }

    public var stride: Int {
        return context.bytesPerRow
    }
    
    public struct UVec4 {
        public let r: UInt8
        public let g: UInt8
        public let b: UInt8
        public let a: UInt8
        
        public init(_ r: UInt8, _ g: UInt8, _ b: UInt8, _ a: UInt8) {
            self.r = r
            self.g = g
            self.b = b
            self.a = a
        }
        
    }
    
    public var data: UnsafeMutablePointer<UInt8> {
        let raw = context.data!
        
        let bytes = raw.assumingMemoryBound(to: UInt8.self)
        
        return bytes
    }
    
    public var pixels: UnsafeMutablePointer<UVec4> {
        let raw = context.data!
        
        let bytes = raw.assumingMemoryBound(to: UVec4.self)
        
        return bytes
    }
    
    public func clear() {
        context.clear(bounds)
    }
    
    public var size: CGSize {
        return CGSize(width: width, height: height)
    }
    
    public var bounds: CGRect {
        return CGRect(origin: CGPoint.zero, size: size)
    }
    
    public var cgImage: CGImage {
        return context.makeImage()!
    }
    
    #if os(iOS)
    public var uiImage: UIImage {
        return UIImage(cgImage: cgImage)
    }
    #endif
    
    public typealias FilterType = ((_ x: Int,_ y: Int,_ value: UVec4) -> UVec4)
    
    // WARNING: SLOW! Use for dev purposes only, for production use Metal instead
    @inlinable
    public func applySlowFilter(filter: FilterType) {
        let w = width
        let h = height
        let s = stride/4
        
        let d = pixels
        
        for y in (0..<h) {
            for x in (0..<w) {
                let i = y * s + x
                d[i] = filter(x, y, d[i])
            }
        }
    }
    
    // MARK: Other
    
    public let hashValue: Int = Int(arc4random())
    
    // temp
    
    #if os(iOS)
    func save(to file: String) {
        var url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
        
        url.appendPathComponent("\(file).png")
        
        let data = uiImage.pngData()
        
        print("saving to \(url)")
        
        try! data!.write(to: url)
    }
    #endif
    
}
