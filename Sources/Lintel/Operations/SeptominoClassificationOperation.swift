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
    private let totalLayers: Int
        
    internal init(septomino: Grid.Triangle.Septomino,
                  totalLayers: Int = 1) {
        
        self.septomino = septomino
        self.totalLayers = min(max(totalLayers, 1), 3)
    }
    
    public override func execute() {
        
        do {
            
            var footprint = septomino.footprint
            
            var layers: [Classification.Layer] = []
            
            for index in 0..<totalLayers {
                
                let perimeter = footprint.perimeter
                
                let layerFootprint = try classify(footprint: footprint)
                let layerVertices = try classify(vertices: footprint.vertices)
                
                let layerCorners = try classifyCorners(perimeter: perimeter,
                                                       footprint: layerFootprint,
                                                       vertices: layerVertices)
                
                let layerEdges = try classifyEdges(perimeter: perimeter,
                                                   footprint: layerFootprint,
                                                   vertices: layerVertices)
                
                let layerRotation = try classifyRotation(perimeter: perimeter,
                                                         footprint: footprint,
                                                         vertices: Array(layerVertices.keys))
                
                let layer = Classification.Layer(index: index,
                                                 footprint: layerFootprint,
                                                 vertices: layerVertices,
                                                 corners: layerCorners,
                                                 edges: layerEdges,
                                                 rotation: layerRotation)
                
                footprint = layerFootprint.keys.filter { layerFootprint[$0] != .one }
                
                guard let foundation = layers.last else {
                    
                    layers.append(layer)
                    
                    continue
                }
                
                let combinedFootprint = try combine(apex: layerFootprint,
                                                    base: foundation.footprint)
                
                let combinedVertices = try combine(apex: layerVertices,
                                                   base: foundation.vertices)
                
                let combinedCorners = try classifyCorners(perimeter: perimeter,
                                                          footprint: combinedFootprint,
                                                          vertices: combinedVertices)
                
                let combinedEdges = try classifyEdges(perimeter: perimeter,
                                                      footprint: combinedFootprint,
                                                      vertices: combinedVertices)
                
                let combinedRotation = try classifyRotation(perimeter: perimeter,
                                                            footprint: Array(combinedFootprint.keys),
                                                            vertices: Array(combinedVertices.keys))
                
                layers.append(Classification.Layer(index: index,
                                                   footprint: combinedFootprint,
                                                   vertices: combinedVertices,
                                                   corners: combinedCorners,
                                                   edges: combinedEdges,
                                                   rotation: combinedRotation))
            }
            
            self.output = .success(Classification(layers: layers))
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
