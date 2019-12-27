//
//  Matrix3x3.swift
//  muze
//
//  Created by Greg Fajen on 6/14/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation

infix operator •: MultiplicationPrecedence
infix operator ~ : ComparisonPrecedence
infix operator × : MultiplicationPrecedence

public func ~ (l: Double, r: Double!) -> Bool {
    let d = abs(l-r)
    let q = max(min(abs(l), abs(r)), 1)
    let e = d/q
    let r = e < 0.009
    return r
}

public func ~ (l: Vec3<Double>, r: Vec3<Double>) -> Bool {
    return l.a ~ r.a && l.b ~ r.b && l.c ~ r.c
}

public func ~ (l: Matrix3x3<Double>, r: Matrix3x3<Double>) -> Bool {
    return l[0] ~ r[0] && l[1] ~ r[1] && l[2] ~ r[2]
}

public struct Vec3<N: BinaryFloatingPoint>: ExpressibleByArrayLiteral, Hashable {
    
    public var a, b, c: N
    
    public init(arrayLiteral elements: N...) {
        a = elements[0]
        b = elements[1]
        c = elements[2]
    }
    
    public init(_ elements: [N]) {
        a = elements[0]
        b = elements[1]
        c = elements[2]
    }
    
    public func set(_ a: inout N, _ b: inout N, _ c: inout N) {
        a = self.a
        b = self.b
        c = self.c
    }
    
    public var tuple: (N, N, N) {
        return (a, b, c)
    }
    
    public var components: [N] { return [a, b, c] }
    
    public subscript(index: Int) -> N {
        get {
            switch index {
                case 0: return a
                case 1: return b
                case 2: return c
                default: fatalError()
            }
        }
        set {
            switch index {
                case 0: a = newValue
                case 1: b = newValue
                case 2: c = newValue
                default: fatalError()
            }
        }
    }
    
    public static func + (l: Vec3<N>, r: N) -> Vec3<N> {
        var copy = l
        copy.a = r + l.a
        copy.b = r + l.b
        copy.c = r + l.c
        return copy
    }
    
    public static func + (l: Vec3<N>, r: Vec3<N>) -> Vec3<N> {
        var copy = l
        copy.a = r.a + l.a
        copy.b = r.b + l.b
        copy.c = r.c + l.c
        return copy
    }
    
    public static func - (l: Vec3<N>, r: N) -> Vec3<N> {
        var copy = l
        copy.a = l.a - r
        copy.b = l.b - r
        copy.c = l.c - r
        return copy
    }
    
    public static func + (l: N, r: Vec3<N>) -> Vec3<N> {
        var copy = r
        copy.a = l + copy.a
        copy.b = l + copy.b
        copy.c = l + copy.c
        return copy
    }
    
    public static func - (l: N, r: Vec3<N>) -> Vec3<N> {
        var copy = r
        copy.a = l - copy.a
        copy.b = l - copy.b
        copy.c = l - copy.c
        return copy
    }
    
    public static func * (l: N, r: Vec3<N>) -> Vec3<N> {
        var copy = r
        copy.a = l * copy.a
        copy.b = l * copy.b
        copy.c = l * copy.c
        return copy
    }
    
    public static func * (l: Vec3<N>, r: Vec3<N>) -> Vec3<N> {
        var copy = r
        copy.a = l.a * r.a
        copy.b = l.b * r.b
        copy.c = l.c * r.c
        return copy
    }
    
    public static func • (l: Vec3<N>, r: Vec3<N>) -> N {
        let a = l.a * r.a
        let b = l.b * r.b
        let c = l.c * r.c
        return a + b + c
    }
    
    public static func / (l: N, r: Vec3<N>) -> Vec3<N> {
        var copy = r
        copy.a = l / copy.a
        copy.b = l / copy.b
        copy.c = l / copy.c
        return copy
    }
    
    public func map(_ map: (N) -> N) -> Vec3<N> {
        let xs = [a, b, c].map(map)
        return Vec3(xs)
    }
    
}

public struct Matrix3x3<N: BinaryFloatingPoint>: ExpressibleByArrayLiteral, Hashable {
    
    // a,b,c = rows
    // 1,2,3 = cols
    public var a1, a2, a3: N
    public var b1, b2, b3: N
    public var c1, c2, c3: N
    
