//
//  FloorPlan.swift
//
//  Created by Zack Brown on 02/10/2024.
//

import Deltille

internal struct FloorPlan {
    
    internal let foundation: [Grid.Coordinate]
    internal let footprint: [WeightedVertex]
    internal let vertices: [WeightedVertex]
    internal let perimeter: [WeightedVertex]
    internal let rotations: [WeightedVertex]
    
    internal init(foundation: [Grid.Coordinate]) {
        
        self.init(foundation: foundation,
                  footprint: foundation.weightedFootprint,
                  vertices: foundation.vertices.weightedVertices,
                  perimeter: foundation.weightedPerimeter,
                  rotations: foundation.weightedRotations)
    }
    
    internal init(foundation: [Grid.Coordinate],
                  footprint: [WeightedVertex],
                  vertices: [WeightedVertex],
                  perimeter: [WeightedVertex],
                  rotations: [WeightedVertex]) {
        
        self.foundation = foundation
        self.footprint = footprint
        self.vertices = vertices
        self.perimeter = perimeter
        self.rotations = rotations
    }
}

extension FloorPlan {
    
    internal func merge(_ other: Self) -> Self { Self(foundation: foundation,
                                                      footprint: footprint.merge(other.footprint),
                                                      vertices: vertices.merge(other.vertices),
                                                      perimeter: perimeter.merge(other.perimeter),
                                                      rotations: rotations) }
}
