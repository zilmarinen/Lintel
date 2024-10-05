//
//  BuildingMeshOperation.swift
//
//  Created by Zack Brown on 15/10/2023.
//

import Bivouac
import Deltille
import Euclid
import Foundation
import PeakOperation

internal class BuildingMeshOperation: ConcurrentOperation,
                                      ProducesResult {
    
    internal var output: Result<Mesh, Error> = Result { throw ResultError.noResult }
    
    internal let architectureType: ArchitectureType
    internal let septomino: Grid.Triangle.Septomino
    internal let prefabs: [Prefab : Mesh]
    internal let floors: Int
    
    internal init(_ architectureType: ArchitectureType,
                  _ septomino: Grid.Triangle.Septomino,
                  _ prefabs: [Prefab : Mesh],
                  _ floors: Int) {
        
        self.architectureType = architectureType
        self.septomino = septomino
        self.prefabs = prefabs
        self.floors = floors
        
        super.init()
        
        self.internalQueue.maxConcurrentOperationCount = 1
    }
    
    public override func execute() {
        
        do {
            
            //
            self.output = .success(Mesh([]))
            //
        }
        catch { self.output = .failure(error) }
        
        finish()
    }
}
