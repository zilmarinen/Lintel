//
//  Tile.swift
//
//  Created by Zack Brown on 02/10/2023.
//

import Bivouac
import Euclid
import Foundation

extension Grid.Triangle {
    
    internal enum Tile: Int,
                        Architecture,
                        CaseIterable,
                        Identifiable {
        
        case zero = 0
        case one = 1
        case two = 2
        case three = 3
        case four = 4
        case five = 5
        case six = 6
        case seven = 7
        
        var id: String { "Tile [\(rawValue)]" }
        
        internal func mesh(stencil: Grid.Triangle.Stencil,
                  cutaway: Grid.Triangle.Stencil.Cutaway,
                  architectureType: ArchitectureType) throws -> Mesh {
            
            switch self {
                
            default: return try Self.mesh(stencil: stencil,
                                          color: architectureType.colorPalette.primary)
            }
        }
        
        internal static let vertices: [Stencil.Vertex] = [.v0,
                                                          .v1,
                                                          .v2]
        
        internal static func mesh(stencil: Grid.Triangle.Stencil,
                                  color: Color) throws -> Mesh {
            
            let peak = Vector(0.0, ArchitectureType.apex, 0.0)
            let points = vertices.map { stencil.vertex(for: $0) }
                    
            var polygons: [Polygon] = []
            
            let apex = points.map { Euclid.Vertex($0 + peak,
                                                  .up,
                                                  nil,
                                                  color) }
            
            let base = points.map { Euclid.Vertex($0,
                                                  -.up,
                                                  nil,
                                                  color) }
            
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
                                        color: color)
                
                try polygons.glue(face?.polygon)
            }
            
            return Mesh(polygons)
        }
    }
}
