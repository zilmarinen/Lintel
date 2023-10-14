//
//  Door.swift
//
//  Created by Zack Brown on 04/10/2023.
//

import Bivouac
import Euclid
import Foundation

extension ArchitectureType {
    
    enum Door {
        
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
            
            let doorStencil = Path(architectureType.style.stencil(door: cutaway),
                                   color: architectureType.colorPalette.secondary,
                                   isCurved: architectureType.style.curved).extrude()
            
            let doorMesh = Path(architectureType.style.stencil(door: cutaway),
                                color: architectureType.doorColor,
                                isCurved: architectureType.style.curved).extrude(depth: 0.01)
            
            let mesh = edge.subtract(frameStencil).union(frameMesh.subtract(doorStencil)).union(doorMesh)
            
            guard case let .straight(transom) = architectureType.style,
                  transom else { return mesh }
            
            let transomStencil = Path(architectureType.style.stencil(transom: cutaway),
                                      color: architectureType.colorPalette.secondary).extrude()
            
            let transomMesh = Path(architectureType.style.stencil(transom: cutaway),
                                   color: Window.windowColor).extrude(depth: 0.01)
            
            return mesh.subtract(transomStencil).union(transomMesh)
        }
    }
}
