//
//  ImageNode.swift
//  CanvasDAG
//
//  Created by Greg Fajen on 12/23/19.
//

import MuzePrelude
import DAG
import MuzeMetal

public class ImageNode: GeneratorNode<ImagePayload> {
    
    override public var cost: Int { 1 }
    
    public init(_ key: NodeKey = NodeKey(), graph: Graph, payload: ImagePayload? = nil) {
        super.init(key, graph: graph, payload: payload, nodeType: .image)
    }
    
//    init(_ key: NodeKey = NodeKey(),
//         image: Image,
//         transform: AffineTransform = .identity,
//         colorMatrix: DMatrix3x3 = .identity,
//         graph: DAG) {
//        let payload = ImagePayload(image, transform, colorMatrix)
//        super.init(key, graph: graph, payload: payload, nodeType: .image)
//    }

    public init(_ key: NodeKey = NodeKey(),
                texture: MetalTexture,
                transform: AffineTransform = .identity,
                colorMatrix: DMatrix3x3 = .identity,
                graph: Graph) {
//        let image = Image.with(texture)
        let payload = ImagePayload(texture, transform, colorMatrix)
        super.init(key, graph: graph, payload: payload, nodeType: .image)
    }
    
//    var image: Image {
//        get { return payload.image }
//        set { payload.image = newValue }
//    }
//    
//    var texture: MetalTexture {
//        get { return payload.image.original!.metal.stored! }
//        set { payload.image = .with(newValue) }
//    }
    
    var texture: MetalTexture {
        get { payload.texture }
        set { payload.texture = newValue }
    }
    
    var transform: AffineTransform {
        get { payload.transform }
        set { payload.transform = newValue }
    }
    
    var colorMatrix: DMatrix3x3 {
        get { payload.colorMatrix }
        set { payload.colorMatrix = newValue }
    }
    
    var colorMatrixIsIdentity: Bool {
        return colorMatrix ~ .identity
    }
    
    override public func renderPayload(for options: RenderOptions) -> RenderPayload? {
        //        colorMatrix.a1 = 2
        //        colorMatrix.b2 = 2
        //        colorMatrix.c3 = 2
        //        colorMatrix

        texture.identifier = texture.identifier ?? "Image"

        let t: RenderPayload = .texture(texture)
        let m: RenderPayload = colorMatrixIsIdentity ? t : .colorMatrix(t, colorMatrix)

        return .cropAndTransform(m, texture.size, transform)
    }

    override public var calculatedRenderExtent: RenderExtent {
        return .basic(BasicExtent(size: texture.size, transform: transform))
    }

    override public var calculatedUserExtent: UserExtent {
        return .photo & renderExtent
    }
    
}

public struct ImagePayload: NodePayload, CustomDebugStringConvertible {
    
    public var texture: MetalTexture
    public var transform: AffineTransform
    public var colorMatrix: DMatrix3x3
    
    public init(_ a: MetalTexture,
                _ b: AffineTransform = .identity,
                _ c: DMatrix3x3 = .identity) {
        self.texture = a
        self.transform = b
        self.colorMatrix = c
    }

    public func transformed(by transform: AffineTransform) -> ImagePayload {
        return ImagePayload(texture, transform * transform, colorMatrix)
    }
    
    public var debugDescription: String {
        let textureString = texture.identifier ?? texture.pointerString
        let transformString = "\(transform.cg.asFloats)"
        return "ImagePayload(\(textureString), \(transformString))"
    }
    
}
