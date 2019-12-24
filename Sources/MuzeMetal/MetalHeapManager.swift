//
//  MetalHeapManager.swift
//  muze
//
//  Created by Greg Fajen on 5/14/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import UIKit
import Metal
import MetalKit
import MuzePrelude

enum HeapType {
    case longTerm
    case render
}

class MetalHeapManager {
    
    static let shared = MetalHeapManager()
    
    let renderHeaps = MetalHeapSeries(type: .render)
    let staticHeaps = MetalHeapSeries(type: .longTerm)
    
    func series(for type: HeapType) -> MetalHeapSeries {
        switch type {
            case .longTerm: return staticHeaps
            case .render: return renderHeaps
        }
    }
    
    #if !targetEnvironment(simulator)
    lazy var textureCache: CVMetalTextureCache = {
        var textureCache: CVMetalTextureCache?
        CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, MetalDevice.device, nil, &textureCache)
        return textureCache!
    }()
    #endif
    
    func makeTexture(for descriptor: MTLTextureDescriptor, type: HeapType) -> MetalTexture? {
//        dispatchPrecondition(condition: .notOnQueue(.main))
        
        let t = series(for: type).makeTexture(for: descriptor)
        checkAllocations()
        return t
    }
    
    func makeDescriptor(with size: CGSize, _ pixelFormat: MTLPixelFormat) -> MTLTextureDescriptor {
        return MTLTextureDescriptor.texture2DDescriptor(pixelFormat: pixelFormat,
                                                        width: Int(size.width),
                                                        height: Int(size.height),
                                                        mipmapped: false)
    }
    
    func makeTexture(_ size: CGSize, _ pixelFormat: MTLPixelFormat, type: HeapType) -> MetalTexture? {
        let descriptor = makeDescriptor(with: size, pixelFormat)
        descriptor.usage = [.renderTarget, .shaderRead, .shaderWrite]
        
        return makeTexture(for: descriptor, type: type)
    }
    
    func checkAllocations() {
//        let used = MemorySize(dynamicHeaps.usedSize)
//        let allocated = MemorySize(dynamicHeaps.allocatedSize)
//        print("    \(used)/\(allocated)")
    }
    
    let queue = DispatchQueue(label: "Heaps", qos: .userInteractive, attributes: [], autoreleaseFrequency: .workItem)
    
    enum GarbageCollectionStrategy {
        case aggressive
    }
    
    func collectGarbage(_ stragegy: GarbageCollectionStrategy, after interval: TimeInterval) {
        #if !targetEnvironment(simulator)
        staticHeaps.queue.asyncAfter(deadline: .now() + interval) {
//            print("BEFORE")
//            for heapSeries in [staticHeaps, renderHeaps] {
//                for heap in heapSeries.heaps {
//                    print("    \(heap) \(heap.usedSize)/\(heap.allocatedSize)")
//                }
//            }
//            print(" ")
            
            self.staticHeaps._defragment(from: [self.renderHeaps], policy: .allocateIfNeeded)
            self.staticHeaps._purgeEmptyHeaps(0)
            
//            print("AFTER")
//            for heapSeries in [staticHeaps, renderHeaps] {
//                for heap in heapSeries.heaps {
//                    print("    \(heap) \(heap.usedSize)/\(heap.allocatedSize)")
//                }
//            }
//            print(" ")
        }
        
//        for heapSeries in [staticHeaps, renderHeaps] {
//            heapSeries.queue.asyncAfter(deadline: .now() + interval) {
//                print("BEFORE")
//                for heap in heapSeries.heaps {
//                    print("    \(heap) \(heap.usedSize)/\(heap.allocatedSize)")
//                }
//                print(" ")
//
//                heapSeries._defragment(with: nil, policy: .allocateIfNeeded)
//                heapSeries._purgeEmptyHeaps()
//
//                print("AFTER")
//                for heap in heapSeries.heaps {
//                    print("    \(heap) \(heap.usedSize)/\(heap.allocatedSize)")
//                }
//                print(" ")
//            }
//        }
        #endif
    }
    
    var usedSize: MemorySize {
        return MemorySize(renderHeaps.usedSize + staticHeaps.usedSize)
    }
    
    var allocatedSize: MemorySize {
        return MemorySize(renderHeaps.allocatedSize + staticHeaps.usedSize)
    }
    
    static let imageLoader = MTKTextureLoader(device: MetalDevice.device)
    var imageLoader: MTKTextureLoader { return MetalHeapManager.imageLoader }
    
    func _allocated(_ size: MemorySize, at time: Date = Date()) -> Int {
        recentAllocations.append((size, time, Thread.callStackSymbols))
        return _allocationVelocity
    }
    
    var recentAllocations: [(MemorySize, Date, [String])] = []
    
    // bytes per second
    var _allocationVelocity: Int {
        var velocity: Int = 0
        
        recentAllocations = recentAllocations.filter { $0.1.timeIntervalSinceNow > -1 }
        
        velocity = recentAllocations.reduce(velocity, { (result, tuple) -> Int in
            let r = result + tuple.0.size
            return r
        })
        
        // leave this here for future debuggin'
//        if velocity > 100000000 {
//            print("allocation velocity: \(MemorySize(velocity))")
//            
//            for (_,_,stack) in recentAllocations {
//                print("\n ----- \n")
//                for line in stack {
//                    print("\t\(line)")
//                }
//            }
//            
//            print(" ")
//        }
        
        return velocity
    }
    
}

extension MetalHeap: CustomDebugStringConvertible {
    
    var pointerString: String {
        let unsafe = Unmanaged.passUnretained(self).toOpaque()
        return "\(unsafe)"
    }
    
    var debugDescription: String {
        return "Heap(\(pointerString))"
    }
    
}
