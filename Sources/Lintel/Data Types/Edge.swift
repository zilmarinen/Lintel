//
//  Wall.swift
//
//  Created by Zack Brown on 02/10/2023.
//

import Bivouac
import Euclid
import Foundation

extension Grid.Triangle {
    
    internal enum Edge {
        
        internal static func mesh(stencil: Grid.Triangle.Stencil,
                                  architectureType: ArchitectureType) throws -> Mesh {
            
            let edge = stencil.edge
            let peak = Vector(0.0, ArchitectureType.apex, 0.0)
            let points = [stencil.vertex(for: .v0),
                          stencil.vertex(for: .v1),
                          edge.start,
                          edge.end]
            
            var polygons: [Polygon] = []
            
            let apex = points.map { Euclid.Vertex($0 + peak,
                                                  .up,
                                                  nil,
                                                  architectureType.colorPalette.primary) }
            
            let base = points.map { Euclid.Vertex($0,
                                                  -.up,
                                                  nil,
                                                  architectureType.colorPalette.primary) }
            
            try polygons.glue(Polygon(apex))
            try polygons.glue(Polygon(base.reversed()))
            
            for i in points.indices {
                
                let j = (i + 1) % points.count
                
                let v0 = points[i]
                let v1 = points[j]
                let v2 = v1 + peak
                let v3 = v0 + peak
                
                let face = Polygon.Face([v0,
                                         v1,
                                         v2,
                                         v3],
                                        color: architectureType.colorPalette.primary)
                
                try polygons.glue(face?.polygon)
            }
            
            return Mesh(polygons)
        }
    }
}
