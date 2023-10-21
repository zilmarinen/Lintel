//
//  LayerMeshOperation.swift
//
//  Created by Zack Brown on 27/09/2023.
//

import Bivouac
import Euclid
import Foundation
import PeakOperation

public class LayerMeshOperation: ConcurrentOperation,
                                 ConsumesResult,
                                 ProducesResult {
    
    public var input: Result<BuildingCache, Error> = Result { throw ResultError.noResult }
    public var output: Result<BuildingCache, Error> = Result { throw ResultError.noResult }
    
    private let architectureType: ArchitectureType
    private let septomino: Grid.Triangle.Septomino
        
    public init(architectureType: ArchitectureType,
                septomino: Grid.Triangle.Septomino) {
        
        self.architectureType = architectureType
        self.septomino = septomino
        
        super.init()
    }
    
    public override func execute() {
        
        var meshes: [String : Mesh] = [:]
        
        do {
            
            let buildingCache = try input.get()
            var mesh = Mesh([])

            for layer in Grid.Triangle.Septomino.Layer.allCases {
                
                guard let layerMesh = buildingCache.mesh(for: architectureType,
                                                         septomino: septomino,
                                                         layers: layer) else { throw ArchitectureError.invalid(layer: layer) }
             
                mesh = mesh.union(layerMesh)
                
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
