//
//  SizeAndTransform.swift
//  muze
//
//  Created by Greg Fajen on 6/26/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

#if os(macOS)
import AppKit
#else
import UIKit
#endif

public struct SizeAndTransform: Equatable {
    
    public var size: CGSize
    public var transform: AffineTransform
    public var bounds: CGRect { return CGRect(origin: .zero, size: size) }
    
    public init(size: CGSize, transform: AffineTransform = .identity) {
        self.size = size
        self.transform = transform
    }
    
    public init(rect: CGRect, transform: AffineTransform = .identity) {
        self.size = rect.size
        self.transform = .translating(x: rect.origin.x, y: rect.origin.y) * transform
    }
    
//    var croppable: CropSandwich {
//        return CropSandwich(cropSize: size, postCropTransform: transform)
//    }
    
    public var finalSize: CGSize {
        return size.applying(transform.cg.withoutRotation)
    }
    
    public func transformed(by transform: AffineTransform) -> SizeAndTransform {
        return size & (self.transform * transform)
    }
    
    public func expanded(by amount: CGFloat) -> SizeAndTransform {
        let scale = transform.minScale
        return SizeAndTransform(rect: bounds.inset(by: -amount * scale), transform: transform)
    }
    
    public var corners: [CGPoint] {
        return bounds.corners.map { $0.applying(transform.cg) }
    }
    
}

public func & (size: CGSize, transform: AffineTransform) -> SizeAndTransform {
    return SizeAndTransform(size: size, transform: transform)
}

public func & (size: CGSize, transform: CGAffineTransform) -> SizeAndTransform {
    return SizeAndTransform(size: size, transform: AffineTransform(transform))
}

public func & (rect: CGRect, transform: AffineTransform) -> SizeAndTransform {
    return SizeAndTransform(rect: rect, transform: transform)
}

public extension SizeAndTransform {
    
//    init(_ crop: RenderCrop) {
//       self = crop.size & crop.transform
//    }
//    
//    var renderCrop: RenderCrop {
//        return RenderCrop(size: size, transform: transform)
//    }
    
    static func ~ (l: SizeAndTransform, r: SizeAndTransform) -> Bool {
        return l.size ~= r.size && l.transform ~= r.transform
    }
    
}
