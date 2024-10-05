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
    
    internal func mesh(_ architectureType: ArchitectureType,
                       _ stencil: Grid.Triangle.Stencil) throws -> Mesh {
        
        let v0: Grid.Triangle.Stencil.Vertex = self == .full ? .v12 : .v0
        
        let color: Color = self == .full ? .red : .blue
        
        let p0 = stencil.vertex(v0)
        let p1 = stencil.v4
        let p2 = p1 + Vector.unitY
        let p3 = p0 + Vector.unitY
        
        guard let polygon = Polygon.face([p0, p1, p2, p3],
                                         color) else { throw GeometryError.invalidPolygon }
        
        return Mesh([polygon])
    }
}
