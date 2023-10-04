//
//  Classification.swift
//
//  Created by Zack Brown on 02/10/2023.
//

import Bivouac
import Euclid
import Foundation

internal struct Classification {
    
    internal struct Layer {
        
        internal let index: Int
        internal let footprint: [Coordinate : Triangle]
        internal let vertices: [Grid.Vertex : Vertex]
        internal let corners: [Coordinate: Corner]
        internal let edges: [Coordinate : Edge]
        internal let rotation: [Coordinate : Euclid.Rotation]
    }
    
    internal let layers: [Layer]
}

extension Classification {
    
    internal enum Triangle: Int {
        
        case zero = 0
        case one = 1
        case two = 2
        case three = 3
        case four = 4
        case five = 5
        case six = 6
        case seven = 7
    }
}

extension Classification {
    
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
        case eleven = 11
        case twelve = 12
        case thirteen = 13
        case fourteen = 14
        case fifteen = 15
        case sixteen = 16
        case seventeen = 17
        case eighteen = 18
    }
}

extension Classification {
 
    internal enum Corner: Int {
        
        case two = 2
        case three = 3
        case four = 4
        case five = 5
        case six = 6
        case seven = 7
        case eight = 8
        case nine = 9
        case ten = 10
        case eleven = 11
        case twelve = 12
        case thirteen = 13
        case fourteen = 14
    }
}

extension Classification {
    
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
        case fifteen = 15
        case sixteen = 16
        case seventeen = 17
        case eighteen = 18
        case nineteen = 19
        case twenty = 20
        case twentyOne = 21
    }
}
