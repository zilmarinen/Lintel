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
                                  architectureType: ArchitectureType) throws -> Mesh {
            
            let edge = try Grid.Triangle.Edge.mesh(stencil: stencil,
                                                   color: architectureType.colorPalette.secondary)
         
            switch architectureType {
                
            case .bernina: return try Bernina.Door.mesh(edge: edge,
                                                        stencil: stencil,
                                                        colorPalette: architectureType.colorPalette)
            
            default: return edge
            }
        }
    }
}

extension ArchitectureType.Bernina {
    
    enum Door {
        
        internal static func mesh(edge: Mesh,
                                  stencil: Grid.Triangle.Stencil,
                                  colorPalette: ColorPalette) throws -> Mesh {
            
            let lhs = stencil.vertex(for: .v4)
            let rhs = stencil.vertex(for: .v12)
            let center = lhs.lerp(rhs, 0.5)
            let lintel = Vector(0.0, ArchitectureType.lintel, 0.0)
            
            let v0 = center.lerp(lhs, 0.5)
            let v1 = center.lerp(rhs, 0.5)
            let v2 = v1 + lintel
            let v3 = v0 + lintel
            
            let face = Polygon.Face([v0, v1, v2, v3],
                                    color: colorPalette.secondary)
            
            guard let polygon = face?.polygon else { throw MeshError.invalid(edge: .four) }
            
            let path = Path(polygon)
            
            let mesh = Mesh.extrude([path], depth: 0.1)
            
            return edge.union(mesh)
        }
    }
}