    public init(diagonal d: N = 1) {
        a1 = d
        b2 = d
        c3 = d
        
        a2 = 0
        a3 = 0
        b1 = 0
        b3 = 0
        c1 = 0
        c2 = 0
    }
    
    public init(diagonal d: [N]) {
        a1 = d[0]
        b2 = d[1]
        c3 = d[2]
        
        a2 = 0
        a3 = 0
        b1 = 0
        b3 = 0
        c1 = 0
        c2 = 0
    }
    
    public init(diagonal d: Vec3<N>) {
        self = .init(diagonal: [d.a, d.b, d.c])
    }
    
    public init(arrayLiteral elements: Vec3<N>...) {
        (a1, a2, a3) = elements[0].tuple
        (b1, b2, b3) = elements[1].tuple
        (c1, c2, c3) = elements[2].tuple
    }
    
    public func col(_ index: Int) -> Vec3<N> {
        switch index {
            case 0: return [a1, b1, c1]
            case 1: return [a2, b2, c2]
            case 2: return [a3, b3, c3]
            default: fatalError()
        }
    }
    
    public func row(_ index: Int) -> Vec3<N> {
        switch index {
            case 0: return [a1, a2, a3]
            case 1: return [b1, b2, b3]
            case 2: return [c1, c2, c3]
            default: fatalError()
        }
    }
    
    public subscript(index: Int) -> Vec3<N> {
        get { return col(index) }
        set {
            switch index {
                case 0: (a1, b1, c1) = newValue.tuple
                case 1: (a2, b2, c2) = newValue.tuple
                case 2: (a3, b3, c3) = newValue.tuple
                default: fatalError()
            }
        }
    }
    
    static func oldMultM(_ l: Matrix3x3<N>, _ r: Matrix3x3<N>) -> Matrix3x3<N> {
        var result = Matrix3x3<N>()
        
        for x in 0...2 {
            for y in 0...2 {
                result[x][y] = l.row(y) • r.col(x)
            }
        }
        
        return result
    }
    
//    #warning("optimize me!")
    static func newMultM(_ l: Matrix3x3<N>, _ r: Matrix3x3<N>) -> Matrix3x3<N> {
        var result = Matrix3x3<N>()
        
        for x in 0...2 {
            for y in 0...2 {
                result[x][y] = l.row(y) • r.col(x)
            }
        }
        
        return result
    }
    
   public static func * (l: Matrix3x3<N>, r: Matrix3x3<N>) -> Matrix3x3<N> {
        return newMultM(l, r)
    }
    
    static func oldMultV(_ l: Matrix3x3<N>, _ r: Vec3<N>) -> Vec3<N> {
        let xs = (0..<3).map { i -> N in
            let row = l.row(i)
            return row[0] * r[0] + row[1] * r[1] + row[2] * r[2]
        }
        
        return Vec3<N>(xs)
    }
    
//    #warning("optimize me!")
    static func newMultV(_ l: Matrix3x3<N>, _ r: Vec3<N>) -> Vec3<N> {
        let xs = (0..<3).map { i -> N in
            let row = l.row(i)
            return row[0] * r[0] + row[1] * r[1] + row[2] * r[2]
        }
        
        return Vec3<N>(xs)
    }
    
    public static func * (l: Matrix3x3<N>, r: Vec3<N>) -> Vec3<N> {
        return newMultV(l, r)
    }
    
    private func det2x2(_ c1: (N, N), _ c2: (N, N)) -> N {
        return c1.0 * c2.1 - c2.0 * c1.1
    }
    
    public var determinant: N {
        let _c1 = (b1, c1)
        let _c2 = (b2, c2)
        let _c3 = (b3, c3)
        
        let r1 = a1 * det2x2(_c2, _c3)
        let r2 = a2 * det2x2(_c1, _c3)
        let r3 = a3 * det2x2(_c1, _c2)
        
        return r1 - r2 + r3
    }
    
