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
                
                let stencil = Grid.Triangle.zero.stencil(for: .tile)
                let layers = [classification.lower,
                              classification.upper]
                
                var mesh = Mesh([])
                
                do {
                
                    for index in layers.indices {
                        
                        let elevation = Vector(0.0, ArchitectureType.apex * Double(index), 0.0)
                        let layer = layers[index]
                        
                        for corner in layer.corners {
                            
                            guard let rotation = layer.rotation[corner.key] else { throw MeshError.invalid(corner: corner.value) }
                            
                            mesh = mesh.union(try self.corner(coordinate: corner.key,
                                                              corner: corner.value,
                                                              elevation: elevation,
                                                              rotation: rotation,
                                                              stencil: stencil))
                        }
                        
                        for edge in layer.edges {
                            
                            guard let rotation = layer.rotation[edge.key] else { throw MeshError.invalid(edge: edge.value) }
                            
                            mesh = mesh.union(try self.edge(coordinate: edge.key,
                                                            edge: edge.value,
                                                            elevation: elevation,
                                                            rotation: rotation,
                                                            stencil: stencil))
                        }
                    }
                }
                catch {
                    
                    self.output = .failure(error)
                }
                
                self.output = .success(mesh)
                
            case .failure(let error): fatalError(error.localizedDescription)
            }
            
            group.leave()
        }
        
        group.wait()
     
        finish()
    }
}

extension BuildingMeshOperation {
    
    internal func corner(coordinate: Coordinate,
                         corner: Classification.Corner,
                         elevation: Vector,
                         rotation: Euclid.Rotation,
                         stencil: Grid.Triangle.Stencil) throws -> Mesh {
        
        let mesh = try Grid.Triangle.Corner.mesh(stencil: stencil,
                                                 colorPalette: architectureType.colorPalette)
        
        return mesh.rotated(by: rotation).translated(by: coordinate.convert(to: .tile) + elevation)
    }
    
    internal func edge(coordinate: Coordinate,
                       edge: Classification.Edge,
                       elevation: Vector,
                       rotation: Euclid.Rotation,
                       stencil: Grid.Triangle.Stencil) throws -> Mesh {
        
        let mesh = try Grid.Triangle.Edge.mesh(stencil: stencil,
                                               colorPalette: architectureType.colorPalette)
        
        return mesh.rotated(by: rotation).translated(by: coordinate.convert(to: .tile) + elevation)
    }
}
