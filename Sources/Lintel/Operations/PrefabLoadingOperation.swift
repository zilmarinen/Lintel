//
//  PrefabLoadingOperation.swift
//
//  Created by Zack Brown on 01/10/2024.
//

import Bivouac
import Deltille
import Euclid
import Foundation
import PeakOperation

internal class PrefabLoadingOperation: ConcurrentOperation,
                                       ProducesResult {
    
    public var output: Result<[String : Mesh], Error> = Result { throw ResultError.noResult }
    
    public override func execute() {
     
        do {
            
            var meshes: [String : Mesh] = [:]
            
            let stencil = Grid.Triangle(.zero).stencil(.tile)
            
            for architectureType in ArchitectureType.allCases {
                
                for prefab in Prefab.allCases {
                    
                    let identifier = PrefabCache.identifier(architectureType,
                                                            prefab)
                    
                    meshes[identifier] = try prefab.mesh(architectureType,
                                                                             stencil)
                }
            }
            
            self.output = .success(meshes)
        }
        catch { self.output = .failure(error) }
        
        finish()
    }
}
