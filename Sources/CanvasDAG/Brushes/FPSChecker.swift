//
//  FPSChecker.swift
//  muze
//
//  Created by Becca Shapiro on 12/9/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation
import UIKit

#if MZE_DEBUG
class FPSChecker {
    
    static let queue = DispatchQueue(label: "FPSChecker")
    var ticks = [Date]()
    
    func tick() {
        FPSChecker.queue.async {
            var t = self.ticks.filter { -$0.timeIntervalSinceNow < 1 }
            t.append(Date())
            self.ticks = t
            
            let fps = t.count
            print("FPS: \(fps)")
        }
//        var values = ticks.values
    }
    
}
#endif
