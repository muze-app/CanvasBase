//
//  DabInterpolator.swift
//  muze
//
//  Created by Greg on 1/3/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import UIKit

// takes dabs from BrushStroke, interpolates them according to spacing
public class DabInterpolator {
    
    public let stroke: BrushStroke
    public let spacing: CGFloat
    
    public init(stroke: BrushStroke) {
        self.stroke = stroke
        self.spacing = stroke.actualSpacing
    }
    
    public var inputs: [AbstractDab] { stroke.dabs }
    
    // MARK: Interpolation
    private var drawnLines: Int = -1
    private var t: CGFloat = 0
    
    public func getDabs() -> [AbstractDab] {
        let count = inputs.count
        
        if count == 0 { return [] }
        
        var output = [AbstractDab]()
        
        if drawnLines == -1 {
            output.append(inputs[0])
            drawnLines = 0
        }
        
        while drawnLines < (count - 1) {
            output.append(contentsOf: getDabs(forLine: drawnLines))
            drawnLines += 1
        }
        
        return output
    }
    
    func getDabs(forLine line: Int) -> [AbstractDab] {
//        print("draw line \(line)")
//        print("   t: \(t)")
        let from = inputs[line]
        let to = inputs[line+1]
        
        let dist = distance(from.point, to.point)
        let oneMinusT = 1 - t
        let first = oneMinusT * spacing
        
        if first > dist {
            t += dist / spacing
//            print("    no points, updated t = \(t)")
            return []
        }
        
        var outputs = [AbstractDab]()
        
        var amount = first / dist
        let inc = spacing / dist
        while amount <= 1 {
            let dab = from.blend(with: to, Float(amount))
            outputs.append(dab)
//            print("    draw dab at \(dab.point)")
            
            amount += inc
        }
        
        t = (1 - (amount - inc)) * dist / spacing
        
//        print("   new t: \(t)")
        return outputs
    }
    
    private func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let x = b.x - a.x
        let y = b.y - a.y
        return sqrt(x * x + y * y)
    }
    
}