    public var inverse: Matrix3x3<N> {
        var result = Matrix3x3<N>()
        let id = 1.0 / determinant
        
        result.a1 =  det2x2((b2, c2), (b3, c3)) * id
        result.b1 = -det2x2((b1, c1), (b3, c3)) * id
        result.c1 =  det2x2((b1, c1), (b2, c2)) * id
        
        result.a2 = -det2x2((a2, c2), (a3, c3)) * id
        result.b2 =  det2x2((a1, c1), (a3, c3)) * id
        result.c2 = -det2x2((a1, c1), (a2, c2)) * id
        
        result.a3 =  det2x2((a2, b2), (a3, b3)) * id
        result.b3 = -det2x2((a1, b1), (a3, b3)) * id
        result.c3 =  det2x2((a1, b1), (a2, b2)) * id
        
        return result
    }

}

public typealias FMatrix3x3 = Matrix3x3<Float32>
public typealias DMatrix3x3 = Matrix3x3<Float64>

public extension DMatrix3x3 {
    
    static let identity: DMatrix3x3 = .init(diagonal: 1)
    
    static let M_CAT02: DMatrix3x3 = [
        [ 0.7328, 0.4296, -0.1624],
        [-0.7036, 1.6975,  0.0061],
        [ 0.0030, 0.0136,  0.9834]
    ]
    
    static let M_HPE: DMatrix3x3 = [
        [ 0.38971, 0.68898, -0.07868],
        [-0.22981, 1.18340,  0.04641],
        [ 0.00000, 0.00000,  1.00000]
    ]
    
    // from XYZ to CAT16
    static let M_CAT16: DMatrix3x3 = [
        [0.401288, 0.650173, -0.051461],
        [-0.250268, 1.204414, 0.045845],
        [-0.002079, 0.048952, 0.953127]
    ]
    
    // from CAT16 to XYZ
    static let M_CAT16_INV: DMatrix3x3 = [
        [1.86206786, -1.01125463, 0.14918677],
        [0.38752654, 0.62144744, -0.00897398],
        [-0.01584150, -0.03412294, 1.04996444]
    ]
    
    // from Display P3 to XYZ
    static let displayP3Inv: DMatrix3x3 = [
        [0.5151, 0.2920, 0.1571],
        [0.2412, 0.6922, 0.0666],
        [-0.0011, 0.0419, 0.7841]
    ]
    
    // from XYZ to Display P3
    static let displayP3: DMatrix3x3 = DMatrix3x3.displayP3Inv.inverse
    
    // from sRGB to XYZ
    static let sRGBInv: DMatrix3x3 = [
        [0.4361, 0.3851, 0.1431],
        [0.2225, 0.7169, 0.0606],
        [0.0139, 0.0971, 0.7141]
    ]
    
    // from XYZ to sRGB
    static let sRGB: DMatrix3x3 = DMatrix3x3.sRGBInv.inverse
    
    static func from(_ sourceIlluminant: Vec3<Double>, to targetIlluminant: Vec3<Double>) -> DMatrix3x3 {
        let sourceIlluminant = .M_CAT16 * sourceIlluminant
        let targetIlluminant = .M_CAT16 * targetIlluminant
        
        let (s1,s2,s3) = sourceIlluminant.tuple
        let (t1,t2,t3) = targetIlluminant.tuple
        return .init(diagonal: [t1/s1, t2/s2, t3/s3])
    }
    
    static let cat16_to_dp3: DMatrix3x3 = .displayP3
                                        * .M_CAT16_INV
                                        * .from(.illuminantE, to: .illuminantD65)
    
    static let sRGB_to_cat16: DMatrix3x3 = /*.sRGBInv * .M_CAT16 **/ DMatrix3x3.from(.illuminantD65, to: .illuminantE) * .M_CAT16 * .sRGBInv
    
}

public typealias DVec3 = Vec3<Double>

public extension DVec3 {
    
    // in XYZ
    static let illuminantE: DVec3 = [1,1,1]
    static let illuminantD50: DVec3 = [0.9642200,1,0.8252100]
    static let illuminantD65: DVec3 = [0.9504700,1,1.0888300]
    
}

extension Matrix3x3: MetalBuffer {
    
    public var length: Int {
        return 36
    }
    
    public var asData: Data {
        //        return ([a1,b1,c1,a2,b2,c2,a3,b3,c3].map { Float($0) }).asData
        return ([a1,a2,a3,b1,b2,b3,c1,c2,c3].map { Float($0) }).asData
    }
    
}
