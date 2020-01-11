//
//  CanvasOverlayNode.swift
//  CanvasBase
//
//  Created by Greg Fajen on 1/10/20.
//

import MuzeMetal

public struct CanvasOverlayPayload: NodePayload {

    public var canvasSize: CGSize
    public var transformFromCanvasToView: AffineTransform

    public var scale: Float = 1
    public var cornerRadius: Float = 20

    public init(_ a: CGSize, _ b: AffineTransform) {
        self.canvasSize = a
        self.transformFromCanvasToView = b
    }

    public func transformed(by transform: AffineTransform) -> CanvasOverlayPayload {
        return CanvasOverlayPayload(canvasSize, transformFromCanvasToView * transform)
    }

}

public class CanvasOverlayNode: GeneratorNode<CanvasOverlayPayload> {
    
    public init(_ key: NodeKey = NodeKey(),
                graph: Graph,
                payload: CanvasOverlayPayload? = nil) {
        super.init(key,
                   graph: graph,
                   payload: payload,
                   nodeType: .canvasOverlay)
    }

    public var canvasSize: CGSize {
        get { return payload.canvasSize }
        set { payload.canvasSize = newValue }
    }

    public var transformFromCanvasToView: AffineTransform {
        get { return payload.transformFromCanvasToView }
        set { payload.transformFromCanvasToView = newValue }
    }
    
    public var scale: Float {
        get { payload.scale }
        set { payload.scale = newValue }
    }
    
    public var cornerRadius: Float {
        get { payload.cornerRadius }
        set { payload.cornerRadius = newValue }
    }

    static let transformFromViewToDisplay = AffineTransform.scaling(UIScreen.main.nativeScale)
//    static let grayColor = RenderColor2(UIColor(white: 0, alpha: 1.0))
////    static let grayColor = RenderColor2(UIColor(white: 67/255, alpha: 1.0))
//    static let cropColor = RenderColor2(UIColor(white: 0.00, alpha: 0.7))
//    static let lineColorUnblended = RenderColor2(UIColor(white: 0.135, alpha: 0.5))

    var transformFromViewToDisplay: AffineTransform { return CanvasOverlayNode.transformFromViewToDisplay }
//    var grayColor: RenderColor2 { return CanvasOverlayNode.grayColor }
//    var cropColor: RenderColor2 { return CanvasOverlayNode.cropColor }
//    var lineColorUnblended: RenderColor2 { return CanvasOverlayNode.lineColorUnblended }

