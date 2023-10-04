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
    private let totalLayers: Int
        
    public init(architectureType: ArchitectureType,
                septomino: Grid.Triangle.Septomino,
                totalLayers: Int) {
        
        self.architectureType = architectureType
        self.septomino = septomino
        self.totalLayers = totalLayers
    }
    
    public override func execute() {
        
        let group = DispatchGroup()
        
        let operation = SeptominoClassificationOperation(septomino: septomino,
                                                         totalLayers: totalLayers)
        
        group.enter()
        
        operation.enqueue(on: internalQueue) { result in
            
            switch result {
                
            case .success(let classification):
                
                do {
                    
                    let stencil = Grid.Triangle.zero.stencil(for: .tile)
                    
                    var mesh = Mesh([])
                
                    for layer in classification.layers {
                        
                        let elevation = Vector(0.0, ArchitectureType.apex * Double(layer.index), 0.0)
                        
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

                        for tile in layer.footprint {

                            let triangle = Grid.Triangle(tile.key)

                            guard let rotation = Rotation(axis: .up,
                                                          angle: Angle(degrees: triangle.rotation)) else { throw MeshError.invalid(triangle: tile.value) }

                            mesh = mesh.union(try self.tile(coordinate: tile.key,
                                                            triangle: tile.value,
                                                            elevation: elevation,
                                                            rotation: rotation,
                                                            stencil: stencil))
                        }
                    }
                    
                    self.output = .success(mesh)
                }
                catch {
                    
                    self.output = .failure(error)
                }
                
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
        
        let mesh = try architectureType.mesh(stencil: stencil,
                                             corner: corner)
        
        return mesh.rotated(by: rotation).translated(by: coordinate.convert(to: .tile) + elevation)
    }
    
    internal func edge(coordinate: Coordinate,
                       edge: Classification.Edge,
                       elevation: Vector,
                       rotation: Euclid.Rotation,
                       stencil: Grid.Triangle.Stencil) throws -> Mesh {
        
        let mesh = try architectureType.mesh(stencil: stencil,
                                             edge: edge)
        
        return mesh.rotated(by: rotation).translated(by: coordinate.convert(to: .tile) + elevation)
    }
    
    internal func tile(coordinate: Coordinate,
                       triangle: Classification.Triangle,
                       elevation: Vector,
                       rotation: Euclid.Rotation,
                       stencil: Grid.Triangle.Stencil) throws -> Mesh {
        
        let mesh = try architectureType.mesh(stencil: stencil,
                                             triangle: triangle)
        
        return mesh.rotated(by: rotation).translated(by: coordinate.convert(to: .tile) + elevation)
    }
}
