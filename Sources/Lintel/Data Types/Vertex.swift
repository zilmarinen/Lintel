//
//  Vertex.swift
//
//  Created by Zack Brown on 15/10/2023.
//

import Bivouac
import Euclid
import Foundation

extension Grid.Triangle {
    
    internal enum Vertex: Int,
                          Architecture,
                          CaseIterable,
                          Identifiable {
        
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
        
        var id: String { "Vertex [\(rawValue)]" }
        
        internal func mesh(stencil: Grid.Triangle.Stencil,
                           cutaway: Grid.Triangle.Stencil.Cutaway,
                           architectureType: ArchitectureType) throws -> Mesh {
            
            Mesh([])
        }
    }
}
