//
//  BuildingCache.swift
//
//  Created by Zack Brown on 15/10/2023.
//

import Bivouac
import Euclid
import Foundation

public struct BuildingCache {
    
    public static func identifier(for architectureType: ArchitectureType,
                                  septomino: Grid.Triangle.Septomino,
                                  layers: Grid.Triangle.Septomino.Layer) -> String { "\(architectureType.id)_\(septomino.id)_\(layers.id)" }
    
    public let meshes: [String : Mesh]
    
    public func mesh(for architectureType: ArchitectureType,
                     septomino: Grid.Triangle.Septomino,
                     layers: Grid.Triangle.Septomino.Layer) -> Mesh? { meshes[Self.identifier(for: architectureType,
                                                                                              septomino: septomino,
                                                                                              layers: layers)] }
}
