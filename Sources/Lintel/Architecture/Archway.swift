//
//  Archway.swift
//
//  Created by Zack Brown on 06/10/2023.
//

import Bivouac
import Euclid
import Foundation

extension ArchitectureType {
    
    enum Archway {
        
        internal static func mesh(stencil: Grid.Triangle.Stencil,
                                  cutaway: Grid.Triangle.Stencil.Cutaway,
                                  architectureType: ArchitectureType) throws -> Mesh {
            
            let edge = try Grid.Triangle.Edge.mesh(stencil: stencil,
                                                   architectureType: architectureType)
            
            let frameStencil = Path(architectureType.style.stencil(frame: cutaway),
                                    color: architectureType.colorPalette.primary,
                                    isCurved: architectureType.style.curved).extrude()
            
            let frameMesh = Path(architectureType.style.stencil(frame: cutaway),
                                 color: architectureType.colorPalette.secondary,
                                 isCurved: architectureType.style.curved).extrude()
            
            let archwayStencil = Path(architectureType.style.stencil(archway: cutaway),
                                      color: architectureType.colorPalette.secondary,
                                      isCurved: architectureType.style.curved).extrude()
            
            return edge.subtract(frameStencil).union(frameMesh.subtract(archwayStencil))
        }
    }
}
