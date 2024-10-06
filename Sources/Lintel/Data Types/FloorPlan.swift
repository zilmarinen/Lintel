//
//  FloorPlan.swift
//
//  Created by Zack Brown on 02/10/2024.
//

import Deltille
import Euclid

internal struct FloorPlan {
    
    enum EdgeType: String,
                   Identifiable {
        
        case edge
        case halfEdge = "Half Edge"
        
        public var id: String { rawValue.capitalized }
    }
    
    internal let foundation: [Grid.Coordinate]
    internal let footprint: [WeightedVertex]
    internal let vertices: [WeightedVertex]
    internal let perimeter: [WeightedVertex]
    internal let rotations: [WeightedVertex]
    internal let edges: [WeightedVertex]
    
    internal init(foundation: [Grid.Coordinate]) {
        
        self.init(foundation: foundation,
                  footprint: foundation.weightedFootprint,
                  vertices: foundation.vertices.weightedVertices,
                  perimeter: foundation.weightedPerimeter,
                  rotations: foundation.weightedRotations,
                  edges: foundation.weightedEdges)
    }
    
    internal init(foundation: [Grid.Coordinate],
                  footprint: [WeightedVertex],
                  vertices: [WeightedVertex],
                  perimeter: [WeightedVertex],
                  rotations: [WeightedVertex],
                  edges: [WeightedVertex]) {
        
        self.foundation = foundation
        self.footprint = footprint
        self.vertices = vertices
        self.perimeter = perimeter
        self.rotations = rotations
        self.edges = edges
    }
}

extension FloorPlan {
    
    internal func collapse() -> Self {
        
        let foundation = footprint.compactMap { $0.weight > 1 ? $0 : nil }
        
        return Self(foundation: foundation.map { $0.coordinate })
    }
    
    internal func merge(_ other: Self) -> Self { Self(foundation: foundation,
                                                      footprint: footprint.merge(other.footprint),
                                                      vertices: vertices.merge(other.vertices),
                                                      perimeter: perimeter.merge(other.perimeter),
                                                      rotations: rotations,
                                                      edges: edges) }
    
    internal func edge(_ coordinate: Grid.Coordinate) -> EdgeType? {
        
        let edge = edges.first { $0.coordinate == coordinate}
        
        guard let edge else { return nil }
        
        return edge.weight == 1 ? .halfEdge : .edge
    }
    
    internal func rotation(_ coordinate: Grid.Coordinate) -> Rotation {
        
        let rotation = rotations.first { $0.coordinate == coordinate}
        
        guard let rotation else { return .identity }
        
        let triangle = Grid.Triangle(coordinate)
        
        let angle = Angle(radians: triangle.rotation)
        
        return Rotation(axis: .y,
                        angle: angle)
    }
}
