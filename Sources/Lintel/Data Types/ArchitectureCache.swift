//
//  ArchitectureCache.swift
//
//  Created by Zack Brown on 15/10/2023.
//

import Bivouac
import Euclid
import Foundation

public struct ArchitectureCache {
    
    internal static func identifier(for architecture: any Architecture,
                                    architectureType: ArchitectureType) -> String { "\(architectureType.id)_\(architecture.id)" }
    
    internal let meshes: [String : Mesh]
    
    internal func mesh(for edge: Grid.Triangle.Edge,
                       architectureType: ArchitectureType) -> Mesh? { meshes[Self.identifier(for: edge,
                                                                                             architectureType: architectureType)] }
    
    internal func mesh(for halfEdge: Grid.Triangle.HalfEdge,
                       architectureType: ArchitectureType) -> Mesh? { meshes[Self.identifier(for: halfEdge,
                                                                                             architectureType: architectureType)] }
}
