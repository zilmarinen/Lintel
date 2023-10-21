//
//  Architecture.swift
//
//  Created by Zack Brown on 15/10/2023.
//

import Bivouac
import Euclid
import Foundation

internal protocol Architecture: Identifiable {
    
    var id: String { get }
    
    func mesh(stencil: Grid.Triangle.Stencil,
              cutaway: Grid.Triangle.Stencil.Cutaway,
              architectureType: ArchitectureType) throws -> Mesh
}
