//
//  BuildingMeshOperation.swift
//
//  Created by Zack Brown on 27/09/2023.
//

import Bivouac
import Euclid
import Foundation
import PeakOperation

public class BuildingMeshOperation: ConcurrentOperation,
                                    ProducesResult {
    
    public var output: Result<Mesh, Error> = Result { throw ResultError.noResult }
    
    private let architectureType: ArchitectureType
    private let septomino: Grid.Triangle.Septomino
        
    public init(architectureType: ArchitectureType,
                septomino: Grid.Triangle.Septomino) {
        
        self.architectureType = architectureType
        self.septomino = septomino
    }
    
    public override func execute() {
        
        let group = DispatchGroup()
        
        let operation = SeptominoClassificationOperation(septomino: septomino)
        
        group.enter()
        
        operation.enqueue(on: internalQueue) { result in
            
            switch result {
                
            case .success(let classification):
                
                var polygons: [Euclid.Polygon] = []
                
                let apex = Vector(0.0, 1.0, 0.0)
                let base = Vector(0.0, -0.1, 0.0)
                
                for edge in classification.upper.edges {
                    
                    let triangle = Grid.Triangle(edge.key)
                    
                    let vertices = triangle.vertices(for: .tile).map { Vertex($0 + apex, .up, nil, edge.value.color) }
                    
                    guard let polygon = Polygon(vertices) else { continue }
                    
                    polygons.append(polygon)
                }
                
                for corner in classification.upper.corners {
                    
                    let triangle = Grid.Triangle(corner.key)
                    
                    let vertices = triangle.vertices(for: .tile).map { Vertex($0 + apex, .up, nil, corner.value.color) }
                    
                    guard let polygon = Polygon(vertices) else { continue }
                    
                    polygons.append(polygon)
                }
                
                for footprint in classification.upper.footprint {
                    
                    let triangle = Grid.Triangle(footprint.key)
                    
                    let vertices = triangle.vertices(for: .tile).map { Vertex($0 + apex + base, .up, nil, footprint.value.color) }
                    
                    guard let polygon = Polygon(vertices) else { continue }
                    
                    polygons.append(polygon)
                }
                
                for edge in classification.lower.edges {
                    
                    let triangle = Grid.Triangle(edge.key)
                    
                    let vertices = triangle.vertices(for: .tile).map { Vertex($0, .up, nil, edge.value.color) }
                    
                    guard let polygon = Polygon(vertices) else { continue }
                    
                    polygons.append(polygon)
                }
                
                for corner in classification.lower.corners {
                    
                    let triangle = Grid.Triangle(corner.key)
                    
                    let vertices = triangle.vertices(for: .tile).map { Vertex($0, .up, nil, corner.value.color) }
                    
                    guard let polygon = Polygon(vertices) else { continue }
                    
                    polygons.append(polygon)
                }
                
                for footprint in classification.lower.footprint {
                    
                    let triangle = Grid.Triangle(footprint.key)
                    
                    let vertices = triangle.vertices(for: .tile).map { Vertex($0 + base, .up, nil, footprint.value.color) }
                    
                    guard let polygon = Polygon(vertices) else { continue }
                    
                    polygons.append(polygon)
                }
                
                self.output = .success(Mesh(polygons))
                
            case .failure(let error): fatalError(error.localizedDescription)
            }
            
            group.leave()
        }
        
        group.wait()
     
        finish()
    }
}
