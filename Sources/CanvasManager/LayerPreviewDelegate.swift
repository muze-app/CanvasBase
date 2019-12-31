//
//  LayerPreviewDelegate.swift
//  muze
//
//  Created by Greg on 1/18/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import MuzePrelude

public protocol LayerPreviewDelegate: class {
    
    func layer(updated: LayerPreview)
    
    var wantsUpdate: Bool { get }
    
}
