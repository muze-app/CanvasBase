//
//  RectsNode.swift
//  muze
//
//  Created by Greg Fajen on 5/18/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import UIKit
import MuzePrelude

//struct RectNodePair: Equatable, Hashable {
//
//    let crop: RenderCrop
//    let color: RenderColor2
//
//    init(_ crop: RenderCrop, _ color: RenderColor2) {
//        self.crop = crop
//        self.color = color
//    }
//
//    init(_ pair: (RenderCrop,RenderColor2)) {
//        self.crop = pair.0
//        self.color = pair.1
//    }
//
//    func transformed(by transform: AffineTransform) -> RectNodePair {
//        return RectNodePair(crop.transformed(by: transform), color)
//    }
//
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(crop)
//        hasher.combine(color)
//    }
//
//}

//struct RectsPayload: NodePayload {
//
//    var pairs: [RectNodePair]
//    init(_ pairs: [RectNodePair] = []) { self.pairs = pairs }
//
//    func transformed(by transform: AffineTransform) -> RectsPayload {
//        return .init( pairs.map { $0.transformed(by: transform) } )
//    }
//
//}

//class RectsNode: GeneratorNode<RectsPayload> {
//
////    override var nodeType: NodeType { return .rects }
//
//    var pairs: [RectNodePair] {
//        get { return payload.pairs }
//        set { payload.pairs = newValue }
//    }
//
//    override func renderPayload(for options: RenderOptions) -> RenderPayload? {
//
//        let count: UInt32 = UInt32(pairs.count)
//        if count == 0 { return nil }
//
//        let rects = pairs.map { (pair) -> RenderCrop in
//            return pair.crop
//        }
//
//        let colors = pairs.flatMap { $0.color.floats }
//
//        let countBuffer = Data(from: count)
//
//        let result = RenderIntermediate(identifier: "Rects", options: options, extent: renderExtent)
//        result << RenderPassDescriptor(identifier: "Rects",
//                                       pipeline: .rectsPipeline,
//                                       fragmentBuffers: [rects, colors, countBuffer])
//
//        return result.payload
//    }
//
//    override var calculatedRenderExtent: RenderExtent {
//        //#warning("FIX ME: requires making buffers transformable so that render passes can be transformable")
//               let extents = pairs.map { $0.crop }
//                return .union(BasicExtentSet(extents))
//        //return .infinite
//    }
//
//    override var isInvisible: Bool {
//        let visible = pairs.filter { $0.color.a > 0 && !$0.crop.size.isEmpty }
//        return visible.isEmpty
//    }
//
//    override var possibleOptimizations: [OptFunc] {
//        return [{ RemoveInvisibleOptimization($0) }]
//    }
//
//}

//extension RenderCrop: Hashable {
//
//    public func transformed(by transform: AffineTransform) -> RenderCrop {
//        return RenderCrop(size: size, transform: self.transform * transform)
//    }
//
//    public func hash(into hasher: inout Hasher) {
//        hasher.combine(size)
//        hasher.combine(transform)
//    }
//
//}

extension CGSize {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(width)
        hasher.combine(height)
    }
    
}

extension AffineTransform: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(cg)
    }
    
}

extension CGAffineTransform: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(a)
        hasher.combine(b)
        hasher.combine(c)
        hasher.combine(d)
        hasher.combine(tx)
        hasher.combine(ty)
    }
    
}

//extension Array where Element == RectNodePair {
//
//    init(_ rects: [CGRect], transform: AffineTransform, color: RenderColor2) {
//        self = rects.map { (rect) -> RectNodePair in
//            let crop = RenderCrop(rect: rect, transform: transform)
//            return RectNodePair(crop, color)
//        }
//    }
//
//    init(_ rect: CGRect, transform: AffineTransform, color: RenderColor2) {
//        self.init([rect], transform: transform, color: color)
//    }
//
//    init(_ pairs: [RectNodePair], color: RenderColor2) {
//        self = pairs.map { (pair) -> RectNodePair in
//            return RectNodePair(pair.crop, color)
//        }
//    }
//}

extension CGSize {
    
    var isEmpty: Bool {
        return width == 0 && height == 0
    }
    
}
