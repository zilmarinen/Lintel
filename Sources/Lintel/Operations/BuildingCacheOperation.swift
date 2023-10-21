//
//  BuildingCacheOperation.swift
//
//  Created by Zack Brown on 15/10/2023.
//

import Bivouac
import Euclid
import Foundation
import PeakOperation

public class BuildingCacheOperation: ConcurrentOperation,
                                     ProducesResult {
    
    public var output: Result<BuildingCache, Error> = Result { throw ResultError.noResult }
    
    public override func execute() {
        
        let group = DispatchGroup()
        let queue = DispatchQueue(label: name ?? String(describing: self),
                                  attributes: .concurrent)
        
        var errors: [Error] = []
        var meshes: [String : Mesh] = [:]
        
        let cacheOperation = ArchitectureCacheOperation()
        
        group.enter()
        
        cacheOperation.enqueue(on: internalQueue) { result in
            
            switch result {
                
            case .success(let architectureCache):
                
                for septomino in Grid.Triangle.Septomino.allCases {

                    let classificationOperation = SeptominoClassificationOperation(septomino: septomino)
                    let meshOperation = BuildingMeshOperation(septomino: septomino,
                                                              architectureCache: architectureCache)
                    
                    group.enter()
                    
                    classificationOperation.passesResult(to: meshOperation).enqueue(on: self.internalQueue) { result in
                        
                        queue.async(flags: .barrier) {
                            
                            switch result {
                                
                            case .success(let buildingCache): meshes.merge(buildingCache.meshes) { (current, _) in current }
                            case .failure(let error): errors.append(error)
                            }
                            
                            group.leave()
                        }
                    }
                }
                
            case .failure(let error): errors.append(error)
            }
            
            group.leave()
        }
        
        group.wait()
                
        self.output = errors.isEmpty ? .success(.init(meshes: meshes)) : .failure(MeshError.errors(errors))
        
        finish()
        
        guard let startDate,
              let finishDate else { return }
        
        print("Operation completed in \((finishDate.timeIntervalSince1970 - startDate.timeIntervalSince1970))")
    }
}
