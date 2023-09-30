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
    
    internal struct Classification {
        
        internal enum Triangle: Int {
            
            case one = 1
            case two = 2
            case three = 3
            case four = 4
            case five = 5
            
            internal var color: Color {
                
                switch self {
                    
                case .one: return .blue
                case .two: return .magenta
                case .three: return .gray
                case .four: return .red
                case .five: return .green
                }
            }
        }
        
        internal enum Vertex: Int {
            
            case two = 2
            case three = 3
            case four = 4
            case five = 5
            case six = 6
            case seven = 7
            case eight = 8
            case nine = 9
            case ten = 10
            case twelve = 12
        }
        
        internal enum Corner: Int {
            
            case two = 2
            case three = 3
            case four = 4
            case five = 5
            case six = 6
            case seven = 7
            case eight = 8
            case nine = 9
            
            internal var color: Color {
                
                switch self {
                    
                case .two: return .magenta
                case .three: return .gray
                case .four: return .red
                case .five: return .green
                case .six: return .blue
                case .seven: return .orange
                case .eight: return .yellow
                case .nine: return .cyan
                }
            }
        }
        
        internal enum Edge: Int {
            
            case four = 4
            case five = 5
            case six = 6
            case seven = 7
            case eight = 8
            case nine = 9
            case ten = 10
            case eleven = 11
            case twleve = 12
            case thirteen = 13
            case fourteen = 14
            
            internal var color: Color {
                
                switch self {
                    
                case .four: return .red
                case .five: return .green
                case .six: return .blue
                case .seven: return .orange
                case .eight: return .yellow
                case .nine: return .cyan
                case .ten: return .magenta
                case .eleven: return .gray
                case .twleve: return .white
                case .thirteen: return .black
                case .fourteen: return .init(210)
                }
            }
        }
        
        internal struct Layer {
            
            internal let footprint: [Coordinate : Triangle]
            internal let vertices: [Grid.Vertex : Vertex]
            internal let corners: [Coordinate: Corner]
            internal let edges: [Coordinate : Edge]
        }
        
        internal let upper: Layer
        internal let lower: Layer
    }
    
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
            
            //
            //  Combine layers
            //
            
            let lower = Classification.Layer(footprint: lowerFootprint,
                                             vertices: lowerVertices,
                                             corners: lowerCorners,
                                             edges: lowerEdges)
            
            let upper = Classification.Layer(footprint: upperFootprint,
                                             vertices: upperVertices,
                                             corners: upperCorners,
                                             edges: upperEdges)
            
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
        
        return try perimeter.reduce(into: [Coordinate : Classification.Corner]()) { result, coordinate in
            
            let triangle = Grid.Triangle(coordinate)
            
            let sharedVertices = triangle.vertices.filter { vertices.keys.contains(Grid.Vertex($0)) }.map { Grid.Vertex($0) }
            
            guard sharedVertices.count == 1 else { return }
            
            guard let vertex = sharedVertices.first,
                  let value = vertices[vertex],
                  let classification = Classification.Corner(rawValue: value.rawValue) else { throw ClassificationError.invalidCorner }
            
            result[coordinate] = classification
        }
    }
    
    internal func classifyEdges(perimeter: [Coordinate],
                                footprint: [Coordinate : Classification.Triangle],
                                vertices: [Grid.Vertex : Classification.Vertex]) throws -> [Coordinate : Classification.Edge] {
        
        return try perimeter.reduce(into: [Coordinate : Classification.Edge]()) { result, coordinate in
            
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
                  let classification = Classification.Edge(rawValue: (lhs.rawValue + rhs.rawValue) - neighbour.value.rawValue) else { throw ClassificationError.invalidEdge }
            
            result[coordinate] = classification
        }
    }
}
