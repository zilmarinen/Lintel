//
//  ArchitectureMeshOperation.swift
//
//  Created by Zack Brown on 15/10/2023.
//

import Bivouac
import Euclid
import Foundation
import PeakOperation

internal class ArchitectureMeshOperation: ConcurrentOperation,
                                          ProducesResult {
    
    internal var output: Result<Mesh, Error> = Result { throw ResultError.noResult }
    
    private let architecture: any Architecture
    private let architectureType: ArchitectureType
    private let cutaway: Grid.Triangle.Stencil.Cutaway
    private let stencil: Grid.Triangle.Stencil
    
    internal init(architecture: any Architecture,
                  architectureType: ArchitectureType,
                  cutaway: Grid.Triangle.Stencil.Cutaway,
                  stencil: Grid.Triangle.Stencil) {
        
        self.architecture = architecture
        self.architectureType = architectureType
        self.cutaway = cutaway
        self.stencil = stencil
        
        super.init()
    }
    
    public override func execute() {
           
           do {
               
               let mesh = try architecture.mesh(stencil: stencil,
                                                cutaway: cutaway,
                                                architectureType: architectureType)
               
               output = .success(mesh)
           }
           catch {
               
               output = .failure(error)
           }
           
           finish()
       }
}
