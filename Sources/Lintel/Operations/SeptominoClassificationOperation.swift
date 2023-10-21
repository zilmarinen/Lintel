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
        
        super.init()
    }
    
    public override func execute() {
        
        do {
            
            var footprint = septomino.footprint
            
            var layers: [Classification.Layer] = []
            
            for index in Grid.Triangle.Septomino.Layer.allCases.indices {
                
                let perimeter = footprint.perimeter
                
                let layerFootprint = try classify(footprint: footprint)
                let layerVertices = try classify(vertices: footprint.vertices)
                
                let layerHalfEdges = try classifyHalfEdges(perimeter: perimeter,
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
                                                 halfEdges: layerHalfEdges,
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
                
                let combinedHalfEdges = try classifyHalfEdges(perimeter: perimeter,
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
                                                   halfEdges: combinedHalfEdges,
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
    
    internal func combine(apex: [Coordinate : Grid.Triangle.Tile],
                          base: [Coordinate : Grid.Triangle.Tile]) throws -> [Coordinate : Grid.Triangle.Tile] {
     
        try apex.reduce(into: [Coordinate : Grid.Triangle.Tile]()) { result, footprint in
            
            guard let lower = base[footprint.key]?.rawValue,
                  let classification = Grid.Triangle.Tile(rawValue: footprint.value.rawValue + lower) else { throw ClassificationError.invalid(tile: footprint.key) }
            
            result[footprint.key] = classification
        }
    }
    
    internal func combine(apex: [Coordinate : Grid.Triangle.Vertex],
                          base: [Coordinate : Grid.Triangle.Vertex]) throws -> [Coordinate : Grid.Triangle.Vertex] {
     
        try apex.reduce(into: [Coordinate : Grid.Triangle.Vertex]()) { result, vertex in
            
            guard let lower = base[vertex.key]?.rawValue,
                  let classification = Grid.Triangle.Vertex(rawValue: vertex.value.rawValue + lower) else { throw ClassificationError.invalid(vertex: vertex.key) }
            
            result[vertex.key] = classification
        }
    }
}

extension SeptominoClassificationOperation {
    
    internal func classify(footprint: [Coordinate]) throws -> [Coordinate : Grid.Triangle.Tile] {
        
        try footprint.reduce(into: [Coordinate : Grid.Triangle.Tile]()) { result, coordinate in
            
            let triangle = Grid.Triangle(coordinate)
            
            let adjacent = triangle.adjacent
            
            let neighbours = footprint.filter { adjacent.contains($0) }
            
            guard let classification = Grid.Triangle.Tile(rawValue: neighbours.count) else { throw ClassificationError.invalid(tile: triangle.position) }
            
            result[coordinate] = classification
        }
    }
    
    internal func classify(vertices: [Coordinate]) throws -> [Coordinate : Grid.Triangle.Vertex] {
        
        try vertices.reduce(into: [Coordinate : Grid.Triangle.Vertex]()) { result, vertex in
            
            let adjacent = vertex.adjacent
            
            let neighbours = vertices.filter { adjacent.contains($0) }
            
            guard let classification = Grid.Triangle.Vertex(rawValue: neighbours.count) else { throw ClassificationError.invalid(vertex: vertex) }
            
            result[vertex] = classification
        }
    }
    
    internal func classifyHalfEdges(perimeter: [Coordinate],
                                    footprint: [Coordinate : Grid.Triangle.Tile],
                                    vertices: [Coordinate : Grid.Triangle.Vertex]) throws -> [Coordinate : Grid.Triangle.HalfEdge] {
        
        try perimeter.reduce(into: [Coordinate : Grid.Triangle.HalfEdge]()) { result, coordinate in
            
            let triangle = Grid.Triangle(coordinate)
            
            let sharedVertices = triangle.corners.filter { vertices.keys.contains($0) }
            
            guard sharedVertices.count == 1 else { return }
            
            guard let vertex = sharedVertices.first,
                  let value = vertices[vertex],
                  let classification = Grid.Triangle.HalfEdge(rawValue: value.rawValue) else { throw ClassificationError.invalid(halfEdge: triangle.position) }
            
            result[coordinate] = classification
        }
    }
    
    internal func classifyEdges(perimeter: [Coordinate],
                                footprint: [Coordinate : Grid.Triangle.Tile],
                                vertices: [Coordinate : Grid.Triangle.Vertex]) throws -> [Coordinate : Grid.Triangle.Edge] {
        
        try perimeter.reduce(into: [Coordinate : Grid.Triangle.Edge]()) { result, coordinate in
            
            let triangle = Grid.Triangle(coordinate)
            
            let adjacent = triangle.adjacent
            
            let neighbour = footprint.first { adjacent.contains($0.key) }
            let sharedVertices = triangle.corners.filter { vertices.keys.contains($0) }
            
            guard sharedVertices.count == 2 else { return }
            
            guard let neighbour,
                  let v0 = sharedVertices.first,
                  let v1 = sharedVertices.last,
                  let lhs = vertices[v0],
                  let rhs = vertices[v1],
                  let classification = Grid.Triangle.Edge(rawValue: (lhs.rawValue + rhs.rawValue) - neighbour.value.rawValue) else { throw ClassificationError.invalid(edge: triangle.position) }
            
            result[coordinate] = classification
        }
    }
    
    internal func classifyRotation(perimeter: [Coordinate],
                                   footprint: [Coordinate],
                                   vertices: [Coordinate]) throws -> [Coordinate : Euclid.Rotation] {
        
        try perimeter.reduce(into: [Coordinate : Euclid.Rotation]()) { result, coordinate in
            
            let triangle = Grid.Triangle(coordinate)
            
            let sharedVertices = triangle.corners.filter { vertices.contains($0) }
            
            guard let vertex = sharedVertices.first else { throw ClassificationError.invalid(tile: triangle.position) }
            
            // corners share a single vertex
            result[coordinate] = sharedVertices.count == 1 ? try classifyHalfEdgeRotation(triangle: triangle,
                                                                                          vertex: vertex) :
                                                             try classifyEdgeRotation(triangle: triangle,
                                                                                      footprint: footprint)
        }
    }
    
    internal func classifyHalfEdgeRotation(triangle: Grid.Triangle,
                                           vertex: Coordinate) throws -> Euclid.Rotation {
        
        guard let index = triangle.index(of: vertex),
              let rotation = Rotation(axis: .up,
                                      angle: Angle(degrees: triangle.rotation + (Grid.Triangle.stepRotation * Double(-index.rawValue)))) else { throw ClassificationError.invalid(halfEdge: triangle.position) }
        
        return rotation
    }
    
    internal func classifyEdgeRotation(triangle: Grid.Triangle,
                                       footprint: [Coordinate]) throws -> Euclid.Rotation {
        
        for axis in Grid.Axis.allCases {
            
            if footprint.contains(triangle.adjacent(along: axis)) {
                
                guard let rotation = Rotation(axis: .up,
                                              angle: Angle(degrees: triangle.rotation + (Grid.Triangle.stepRotation * Double(-axis.rawValue - 1)))) else { throw ClassificationError.invalid(halfEdge: triangle.position) }
                
                return rotation
            }
        }
        
        throw ClassificationError.invalid(edge: triangle.position)
    }
}
