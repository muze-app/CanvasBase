//
//  SizeAndTransform.swift
//  muze
//
//  Created by Greg Fajen on 6/26/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import UIKit

struct SizeAndTransform: Equatable {
    
    var size: CGSize
    var transform: AffineTransform
    var bounds: CGRect { return CGRect(origin: .zero, size: size) }
    
    init(size: CGSize, transform: AffineTransform = .identity) {
        self.size = size
        self.transform = transform
    }
    
    init(rect: CGRect, transform: AffineTransform = .identity) {
        self.size = rect.size
        self.transform = .translating(x: rect.origin.x, y: rect.origin.y) * transform
    }
    
//    var croppable: CropSandwich {
//        return CropSandwich(cropSize: size, postCropTransform: transform)
//    }
    
    var finalSize: CGSize {
        return size.applying(transform.cg.withoutRotation)
    }
    
    func transformed(by transform: AffineTransform) -> SizeAndTransform {
        return size & (self.transform * transform)
    }
    
    func expanded(by amount: CGFloat) -> SizeAndTransform {
        let scale = transform.minScale
        return SizeAndTransform(rect: bounds.inset(by: -amount * scale), transform: transform)
    }
    
    var corners: [CGPoint] {
        return bounds.corners.map { $0.applying(transform.cg) }
    }
    
}

func & (size: CGSize, transform: AffineTransform) -> SizeAndTransform {
    return SizeAndTransform(size: size, transform: transform)
}

func & (size: CGSize, transform: CGAffineTransform) -> SizeAndTransform {
    return SizeAndTransform(size: size, transform: AffineTransform(transform))
}

//func & (rect: CGRect, transform: AffineTransform) -> SizeAndTransform {
//    return SizeAndTransform(rect: rect, transform: transform)
//}

extension SizeAndTransform {
    
    init(_ crop: RenderCrop) {
       self = crop.size & crop.transform
    }
    
    var renderCrop: RenderCrop {
        return RenderCrop(size: size, transform: transform)
    }
    
    static func ~ (l: SizeAndTransform, r: SizeAndTransform) -> Bool {
        return l.size ~= r.size && l.transform ~= r.transform
    }
    
}
