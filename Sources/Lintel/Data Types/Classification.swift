//
//  Classification.swift
//
//  Created by Zack Brown on 02/10/2023.
//

import Bivouac
import Euclid
import Foundation

public struct Classification {
    
    internal struct Layer {
        
        internal let index: Int
        internal let footprint: [Coordinate : Grid.Triangle.Tile]
        internal let vertices: [Coordinate : Grid.Triangle.Vertex]
        internal let halfEdges: [Coordinate : Grid.Triangle.HalfEdge]
        internal let edges: [Coordinate : Grid.Triangle.Edge]
        internal let rotation: [Coordinate : Euclid.Rotation]
    }
    
    internal let layers: [Layer]
}
