//
//  FloorPlan.swift
//
//  Created by Zack Brown on 02/10/2024.
//

import Deltille

internal struct FloorPlan {
    
    /// Count number of directly connected triangles within foundations
    internal lazy var footprint: [WeightedVertex] = {
        
        foundation.map {
            
            //sum up count of adjacent triangles
            let weight = $0.adjacent.reduce(into: Int()) { result, coordinate in
                
                result += foundation.contains(Grid.Triangle(coordinate)) ? 1 : 0
            }
            
            return WeightedVertex(coordinate: $0.position,
                                  weight: weight)
        }
    }()
    
    /// Count number of directly connected vertices within foundations
    internal lazy var vertices: [WeightedVertex] = {
        
        let vertices = Set(foundation.flatMap { $0.corners })
        
        return vertices.map {
            
            let adjacent = Grid.Triangle.vertices($0)
            
            //sum up count of adjacent vertices
            let weight = adjacent.reduce(into: Int()) { result, coordinate in
                
                result += vertices.contains(coordinate) ? 1 : 0
            }
            
            return WeightedVertex(coordinate: $0,
                                  weight: weight)
        }
    }()
    
    /// Count number of directly connected vertices and subtract connected edges along perimeter
    internal lazy var perimeter: [WeightedVertex] = {
        
        let coordinates = foundation.map { $0.position }
        
        return coordinates.perimeter.map { coordinate in
            
            let triangle = Grid.Triangle(coordinate)
            let adjacent = triangle.adjacent
            let corners = triangle.corners
            
            let vertices = self.vertices.filter { corners.contains($0.coordinate) }
            let connected = self.footprint.filter { adjacent.contains($0.coordinate) }
            
            //sum up weight of connected vertices
            var weight = vertices.reduce(into: Int()) { $0 += $1.weight }
            
            //optionally, subtract weight of triangle along shared edge
            if let rhs = connected.first {
                
                weight -= rhs.weight
            }
         
            return WeightedVertex(coordinate: coordinate,
                                  weight: weight)
        }
    }()
    
    internal let foundation: [Grid.Triangle]
    
    internal init(foundation: [Grid.Triangle]) {
        
        self.foundation = foundation
        
        perimeter.forEach { print($0.weight) }
    }
}

//extension FloorPlan {
//    
//    internal func merge(_ other: Self) -> Self {
//        
//        
//    }
//}

extension Array where Element == Grid.Triangle {
    
    /// Count number of directly connected triangles within foundations
    internal var weightedFootprint: [WeightedVertex] {
        
        map {
            
            //sum up count of adjacent triangles
            let weight = $0.adjacent.reduce(into: Int()) { result, coordinate in
                
                result += contains(Grid.Triangle(coordinate)) ? 1 : 0
            }
            
            return WeightedVertex(coordinate: $0.position,
                                  weight: weight)
        }
    }
}

extension Array where Element == Grid.Coordinate {
    
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
    
    /// Count number of directly connected vertices and subtract connected edges along perimeter
    internal var weightedPerimeter: [WeightedVertex] {
        
        perimeter.map { coordinate in
            
            let triangle = Grid.Triangle(coordinate)
            let adjacent = triangle.adjacent
            let corners = triangle.corners
            
            let vertices = weightedVertices.filter { corners.contains($0.coordinate) }
            let connected = weightedFootprint.filter { adjacent.contains($0.coordinate) }
            
            //sum up weight of connected vertices
            var weight = vertices.reduce(into: Int()) { $0 += $1.weight }
            
            //optionally, subtract weight of triangle along shared edge
            if let rhs = connected.first {
                
                weight -= rhs.weight
            }
         
            return WeightedVertex(coordinate: coordinate,
                                  weight: weight)
        }
    }
}
