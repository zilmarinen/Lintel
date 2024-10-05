//
//  LintelCacheOperation.swift
//
//  Created by Zack Brown on 15/10/2023.
//

import Bivouac
import Deltille
import Euclid
import Foundation
import PeakOperation

public class LintelCacheOperation: ConcurrentOperation,
                                   ProducesResult {
    
    public var output: Result<[String : Mesh], Error> = Result { throw ResultError.noResult }
    
    public override func execute() {
        
        let group = DispatchGroup()
        
        let prefab = PrefabLoadingOperation()
        
        var meshes: [String : Mesh] = [:]
        
        group.enter()
     
        prefab.enqueue(on: internalQueue) { [weak self] result in
            
            guard let self else { return }
        
            switch result {
                
            case .success(let prefabs):
                
                for architectureType in ArchitectureType.allCases {
                    
                    for septomino in Grid.Triangle.Septomino.allCases {
                        
                        for floor in 0..<3 {
                            
//                            let building = BuildingMeshOperation(architectureType,
//                                                                 septomino,
//                                                                 prefabs,
//                                                                 floor)
//                            
//                            let identifier = "\(architectureType.id)_\(septomino.id)_\(floor)"
//                            
//                            group.enter()
//                            
//                            building.enqueue(on: self.internalQueue) { result in
//                                
//                                switch result {
//                                case .success(let mesh): meshes[identifier] = mesh
//                                    
//                                case .failure(let error):
//                                    
//                                    self.internalQueue.cancelAllOperations()
//                                    
//                                    self.output = .failure(error)
//                                }
//                                
//                                group.leave()
//                            }
                        }
                    }
                }
                
            case .failure(let error): self.output = .failure(error)
            }
            
            group.leave()
        }
        
        group.wait()
        
        finish()
    }
}
