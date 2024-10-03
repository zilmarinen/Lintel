//
//  PrefabLoadingOperation.swift
//
//  Created by Zack Brown on 01/10/2024.
//

import Bivouac
import Euclid
import Foundation
import PeakOperation

public class PrefabLoadingOperation: ConcurrentOperation,
                                     ProducesResult {
    
    public var output: Result<[String : Mesh], Error> = Result { throw ResultError.noResult }
    
    public override func execute() {
     
        do {
            
            var meshes: [String : Mesh] = [:]
            
            for prefab in Prefab.allCases {
                
                for architectureType in ArchitectureType.allCases {
                    
                    meshes[prefab.rawValue] = try prefab.mesh(architectureType)
                }
            }
            
            self.output = .success(meshes)
        }
        catch { self.output = .failure(error) }
        
        finish()
    }
}
