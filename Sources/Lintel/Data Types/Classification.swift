//
//  Classification.swift
//
//  Created by Zack Brown on 02/10/2023.
//

import Bivouac
import Euclid
import Foundation

internal struct Classification {
    
    internal enum Triangle: Int {
        
        case one = 1
        case two = 2
        case three = 3
        case four = 4
        case five = 5
    }
    
    internal enum Vertex: Int {
        
        case two = 2
        case three = 3
        case four = 4
        case five = 5
        case six = 6
        case seven = 7
        case eight = 8
        case nine = 9
        case ten = 10
        case twelve = 12
    }
    
    internal enum Corner: Int {
        
        case two = 2
        case three = 3
        case four = 4
        case five = 5
        case six = 6
        case seven = 7
        case eight = 8
        case nine = 9
        
        internal var face: ArchitectureType.Face { .corner }
    }
    
    internal enum Edge: Int {
        
        case four = 4
        case five = 5
        case six = 6
        case seven = 7
        case eight = 8
        case nine = 9
        case ten = 10
        case eleven = 11
        case twleve = 12
        case thirteen = 13
        case fourteen = 14
        
        internal var face: ArchitectureType.Face { .wall }
    }
    
    internal struct Layer {
        
        internal let footprint: [Coordinate : Triangle]
        internal let vertices: [Grid.Vertex : Vertex]
        internal let corners: [Coordinate: Corner]
        internal let edges: [Coordinate : Edge]
        internal let rotation: [Coordinate : Euclid.Rotation]
    }
    
    internal let upper: Layer
    internal let lower: Layer
}
