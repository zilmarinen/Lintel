//
//  Array.swift
//  Lintel
//
//  Created by Zack Brown on 05/10/2024.
//

import Deltille

extension Array where Element == WeightedVertex {
    
    internal func merge(_ other: Self) -> Self {
        
        map { vertex in
            
            let rhs = other.first { $0.coordinate == vertex.coordinate }
            
            return WeightedVertex(coordinate: vertex.coordinate,
                                  weight: vertex.weight + (rhs?.weight ?? 0))
        }
    }
}

extension Array where Element == Grid.Coordinate {
    
    /// Find unique vertices for connected triangles
    internal var vertices: [Grid.Coordinate] { Array(Set(flatMap { Grid.Triangle($0).corners })) }
    
    /// Count number of directly connected vertices to classify edges and half edges along perimeter
    internal var weightedEdges: [WeightedVertex] {
     
        let vertices = self.vertices
        
        return perimeter.map {
            
            let triangle = Grid.Triangle($0)
            let corners = triangle.corners
            
            let connectedVertices = vertices.filter { corners.contains($0) }
            
            //half edges / corners share a single vertex    (count == 1)
            //edges share two vertices                      (count == 2)
            return WeightedVertex(coordinate: $0,
                                  weight: connectedVertices.count)
        }
    }
    
    /// Count number of directly connected triangles within foundations
    internal var weightedFootprint: [WeightedVertex] {
        
        map {
            
            let adjacent = Grid.Triangle($0).adjacent
            
            //sum up count of adjacent triangles
            let weight = adjacent.reduce(into: Int()) { result, coordinate in
                
                result += contains(coordinate) ? 1 : 0
            }
            
            return WeightedVertex(coordinate: $0,
                                  weight: weight)
        }
    }
    
    /// Count number of directly connected vertices and subtract connected edges along perimeter
    internal var weightedPerimeter: [WeightedVertex] {
        
        let vertices = self.vertices.weightedVertices
        let footprint = weightedFootprint
        
        return perimeter.map { coordinate in
            
            let triangle = Grid.Triangle(coordinate)
            let adjacent = triangle.adjacent
            let corners = triangle.corners
            
            let connectedVertices = vertices.filter { corners.contains($0.coordinate) }
            let connectedTriangles = footprint.filter { adjacent.contains($0.coordinate) }
            
            //sum up weight of connected vertices
            var weight = connectedVertices.reduce(into: Int()) { $0 += $1.weight }
            
            //optionally, subtract weight of triangle along shared edge
            if let rhs = connectedTriangles.first {
                
                weight -= rhs.weight
            }
            
            return WeightedVertex(coordinate: coordinate,
                                  weight: weight)
        }
    }
    
    /// Determine rotations required for each triangle along the perimeter
    internal var weightedRotations: [WeightedVertex] {
        
        let vertices = self.vertices
        
        return perimeter.map {
            
            let triangle = Grid.Triangle($0)
            let adjacent = triangle.adjacent
            let corners = triangle.corners
            
            let connectedVertices = vertices.filter { corners.contains($0) }
            
            //half edges / corners share a single vertex
            if connectedVertices.count == 1,
               let vertex = connectedVertices.first,
               let index = corners.firstIndex(of: vertex) {
                
                return WeightedVertex(coordinate: $0,
                                      weight: index)
            }
            
            //edges have an adjacent triangle
            let index = adjacent.firstIndex(where: { contains($0) }) ?? 0
            
            return WeightedVertex(coordinate: $0,
                                  weight: index)
        }
    }
    
    /// Count number of directly connected vertices within foundations
    internal var weightedVertices: [WeightedVertex] {
        
        map {
            
            let adjacent = Grid.Triangle.vertices($0)
            
            //sum up count of adjacent vertices
            let weight = adjacent.reduce(into: Int()) { result, coordinate in
                
                result += contains(coordinate) ? 1 : 0
            }
            
            return WeightedVertex(coordinate: $0,
                                  weight: weight)
        }
    }
}
