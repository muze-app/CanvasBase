//
//  SimpleNodes.swift
//  muze
//
//  Created by Greg Fajen on 5/17/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

//import UIKit

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

extension One: NodePayload {

}
