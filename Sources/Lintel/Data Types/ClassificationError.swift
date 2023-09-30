//
//  ClassificationError.swift
//
//  Created by Zack Brown on 25/09/2023.
//

import Bivouac
import Foundation

internal enum ClassificationError: Error {
    
    case invalid(triangle: Grid.Triangle)
    case invalid(vertex: Grid.Vertex)
    case invalidCorner
    case invalidEdge
}

