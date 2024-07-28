//
//  BuildingMeshOperation.swift
//
//  Created by Zack Brown on 15/10/2023.
//

import Bivouac
import Euclid
import Foundation
import PeakOperation

public class BuildingMeshOperation: ConcurrentOperation,
                                    ProducesResult {
    
    public var output: Result<Mesh, Error> = Result { throw ResultError.noResult }
    
    public override func execute() {
        
        //
        
        finish()
    }
}
