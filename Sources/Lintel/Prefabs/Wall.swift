//
//  Wall.swift
//
//  Created by Zack Brown on 04/10/2024.
//

import Bivouac
import Deltille
import Euclid

internal enum Wall: String,
                    CaseIterable,
                    Identifiable {
    
    case full   //edges with two vertices
    case half   //edges with a single vertex
    
    public var id: String { rawValue.capitalized }
    
    internal var start: Grid.Triangle.Stencil.Vertex { self == .full ? .v11 : .v3 }
    internal var end: Grid.Triangle.Stencil.Vertex { self == .full ? .v8 : .v4 }
    
    internal func mesh(_ architectureType: ArchitectureType,
                       _ stencil: Grid.Triangle.Stencil) throws -> Mesh {
        
        let color: Color = self == .full ? .red : .blue
        
        let p0 = stencil.vertex(start)
        let p1 = stencil.vertex(end)
        let p2 = p1 + Vector.unitY
        let p3 = p0 + Vector.unitY
        
        guard let polygon = Polygon.face([p0, p1, p2, p3],
                                         color) else { throw GeometryError.invalidPolygon }
        
        if self == .full {
            
            guard let face = Polygon.face([stencil.v1 + .unitY, stencil.v2 + .unitY, p3, p2],
                                          .yellow) else { throw GeometryError.invalidPolygon }
            
            return Mesh([polygon, face])
        }
        
        guard let face = Polygon.face([stencil.v0 + .unitY, p3, p2],
                                      .green) else { throw GeometryError.invalidPolygon }
        
        return Mesh([polygon, face])
        
    }
}