    func nativeRound(_ x: CGFloat) -> CGFloat {
        let s = UIScreen.main.nativeScale
        var x = x

        x /= s
        x -= 0.5

        x = round(x)

        x += 0.5
        x *= s

        return x
    }

//    func verticalLine(at x: CGFloat, thickness: CGFloat, minY: CGFloat, maxY: CGFloat) -> CGRect {
//        let x = nativeRound(x)
//
//        let half = thickness/2
//        return CGRect(left: x-half, top: minY, right: x+half, bottom: maxY)
//    }
//
//    func horizontalLine(at y: CGFloat, thickness: CGFloat, minX: CGFloat, maxX: CGFloat) -> CGRect {
//        let y = nativeRound(y)
//
//        let half = thickness/2
//        return CGRect(left: minX, top: y-half, right: maxX, bottom: y+half)
//    }
//
//    var cropHandles: [ShadedLine] {
//        if cropMode == 0 { return [] }
//
//        let scale = transformFromCanvasToView.inverse.decomposition.scale.x
//        let out = scale * 2.5 * CGFloat(cropMode)
//        let up = scale * 15
//
//        let bounds = .zero & canvasSize
//
//        let c1 = CGRect(left: bounds.minX-out, top: bounds.minY-out, right: bounds.minX+up, bottom: bounds.minY+up)
//        let c2 = CGRect(left: bounds.maxX+out, top: bounds.minY-out, right: bounds.maxX-up, bottom: bounds.minY+up)
//        let c3 = CGRect(left: bounds.minX-out, top: bounds.maxY+out, right: bounds.minX+up, bottom: bounds.maxY-up)
//        let c4 = CGRect(left: bounds.maxX+out, top: bounds.maxY+out, right: bounds.maxX-up, bottom: bounds.maxY-up)
//
//        let lines = [c1,c2,c3,c4].flatMap { $0.shadedLines }
//        return lines.map { $0.applying(transformFromCanvasToView * transformFromViewToDisplay) }
//    }
//
//    var handleColors: [RenderColor2] {
//        if cropMode == 0 { return [] }
//        return [.white,.white,.white,.white]
//    }
//
//    var cropGrid: [ShadedLine] {
//        if cropMode == 0 { return [] }
//
//        let scale = transformFromCanvasToView.inverse.decomposition.scale.x
//
//        let bounds = .zero & canvasSize
//
//        let lineThickness = scale * 0.25 * CGFloat(cropMode)
//        let l1 = verticalLine(at: bounds.width * 1 / 3, thickness: lineThickness, minY: bounds.minY, maxY: bounds.maxY)
//        let l2 = verticalLine(at: bounds.width * 2 / 3, thickness: lineThickness, minY: bounds.minY, maxY: bounds.maxY)
//        let l3 = horizontalLine(at: bounds.height * 1 / 3, thickness: lineThickness, minX: bounds.minX, maxX: bounds.maxX)
//        let l4 = horizontalLine(at: bounds.height * 2 / 3, thickness: lineThickness, minX: bounds.minX, maxX: bounds.maxX)
//
//        let lines = [l1,l2,l3,l4].flatMap { $0.shadedLines }
//        return lines.map { $0.applying(transformFromCanvasToView * transformFromViewToDisplay) }
//    }
//
//    var gridColors: [RenderColor2] {
//        if cropMode == 0 { return [] }
//        return [.white,.white,.white,.white]
//    }
//
//    override public func renderPayload(for options: RenderOptions) -> RenderPayload? {
//        let result = RenderIntermediate(identifier: "Canvas Overlay", options: options, extent: renderExtent)
//
//        let bounds = .zero & canvasSize
//
//        let window0 = bounds.shadedLines.map { $0.applying(transformFromCanvasToView) }
//        let window1 = window0.map { $0.applying(transformFromViewToDisplay) }
//        let window2 = window0.map { $0.parallelLine(shifted: -3/4).applying(transformFromViewToDisplay) }
//
//        let lines = cropHandles + window2 + window1 + cropGrid
//
//        let gray = self.grayColor
//        let crop = self.cropColor
//
//        let mainColor = gray.blend(with: crop, cropMode)
//        let lineColor = self.lineColorUnblended.blend(with: .white, cropMode)
//        let clearColor = RenderColor2.clear
//
//        let colors: [RenderColor2] = [mainColor] + handleColors + [lineColor, clearColor] + gridColors
//        let count = UInt16(colors.count-1)
//
//        result << RenderPassDescriptor(identifier: "Canvas Overlay",
//                                       pipeline: .canvasOverlayPipeline,
//                                       fragmentBuffers: [lines, colors, count])
//
//        return result.payload
//    }

    override public func renderPayload(for options: RenderOptions) -> RenderPayload? {
        let result = RenderIntermediate(identifier: "Canvas Overlay", options: options, extent: renderExtent)
        
        let transform = transformFromCanvasToView.inverse
        let params: [Float] = [Float(canvasSize.width), Float(canvasSize.height), scale, cornerRadius]

        result << RenderPassDescriptor(identifier: "Canvas Overlay",
                                       pipeline: .canvasOverlayPipeline,
                                       fragmentBuffers: [transform, params])

        return result.payload
    }

    override public var calculatedRenderExtent: RenderExtent {
        return .basic(.init(size: UIScreen.main.nativeBounds.size))
    }

}

//extension CanvasOverlayPayload: Animatable {
//
//    func blend(with other: CanvasOverlayPayload, _ t: Float) -> CanvasOverlayPayload {
//        var c = self
//        c.canvasSize = self.canvasSize.blend(with: other.canvasSize, t)
//        c.transformFromCanvasToView = self.transformFromCanvasToView.blend(with: other.transformFromCanvasToView, t)
//        c.cropMode = self.cropMode.blend(with: other.cropMode, t)
//        return c
//    }
//
//}

extension UInt16: MetalBuffer {
 
    public func transformed(by transform: AffineTransform) -> UInt16 {
        self
    }
    
    public var length: Int { return 2 }
    public var asData: Data { return Data(from: self) }

}
