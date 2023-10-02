//
//  SeptominoClassificationOperation.swift
//
//  Created by Zack Brown on 25/09/2023.
//

import Bivouac
import Euclid
import Foundation
import PeakOperation

internal class SeptominoClassificationOperation: ConcurrentOperation,
                                                 ProducesResult {
    
    internal var output: Result<Classification, Error> = Result { throw ResultError.noResult }
    
    private let septomino: Grid.Triangle.Septomino
        
    internal init(septomino: Grid.Triangle.Septomino) {
        
        self.septomino = septomino
    }
    
    public override func execute() {
        
        do {
            
            let septominoBlueprintBase = septomino.footprint
            let septominoPerimeterBase = septominoBlueprintBase.perimeter
            
            //
            //  Classify lower floor
            //
            
            let lowerFootprint = try classify(footprint: septominoBlueprintBase)
            let lowerVertices = try classify(vertices: septominoBlueprintBase.vertices)
            
            let lowerCorners = try classifyCorners(perimeter: septominoPerimeterBase,
                                                   footprint: lowerFootprint,
                                                   vertices: lowerVertices)
            
            let lowerEdges = try classifyEdges(perimeter: septominoPerimeterBase,
                                               footprint: lowerFootprint,
                                               vertices: lowerVertices)
            
            let lowerRotation = try classifyRotation(perimeter: septominoPerimeterBase,
                                                     footprint: septominoBlueprintBase,
                                                     vertices: Array(lowerVertices.keys))
            
            //
            //  Remove "end" triangles from lower footprint
            //
            
            let septominoBlueprintApex = lowerFootprint.keys.filter { lowerFootprint[$0] != .one }
            let septominoPerimeterApex = septominoBlueprintApex.perimeter
            
            //
            //  Classify upper floor
            //
            
            let apexFootprint = try classify(footprint: septominoBlueprintApex)
            let apexVertices = try classify(vertices: septominoBlueprintApex.vertices)
            
            //
            //  Combine lower and upper floors
            //
            
            let upperFootprint = try combine(apex: apexFootprint,
                                             base: lowerFootprint)
            
            let upperVertices = try combine(apex: apexVertices,
                                            base: lowerVertices)
            
            //
            //  Classify merged upper floor
            //
            
            let upperCorners = try classifyCorners(perimeter: septominoPerimeterApex,
                                                   footprint: upperFootprint,
                                                   vertices: upperVertices)
            
            let upperEdges = try classifyEdges(perimeter: septominoPerimeterApex,
                                               footprint: upperFootprint,
                                               vertices: upperVertices)
            
            let upperRotation = try classifyRotation(perimeter: septominoPerimeterApex,
                                                     footprint: septominoBlueprintApex,
                                                     vertices: Array(upperVertices.keys))
            
            //
            //  Create layers
            //
            
            let lower = Classification.Layer(footprint: lowerFootprint,
                                             vertices: lowerVertices,
                                             corners: lowerCorners,
                                             edges: lowerEdges,
                                             rotation: lowerRotation)
            
            let upper = Classification.Layer(footprint: upperFootprint,
                                             vertices: upperVertices,
                                             corners: upperCorners,
                                             edges: upperEdges,
                                             rotation: upperRotation)
            
            self.output = .success(Classification(upper: upper,
                                                  lower: lower))
        }
        catch {
            
            self.output = .failure(error)
        }
        
        finish()
    }
}

extension SeptominoClassificationOperation {
    
    internal func combine(apex: [Coordinate : Classification.Triangle],
                          base: [Coordinate : Classification.Triangle]) throws -> [Coordinate : Classification.Triangle] {
     
        try apex.reduce(into: [Coordinate : Classification.Triangle]()) { result, footprint in
            
            guard let lower = base[footprint.key]?.rawValue,
                  let classification = Classification.Triangle(rawValue: footprint.value.rawValue + lower) else { throw ClassificationError.invalid(triangle: Grid.Triangle(footprint.key)) }
            
            result[footprint.key] = classification
        }
    }
    
    internal func combine(apex: [Grid.Vertex : Classification.Vertex],
                          base: [Grid.Vertex : Classification.Vertex]) throws -> [Grid.Vertex : Classification.Vertex] {
     
        try apex.reduce(into: [Grid.Vertex : Classification.Vertex]()) { result, vertex in
            
            guard let lower = base[vertex.key]?.rawValue,
                  let classification = Classification.Vertex(rawValue: vertex.value.rawValue + lower) else { throw ClassificationError.invalid(vertex: vertex.key) }
            
            result[vertex.key] = classification
        }
    }
}

extension SeptominoClassificationOperation {
    
