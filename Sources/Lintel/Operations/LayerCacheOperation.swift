//
//  LayerCacheOperation.swift
//
//  Created by Zack Brown on 16/10/2023.
//

import Bivouac
import Euclid
import Foundation
import PeakOperation

public class LayerCacheOperation: ConcurrentOperation,
                                  ProducesResult {
    
    public var output: Result<BuildingCache, Error> = Result { throw ResultError.noResult }
    
    private let architectureType: ArchitectureType
    private let septomino: Grid.Triangle.Septomino
    private let classification: Classification
    private let architectureCache: ArchitectureCache
        
    public init(architectureType: ArchitectureType,
                septomino: Grid.Triangle.Septomino,
                classification: Classification,
                architectureCache: ArchitectureCache) {
        
        self.architectureType = architectureType
        self.septomino = septomino
        self.classification = classification
        self.architectureCache = architectureCache
        
        super.init()
    }
    
    public override func execute() {
        
        var meshes: [String : Mesh] = [:]
        
        do {

            let stencil = Grid.Triangle.zero.stencil(for: .tile)
            let cutaway = stencil.cutaway
            
            for layer in Grid.Triangle.Septomino.Layer.allCases {
                
                let index = layer.rawValue - 1
                
                let surface = classification.layers[index]
                
                let elevation = Vector(0.0, ArchitectureType.apex * Double(index), 0.0)
                
                var mesh = Mesh([])
                
                for (key, value) in surface.halfEdges {
                    
                    guard let rotation = surface.rotation[key],
                          let cachedMesh = architectureCache.mesh(for: value,
                                                                  architectureType: architectureType) else { throw ArchitectureError.invalid(halfEdge: value) }
                    
                    mesh = mesh.union(cachedMesh.rotated(by: rotation).translated(by: key.convert(to: .tile) + elevation))
                }
                
                for (key, value) in surface.edges {
                    
                    guard let rotation = surface.rotation[key],
                          let cachedMesh = architectureCache.mesh(for: value,
                                                                  architectureType: architectureType) else { throw ArchitectureError.invalid(edge: value) }
                    
                    mesh = mesh.union(cachedMesh.rotated(by: rotation).translated(by: key.convert(to: .tile) + elevation))
                }
                
                for (key, value) in surface.footprint {
                    
                    let triangle = Grid.Triangle(key)
                    
                    guard let rotation = Rotation(axis: .up,
                                                  angle: Angle(degrees: triangle.rotation)) else { throw ArchitectureError.invalid(tile: value) }
                    
                    mesh = mesh.union(try value.mesh(stencil: stencil,
                                                     cutaway: cutaway,
                                                     architectureType: self.architectureType).rotated(by: rotation).translated(by: key.convert(to: .tile) + elevation))
                }
                
                meshes[BuildingCache.identifier(for: architectureType,
                                                septomino: septomino,
                                                layers: layer)] = mesh
            }

            self.output = .success(.init(meshes: meshes))
        }
        catch {

            self.output = .failure(error)
        }

        finish()
    }
}
