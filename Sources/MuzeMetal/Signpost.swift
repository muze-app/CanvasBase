//
//  Signpost.swift
//  MuzeMetal
//
//  Created by Greg Fajen on 12/23/19.
//

import Foundation

public enum Signpost: UInt32 {
    case renderTimerFired = 0
    case nodeToRender = 1
    case render = 2
    case blit = 3
    
    case renderInstance = 4
    case encoders = 5
    case commandBuffer = 6
    case gpu = 7
    
}

public func _post(_ signpost: Signpost) {
    kdebug_signpost(signpost.rawValue, 0, 0, 0, 0)
}

public func _start(_ signpost: Signpost) {
    kdebug_signpost_start(signpost.rawValue, 0, 0, 0, 0)
}

public func _end(_ signpost: Signpost) {
    kdebug_signpost_end(signpost.rawValue, 0, 0, 0, 0)
}