    internal func classify(footprint: [Coordinate]) throws -> [Coordinate : Classification.Triangle] {
        
        try footprint.reduce(into: [Coordinate : Classification.Triangle]()) { result, coordinate in
            
            let triangle = Grid.Triangle(coordinate)
            
            let adjacent = triangle.adjacent
            
            let neighbours = footprint.filter { adjacent.contains($0) }
            
            guard let classification = Classification.Triangle(rawValue: neighbours.count) else { throw ClassificationError.invalid(triangle: triangle) }
            
            result[coordinate] = classification
        }
    }
    
    internal func classify(vertices: [Grid.Vertex]) throws -> [Grid.Vertex : Classification.Vertex] {
        
        try vertices.reduce(into: [Grid.Vertex : Classification.Vertex]()) { result, vertex in
            
            let adjacent = vertex.adjacent
            
            let neighbours = vertices.filter { adjacent.contains($0) }
            
            guard let classification = Classification.Vertex(rawValue: neighbours.count) else { throw ClassificationError.invalid(vertex: vertex) }
            
            result[vertex] = classification
        }
    }
    
    internal func classifyCorners(perimeter: [Coordinate],
                                  footprint: [Coordinate : Classification.Triangle],
                                  vertices: [Grid.Vertex : Classification.Vertex]) throws -> [Coordinate : Classification.Corner] {
        
        try perimeter.reduce(into: [Coordinate : Classification.Corner]()) { result, coordinate in
            
            let triangle = Grid.Triangle(coordinate)
            
            let sharedVertices = triangle.vertices.filter { vertices.keys.contains(Grid.Vertex($0)) }.map { Grid.Vertex($0) }
            
            guard sharedVertices.count == 1 else { return }
            
            guard let vertex = sharedVertices.first,
                  let value = vertices[vertex],
                  let classification = Classification.Corner(rawValue: value.rawValue) else { throw ClassificationError.invalid(corner: triangle) }
            
            result[coordinate] = classification
        }
    }
    
    internal func classifyEdges(perimeter: [Coordinate],
                                footprint: [Coordinate : Classification.Triangle],
                                vertices: [Grid.Vertex : Classification.Vertex]) throws -> [Coordinate : Classification.Edge] {
        
        try perimeter.reduce(into: [Coordinate : Classification.Edge]()) { result, coordinate in
            
            let triangle = Grid.Triangle(coordinate)
            
            let adjacent = triangle.adjacent
            
            let neighbour = footprint.first { adjacent.contains($0.key) }
            let sharedVertices = triangle.vertices.filter { vertices.keys.contains(Grid.Vertex($0)) }.map { Grid.Vertex($0) }
            
            guard sharedVertices.count == 2 else { return }
            
            guard let neighbour,
                  let v0 = sharedVertices.first,
                  let v1 = sharedVertices.last,
                  let lhs = vertices[v0],
                  let rhs = vertices[v1],
                  let classification = Classification.Edge(rawValue: (lhs.rawValue + rhs.rawValue) - neighbour.value.rawValue) else { throw ClassificationError.invalid(edge: triangle) }
            
            result[coordinate] = classification
        }
    }
    
    internal func classifyRotation(perimeter: [Coordinate],
                                   footprint: [Coordinate],
                                   vertices: [Grid.Vertex]) throws -> [Coordinate : Euclid.Rotation] {
        
        try perimeter.reduce(into: [Coordinate : Euclid.Rotation]()) { result, coordinate in
            
            let triangle = Grid.Triangle(coordinate)
            
            let sharedVertices = triangle.vertices.filter { vertices.contains(Grid.Vertex($0)) }.map { Grid.Vertex($0) }
            
            guard let vertex = sharedVertices.first else { throw ClassificationError.invalid(triangle: triangle) }
            
            // corners share a single vertex
            result[coordinate] = sharedVertices.count == 1 ? try classifyCornerRotation(triangle: triangle,
                                                                                        vertex: vertex) :
                                                             try classifyEdgeRotation(triangle: triangle,
                                                                                      footprint: footprint)
        }
    }
    
    internal func classifyCornerRotation(triangle: Grid.Triangle,
                                         vertex: Grid.Vertex) throws -> Euclid.Rotation {
        
        guard let index = triangle.index(of: vertex),
              let rotation = Rotation(axis: .up,
                                      angle: Angle(degrees: triangle.rotation + (Grid.Triangle.stepRotation * Double(-index.rawValue)))) else { throw ClassificationError.invalid(corner: triangle) }
        
        return rotation
    }
    
    internal func classifyEdgeRotation(triangle: Grid.Triangle,
                                       footprint: [Coordinate]) throws -> Euclid.Rotation {
        
        for axis in Grid.Axis.allCases {
            
            if footprint.contains(triangle.adjacent(along: axis)) {
                
                guard let rotation = Rotation(axis: .up,
                                              angle: Angle(degrees: triangle.rotation + (Grid.Triangle.stepRotation * Double(-axis.rawValue - 1)))) else { throw ClassificationError.invalid(corner: triangle) }
                
                return rotation
            }
        }
        
        throw ClassificationError.invalid(edge: triangle)
    }
}
