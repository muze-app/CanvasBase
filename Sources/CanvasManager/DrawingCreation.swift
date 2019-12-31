//
//  DrawingCreation.swift
//  muze
//
//  Created by Becca Shapiro on 9/8/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation
import UIKit

typealias DrawingCreation = Drawing & SingleLayerCreation

protocol Drawing: Creation {
    
    var stroke: BrushStroke?            { get }
    var interpolator: DabInterpolator?  { get }
    var realizer: DabRealizer?          { get }
    var texture: MetalTexture?          { get }
    var shouldClear: Bool               { get set }

    func startStroke(dab: AbstractDab, point: CGPoint)
    func append(point: CGPoint)
    func commitStroke()
    func cancelStroke()
    func cleanupStroke()

    func draw(texture: MetalTexture?)
    func transform(for texture: MetalTexture, flip: Bool) -> AffineTransform
}



extension Drawing {
    
  
//    var currentLayer: Layer { return canvasManager.canvas.layers[0] }
//    var currentCanvas: Canvas { return canvasManager.canvas }

    func commitStroke() {
//        transaction?.commit()
//        cleanupStroke()
//        canvasManager.activeNode = nil
        canvasManager.reduceMemory()
    }
    
    func cancelStroke() {
//        transaction?.cancel()
//        cleanupStroke()
//        canvasManager.activeNode = nil
        canvasManager.reduceMemory() 
    }
    
    func append(point: CGPoint) {
        stroke?.append(point: point)
    }

    func transform(for texture: MetalTexture, flip: Bool = false) -> AffineTransform {
        
        let iSize = CGSize(width: texture.width, height: texture.height)
        let iRect = CGRect(origin: .zero, size: iSize)
        let oSize = self.texture!.size
        let oRect = CGRect(origin: .zero, size: oSize)
        let target = oRect.rectThatFills(iSize.aspectRatio)

        return AffineTransform(from: target, to: iRect, flipHorizontally: flip)
    }
}
