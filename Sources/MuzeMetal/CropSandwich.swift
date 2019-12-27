//
//  CropSandwich.swift
//  muze
//
//  Created by Greg on 2/5/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation
import MuzePrelude

public typealias AbstractCroppable = CropSandwich

public func & (l: AffineTransform, r: SizeAndTransform) -> CropSandwich {
    return CropSandwich(preCropTransform: l,
                        cropSize: r.size,
                        postCropTransform: r.transform)
}

public func & (l: CGAffineTransform, r: SizeAndTransform) -> CropSandwich {
    return CropSandwich(preCropTransform: AffineTransform(l),
                        cropSize: r.size,
                        postCropTransform: r.transform)
}

public func & (l: AffineTransform, r: CGSize) -> (AffineTransform, CGSize) {
    return (l, r)
}

public func & (l: CGAffineTransform, r: CGSize) -> (AffineTransform, CGSize) {
    return (AffineTransform(l), r)
}

public func & (l: (AffineTransform, CGSize), r: AffineTransform) -> CropSandwich {
    return CropSandwich(preCropTransform: l.0, cropSize: l.1, postCropTransform: r)
}

public struct CropSandwich: Equatable {

    public var postCropTransform: AffineTransform
    public var cropSize: CGSize { didSet {
        assert(cropSize.width >= 0)
        assert(cropSize.height >= 0)
    } }
    public var preCropTransform: AffineTransform
    public var cropBounds: CGRect { return .zero & cropSize }
    public var combinedTransform: AffineTransform { return preCropTransform * postCropTransform }
    
    public init(preCropTransform: AffineTransform = .identity,
                cropSize: CGSize,
                postCropTransform: AffineTransform = .identity) {
        self.preCropTransform = preCropTransform
        self.cropSize = cropSize
        self.postCropTransform = postCropTransform
        assert(cropSize.width >= 0)
        assert(cropSize.height >= 0)
    }
    
    public var transformable: SizeAndTransform {
        return cropSize & postCropTransform
    }
    
}

public extension CropSandwich {
    
    var postCropScale: ScaleAtom {
        return postCropTransform.cg.decomposition.scale
    }
    
    var finalSize: CGSize {
        let size = cropSize.applying(postCropScale.transform)
        return CGSize(width: size.width.abs, height: size.height.abs)
    }
    
    var aspectRatio: CGFloat {
        return finalSize.aspectRatio
    }
    
}

extension CropSandwich {
    
    func resized(to size: CGSize) -> CropSandwich {
        let old = CGRect(origin: .zero, size: cropSize)
        let new = CGRect(origin: .zero, size: size)
        
        let t = AffineTransform.init(from: old, to: new)
        
        let pre = preCropTransform * t
        let post = t.inverse * postCropTransform
        
        return CropSandwich(preCropTransform: pre,
                                 cropSize: size,
                                 postCropTransform: post)
    }
    
    var normalized: CropSandwich {
        //        return self
        let scale = postCropTransform.decomposition.scale
        
        var size = cropSize
        size.width = round(size.width * abs(scale.x))
        size.height = round(size.height * abs(scale.y))
        
        return resized(to: size)
    }
    
    var corners: [CGPoint] {
        let xs = [0, cropSize.width]
        let ys = [0, cropSize.height]
        return (xs ** ys).map { CGPoint(x: $0, y: $1) }
    }
    
}

extension CGRect {
    
    var corners: [CGPoint] {
        let xs = [minX, maxX]
        let ys = [minY, maxY]
        return (xs ** ys).map { CGPoint(x: $0, y: $1) }
    }
    
}

infix operator ** : MultiplicationPrecedence

extension Array {
    
    static func ** <B>(lhs: [Element], rhs: [B]) -> [(Element,B)] {
        var result = [(Element,B)]()
        for a in lhs {
            for b in rhs {
                result.append((a,b))
            }
        }
        
        return result
    }
    
}
