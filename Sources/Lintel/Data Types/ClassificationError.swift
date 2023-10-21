//
//  ClassificationError.swift
//
//  Created by Zack Brown on 25/09/2023.
//

import Bivouac
import Foundation

internal enum ClassificationError: Error {
    
    case invalid(tile: Coordinate)
    case invalid(vertex: Coordinate)
    case invalid(halfEdge: Coordinate)
    case invalid(edge: Coordinate)
}
