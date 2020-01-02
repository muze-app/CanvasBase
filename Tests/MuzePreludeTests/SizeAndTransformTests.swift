//
//  SizeAndTransformTests.swift
//  MuzePreludeTests
//
//  Created by Greg Fajen on 1/1/20.
//

import XCTest
@testable import MuzePrelude

extension CGSize {
    
    static var random: CGSize {
        func rnd() -> CGFloat {
            return CGFloat(arc4random_uniform(4096)).clamp(min: 1, max: 4096)
        }
        
        return .init(width: rnd(), height: rnd())
    }
    
}

class SizeAndTransformTests: XCTestCase {
    
    var oneHundredSizeAndTransforms: [SizeAndTransform] {
        return (1...100).map { _ in
            CGSize.random & CGAffineTransform.random
        }
    }
    
}
