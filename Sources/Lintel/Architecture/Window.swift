//
//  Window.swift
//
//  Created by Zack Brown on 09/10/2023.
//

import Bivouac
import Euclid
import Foundation

extension ArchitectureType {
    
    enum Window {
        
        internal static let windowColor = Color("80B3FF")
        
        internal static func mesh(stencil: Grid.Triangle.Stencil,
                                  cutaway: Grid.Triangle.Stencil.Cutaway,
                                  architectureType: ArchitectureType) throws -> Mesh {
            
            let edge = try Grid.Triangle.Edge.mesh(stencil: stencil,
                                                   architectureType: architectureType)
            
            let frameStencil = Path(architectureType.style.stencil(windowFrame: cutaway),
                                    color: architectureType.colorPalette.secondary,
                                    isCurved: architectureType.style.curved).extrude()
            
            let frameMesh = Path(architectureType.style.stencil(windowFrame: cutaway),
                                 color: architectureType.colorPalette.secondary,
                                 isCurved: architectureType.style.curved).extrude()
            
            let windowStencil = Path(architectureType.style.stencil(window: cutaway),
                                  color: architectureType.colorPalette.secondary,
                                  isCurved: architectureType.style.curved).extrude()
            
            let windowMesh = Path(architectureType.style.stencil(window: cutaway),
                                  color: windowColor,
                                  isCurved: architectureType.style.curved).extrude(depth: 0.01)
            
            let mesh = edge.subtract(frameStencil).union(frameMesh.subtract(windowStencil)).union(windowMesh)
            
            guard case let .straight(transom) = architectureType.style,
                  transom else { return mesh }
            
            let transomStencil = Path(architectureType.style.stencil(transom: cutaway),
                                      color: architectureType.colorPalette.secondary).extrude()
            
            let transomMesh = Path(architectureType.style.stencil(transom: cutaway),
                                   color: windowColor).extrude(depth: 0.01)
            
            return mesh.subtract(transomStencil).union(transomMesh)
        }
    }
}
