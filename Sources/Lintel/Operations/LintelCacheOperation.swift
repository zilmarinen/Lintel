//
//  LintelCacheOperation.swift
//
//  Created by Zack Brown on 15/10/2023.
//

import Bivouac
import Deltille
import Dependencies
import Euclid
import Foundation
import PeakOperation

public class LintelCacheOperation: ConcurrentOperation,
                                   ProducesResult {
    
    @Dependency(\.prefabCache) var prefabCache
    
    public var output: Result<[String : Mesh], Error> = Result { throw ResultError.noResult }
    
    public override func execute() {
        
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "LintelCacheOperation",
                                  attributes: .concurrent)
        
        let prefab = PrefabLoadingOperation()
        
        var meshes: [String : Mesh] = [:]
        var errors: [Error] = []
        
        group.enter()
     
        prefab.enqueue(on: internalQueue) { [weak self] result in
            
            guard let self else { return }
        
            switch result {
                
            case .success(let prefabs):
                
                self.prefabCache.merge(prefabs)
                
                for architectureType in ArchitectureType.allCases {
                    
                    for septomino in Grid.Triangle.Septomino.allCases {
                        
                        for floor in 1...3 {
                            
                            let building = BuildingMeshOperation(architectureType,
                                                                 septomino,
                                                                 floor)
                            
                            let identifier = BuildingCache.identifier(architectureType,
                                                                      septomino,
                                                                      floor)
                            
                            group.enter()
                            
                            building.enqueue(on: self.internalQueue) { result in
                                
                                queue.async(flags: .barrier) {
                                    
                                    switch result {
                                    case .success(let mesh): meshes[identifier] = mesh
                                    case .failure(let error): errors.append(error)
                                    }
                                    
                                    group.leave()
                                }
                            }
                        }
                    }
                }
                
            case .failure(let error): self.output = .failure(error)
            }
            
            group.leave()
        }
        
        group.wait()
        
        self.output = errors.isEmpty ? .success(meshes) : .failure(GeometryError.errors(errors))
        
        finish()
    }
}
