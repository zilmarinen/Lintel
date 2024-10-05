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
    
    public var output: Result<[Prefab : Mesh], Error> = Result { throw ResultError.noResult }
    
    public override func execute() {
     
        do {
            
            var meshes: [Prefab : Mesh] = [:]
            
            let stencil = Grid.Triangle(.zero).stencil(.tile)
            
            for prefab in Prefab.allCases {
                
                for architectureType in ArchitectureType.allCases {
                    
                    meshes[prefab] = try prefab.mesh(architectureType,
                                                     stencil)
                }
            }
            
            self.output = .success(meshes)
        }
        catch { self.output = .failure(error) }
        
        finish()
    }
}
