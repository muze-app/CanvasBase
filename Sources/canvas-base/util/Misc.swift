//
//  File.swift
//  
//
//  Created by Greg Fajen on 12/19/19.
//

import Foundation

extension Range where Element == Int {
    
    var length: Int {
        return upperBound - lowerBound
    }
    
}
