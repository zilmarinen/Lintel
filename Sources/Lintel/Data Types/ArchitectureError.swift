//
//  ArchitectureError.swift
//
//  Created by Zack Brown on 16/10/2023.
//

import Bivouac
import Foundation

internal enum ArchitectureError: Error {
    
    case invalid(tile: Grid.Triangle.Tile)
    case invalid(vertex: Grid.Triangle.Vertex)
    case invalid(halfEdge: Grid.Triangle.HalfEdge)
    case invalid(edge: Grid.Triangle.Edge)
    case invalid(layer: Grid.Triangle.Septomino.Layer)
}
