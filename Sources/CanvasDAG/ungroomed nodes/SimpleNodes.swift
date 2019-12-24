//
//  SimpleNodes.swift
//  muze
//
//  Created by Greg Fajen on 5/17/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import UIKit

//extension InternalImage: Equatable, Hashable {
//
//    static func == (l: InternalImage, r: InternalImage) -> Bool {
//        return l === r
//    }
//
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(identifier)
//    }
//
//}
//extension Image: Equatable, Hashable {
//
//    static func == (l: Image, r: Image) -> Bool {
//        return l.image === r.image
//    }
//
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(identifier)
//    }
//
//}
//
//public struct ImagePayload: NodePayload {
//
//    var image: Image
//    var transform: AffineTransform
//    var colorMatrix: DMatrix3x3
//
//    init(_ a: Image, _ b: AffineTransform = .identity, _ c: DMatrix3x3) {
//        self.image = a
//        self.transform = b
//        self.colorMatrix = c
//    }
//
//    public func transformed(by transform: AffineTransform) -> ImagePayload {
//        return ImagePayload(image, transform * transform, colorMatrix)
//    }
//
//}
//

//// these may get their own file as they get expanded upon
//final class ImageNode: GeneratorNode<ImagePayload> {
//
//    init(_ key: NodeKey = NodeKey(), graph: DAG, payload: ImagePayload? = nil) {
//        super.init(key, graph: graph, payload: payload, nodeType: .image)
//    }
//
//    init(_ key: NodeKey = NodeKey(),
//                     image: Image,
//                     transform: AffineTransform = .identity,
//                     colorMatrix: DMatrix3x3 = .identity,
//                     graph: DAG) {
//        let payload = ImagePayload(image, transform, colorMatrix)
//        super.init(key, graph: graph, payload: payload, nodeType: .image)
//    }
//
//    init(_ key: NodeKey = NodeKey(),
//                     texture: MetalTexture,
//                     transform: AffineTransform = .identity,
//                     colorMatrix: DMatrix3x3 = .identity,
//                     graph: DAG) {
//        let image = Image.with(texture)
//        let payload = ImagePayload(image, transform, colorMatrix)
//        super.init(key, graph: graph, payload: payload, nodeType: .image)
//    }
//
//    override var cost: Int {
//        return 1
//    }
//
////    override var nodeType: NodeType { return .image }
//
//    var image: Image {
//        get { return payload.image }
//        set { payload.image = newValue }
//    }
//
//    var texture: MetalTexture {
//        get { return payload.image.original!.metal.stored! }
//        set { payload.image = .with(newValue) }
//    }
//
//    var transform: AffineTransform {
//        get { return payload.transform }
//        set { payload.transform = newValue }
//    }
//
//    var colorMatrix: DMatrix3x3 {
//        get { return payload.colorMatrix }
//        set { payload.colorMatrix = newValue }
//    }
//
//    var colorMatrixIsIdentity: Bool {
//        return colorMatrix ~ DMatrix3x3.identity
//    }
//
//    override public func renderPayload(for options: RenderOptions) -> RenderPayload? {
////        colorMatrix.a1 = 2
////        colorMatrix.b2 = 2
////        colorMatrix.c3 = 2
////        colorMatrix
//
//        texture.identifier = texture.identifier ?? "Image"
//
//        let t: RenderPayload = .texture(texture)
//        let m: RenderPayload = colorMatrixIsIdentity ? t : .colorMatrix(t, colorMatrix)
//
//        return .cropAndTransform(m, texture.size, transform)
//    }
//
//    override var calculatedRenderExtent: RenderExtent {
//        return .basic(BasicExtent(size: texture.size, transform: transform))
//    }
//
//    override var calculatedUserExtent: UserExtent {
//        return .photo & renderExtent
//    }
//
//}
//

//extension RenderColor2: NodePayload { }
//
//final class SolidColorNode: GNode<RenderColor2> {
//
//    init(_ key: NodeKey = NodeKey(), graph: DAG, payload: RenderColor2? = nil) {
//        super.init(key, graph: graph, payload: payload, nodeType: .solidColor)
//    }
//
////    convenience init(_ uiColor: UIColor) {
////        self.init(.init(uiColor))
////    }
////
////    override var nodeType: NodeType { return .solidColor }
//
//    var color: RenderColor2 {
//        get { return payload }
//        set { payload = newValue }
//    }
//
//    var colorTexture: MetalTexture { return MetalSolidColorTexture(color).texture }
//
//    override public func renderPayload(for options: RenderOptions) -> RenderPayload? {
//        return .texture(colorTexture)
//    }
//
//    override var calculatedRenderExtent: RenderExtent {
//        return .infinite
//    }
//
//    override var calculatedUserExtent: UserExtent {
//        return .brush & .infinite
//    }
//
//}
//
//struct MaskedColorPayload: NodePayload {
//    var a: RenderColor2
//    var b: MaskMode
//    init(_ a: RenderColor2, _ b: MaskMode) { self.a = a; self.b = b }
//}
//
//final class MaskedColorNode: INode<MaskedColorPayload> {
//
//    final var mask: DNode? {
//        get { return input }
//        set { input = newValue }
//    }
//
//    final var mode: MaskMode {
//        get { return payload.b }
//        set { payload.b = mode }
//    }
//
//    final var color: RenderColor2 {
//        get { return payload.a }
//        set { payload.a = newValue }
//    }
//
//    final var colorTexture: MetalTexture { return MetalSolidColorTexture(color).texture }
//
//    final override func renderPayload(for options: RenderOptions) -> RenderPayload? {
//        guard let mask = self.mask?.renderPayload(for: options) else {
//            return nil
//        }
//
//        let colorBuffer = color
//
//        let masked = RenderIntermediate(identifier: "\(self)", options: options, extent: renderExtent)
//        masked << RenderPassDescriptor(identifier: "Mask",
//                                       pipeline: pipeline,
//                                       fragmentBuffers: [colorBuffer],
//                                       inputs: [mask])
//
//        return masked.payload
//    }
//
//    final override var calculatedRenderExtent: RenderExtent {
//        return mask?.renderExtent ?? .infinite
//    }
//
//    final var pipeline: MetalPipeline {
//        switch mode {
//        case .blackIsTransparent: return .maskColorPipeline
//        case .whiteIsTransparent: return .inverseMaskColorPipeline
//        }
//    }
//
//    override var possibleOptimizations: [OptFunc] {
//        return [removeInvisibles]
//    }
//
//    override var isInvisible: Bool {
//        return input?.isInvisible ?? true
//    }
//
//}
//
//extension BasicExtent: NodePayload {
//
//}
//
//final class CropNode: UnaryInputNode<BasicExtent> {
//
//    override var nodeType: NodeType { return .crop }
//
//}
//
//extension One: NodePayload {
//
//}
//
//final class WrapperNode: UnaryInputNode<One> {
//
//    init() {
//        super.init(.one, NodeKey(0), nil)
//    }
//
//    required init(_ payload: One, _ key: Key = Key(0), _ graph: NodeGraph? = nil) {
//        super.init(.one, NodeKey(0), graph)
//    }
//
//    override var nodeType: NodeType {
//        // these nodes shouldn't be copied between graphs
//        fatalError("this fatal error is intentional")
//    }
//
//    override var calculatedRenderExtent: RenderExtent {
//        return input?.renderExtent ?? .nothing
//    }
//
//
//}
//
//extension MetalTexture: Hashable {
//
//    public func hash(into hasher: inout Hasher) {
//        hasher.combine(pointerString)
//    }
//
//}
