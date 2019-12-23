//
//  FileMappedHeapSet.swift
//  muze
//
//  Created by Greg Fajen on 8/14/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation
import muze_prelude

class FileMappedHeapSet: HeapSet<FileMappedHeap> {
    
    let queue = DispatchQueue(label: "HeapSet")
    
}
