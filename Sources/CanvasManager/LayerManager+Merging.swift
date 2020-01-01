//
//  LayerManager+Merging.swift
//  muze
//
//  Created by Greg on 1/24/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import MuzePrelude
import Metal
import MuzeMetal

#if os(iOS)
extension UIImage {
    
    func save(to path: String) {
        let url = URL(fileURLWithPath: path.standardizingPath)
        
        let data = self.pngData()!
        try! data.write(to: url)
        
        print("saved to \(path)")
    }
    
}
#endif

extension MTLTexture {
    
    @available(*, deprecated)
    var immutableCopy: MetalTexture {
        let device = MetalHeapManager.shared
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: pixelFormat,
                                                                  width: width,
                                                                  height: height,
                                                                  mipmapped: false)
        descriptor.usage = [.shaderRead]
        
        let copy = device.makeTexture(for: descriptor, type: .longTerm)!
        
        let commandBuffer = MetalDevice.commandQueue.makeCommandBuffer()
        let encoder = commandBuffer?.makeBlitCommandEncoder()
        
        encoder?.copy(from: self,
                      sourceSlice: 0,
                      sourceLevel: 0,
                      sourceOrigin: .zero,
                      sourceSize: MTLSize(width: width, height: height, depth: 1),
                      to: copy._texture,
                      destinationSlice: 0,
                      destinationLevel: 0,
                      destinationOrigin: .zero)
        
        encoder?.endEncoding()
        
        commandBuffer?.commit()
        
        return copy
    }
    
}

extension MTLOrigin {
    
    static let zero = MTLOrigin(x: 0, y: 0, z: 0)
    
}
