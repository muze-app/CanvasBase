//
//  CanvasObserver.swift
//  muze
//
//  Created by Greg on 1/17/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation

protocol BasicCanvasObserver: AnyObject {
    
    func canvasChanged(_ canvas: One, needsRedraw: Bool)
    
}

protocol CanvasObserver: class {
    
    func canvasSelected(layer: LayerKey, at index: Int)
    func canvasInserted(layer: LayerKey, at index: Int)
    func canvasRemoved(layer: LayerKey,  at index: Int)
    func canvasDidReorderLayers()
    
    func canvasBackground(hidden: Bool)
    
    func canvas(layer: LayerKey, at index: Int, wasHidden hidden: Bool)
    func canvas(layerSublayersChanged: LayerKey, at index: Int)
    
}

