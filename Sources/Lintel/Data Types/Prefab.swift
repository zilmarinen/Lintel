//
//  Prefab.swift
//
//  Created by Zack Brown on 01/10/2024.
//

import Euclid

internal enum Prefab: String,
                      CaseIterable,
                      Identifiable {
    
    case door
    case wall
    case window
    
    public var id: String { rawValue.capitalized }
    
    internal func mesh(_ architectureType: ArchitectureType) throws -> Mesh {
        
        switch self {
            
        case .door: return try door(architectureType)
        case .wall: return try wall(architectureType)
        case .window: return try window(architectureType)
        }
    }
}

extension Prefab {
    
    internal func door(_ architectureType: ArchitectureType) throws -> Mesh {
        
        return Mesh([])
    }
    
    internal func wall(_ architectureType: ArchitectureType) throws -> Mesh {
        
        return Mesh([])
    }
    
    internal func window(_ architectureType: ArchitectureType) throws -> Mesh {
        
        return Mesh([])
    }
}
