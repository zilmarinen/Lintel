//
//  BuildingMeshOperation.swift
//
//  Created by Zack Brown on 15/10/2023.
//

import Bivouac
import Euclid
import Foundation
import PeakOperation

internal class BuildingMeshOperation: ConcurrentOperation,
                                      ConsumesResult,
                                      ProducesResult {
    
    internal var input: Result<Classification, Error> = Result { throw ResultError.noResult }
    internal var output: Result<BuildingCache, Error> = Result { throw ResultError.noResult }
    
    private let septomino: Grid.Triangle.Septomino
    private let architectureCache: ArchitectureCache
    
    public init(septomino: Grid.Triangle.Septomino,
                architectureCache: ArchitectureCache) {
        
        self.septomino = septomino
        self.architectureCache = architectureCache
        
        super.init()
    }
    
    internal override func execute() {
     
        let group = DispatchGroup()
        let queue = DispatchQueue(label: name ?? String(describing: self),
                                  attributes: .concurrent)
        
        var errors: [Error] = []
        var meshes: [String : Mesh] = [:]
        
        do {
            
            let classification = try input.get()
            
            for architectureType in ArchitectureType.allCases {
                
                let cacheOperation = LayerCacheOperation(architectureType: architectureType,
                                                         septomino: septomino,
                                                         classification: classification,
                                                         architectureCache: architectureCache)
                let meshOperation = LayerMeshOperation(architectureType: architectureType,
                                                       septomino: septomino)
             
                group.enter()
                
                cacheOperation.passesResult(to: meshOperation).enqueue(on: internalQueue) { result in
                    
                    queue.async(flags: .barrier) {
                                                
                        switch result {
                            
                        case .success(let buildingCache): meshes.merge(buildingCache.meshes) { (current, _) in current }
                        case .failure(let error): errors.append(error)
                        }
                        
                        group.leave()
                    }
                }
            }
        }
        catch {
            
            errors.append(error)
        }
        
        group.wait()
        
        self.output = errors.isEmpty ? .success(.init(meshes: meshes)) : .failure(MeshError.errors(errors))
        
        finish()
    }
}
