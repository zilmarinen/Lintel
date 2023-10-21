//
//  ArchitectureCacheOperation.swift
//
//  Created by Zack Brown on 15/10/2023.
//

import Bivouac
import Euclid
import Foundation
import PeakOperation

internal class ArchitectureCacheOperation: ConcurrentOperation,
                                           ProducesResult {
    
    internal var output: Result<ArchitectureCache, Error> = Result { throw ResultError.noResult }
    
    internal override func execute() {
     
        let group = DispatchGroup()
        let queue = DispatchQueue(label: name ?? String(describing: self),
                                  attributes: .concurrent)
        
        let stencil = Grid.Triangle.zero.stencil(for: .tile)
        let cutaway = stencil.cutaway
        
        var errors: [Error] = []
        var meshes: [String : Mesh] = [:]
        
        let architectures: [any Architecture] = Grid.Triangle.HalfEdge.allCases +
                                                Grid.Triangle.Edge.allCases +
                                                Grid.Triangle.Tile.allCases +
                                                Grid.Triangle.Vertex.allCases
        
        for architectureType in ArchitectureType.allCases {
            
            for architecture in architectures {
                
                let operation = ArchitectureMeshOperation(architecture: architecture,
                                                          architectureType: architectureType,
                                                          cutaway: cutaway,
                                                          stencil: stencil)
                
                group.enter()
                
                operation.enqueue(on: internalQueue) { result in
                    
                    queue.async(flags: .barrier) {
                        
                        switch result {
                            
                        case .success(let mesh): meshes[ArchitectureCache.identifier(for: architecture,
                                                                                     architectureType: architectureType)] = mesh
                        case .failure(let error): errors.append(error)
                        }
                        
                        group.leave()
                    }
                }
            }
        }
        
        group.wait()
        
        self.output = errors.isEmpty ? .success(.init(meshes: meshes)) : .failure(MeshError.errors(errors))
        
        finish()
    }
}
