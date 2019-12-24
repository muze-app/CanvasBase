//
//  MetalCommandBuffer.swift
//  muze
//
//  Created by Greg on 2/11/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation
import Metal

class MetalCommandBuffer {
    
    typealias HandlerType = (MetalCommandBuffer)->()
    
    let buffer = MetalDevice.commandQueue.makeCommandBuffer()!
    
    func addCompletionHandler(_ handler: @escaping HandlerType) {
        buffer.addCompletedHandler { (buffer) in
            let status = buffer.status
            let duration = buffer.gpuEndTime - buffer.gpuStartTime
            
            if status == .error {
                print("an error occurred")
            } else {
                if duration > 1 {
                    print("SLOW!!!")
                }
                
//                print("buffer completed after \(duration) seconds!")
            }
            
            handler(self)
        }
    }
    
    func commit() {
        buffer.commit()
    }
    
}
