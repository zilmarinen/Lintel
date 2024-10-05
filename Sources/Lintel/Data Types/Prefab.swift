//
//  Prefab.swift
//
//  Created by Zack Brown on 01/10/2024.
//

import Deltille
import Euclid

internal enum Prefab: String,
                      CaseIterable,
                      Identifiable {
    
    case door
    case wallFull   //edges with two vertices
    case wallHalf   //edges with a single vertex
    case window
    
    public var id: String { rawValue.capitalized }
    
    internal func mesh(_ architectureType: ArchitectureType,
                       _ stencil: Grid.Triangle.Stencil) throws -> Mesh {
        
        switch self {
            
        case .door: return try Wall.full.mesh(architectureType,
                                              stencil)
        case .wallFull: return try Wall.full.mesh(architectureType,
                                                  stencil)
        case .wallHalf: return try Wall.half.mesh(architectureType,
                                                  stencil)
        case .window: return try Wall.full.mesh(architectureType,
                                                stencil)
        }
    }
}
