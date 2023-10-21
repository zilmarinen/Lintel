//
//  Wall.swift
//
//  Created by Zack Brown on 02/10/2023.
//

import Bivouac
import Euclid
import Foundation

extension Grid.Triangle {
    
    internal enum Edge: Int,
                        Architecture,
                        CaseIterable,
                        Identifiable {
        
        case four = 4
        case five = 5
        case six = 6
        case seven = 7
        case eight = 8
        case nine = 9
        case ten = 10
        case eleven = 11
        case twleve = 12
        case thirteen = 13
        case fourteen = 14
        case fifteen = 15
        case sixteen = 16
        case seventeen = 17
        case eighteen = 18
        case nineteen = 19
        case twenty = 20
        case twentyOne = 21
        
        var id: String { "Edge [\(rawValue)]" }
        
        internal func mesh(stencil: Grid.Triangle.Stencil,
                           cutaway: Grid.Triangle.Stencil.Cutaway,
                           architectureType: ArchitectureType) throws -> Mesh {
            
            switch self {
                
            case .four, .nine: return try ArchitectureType.Door.mesh(stencil: stencil,
                                                                     cutaway: cutaway,
                                                                     architectureType: architectureType)
            
            case .five: return try ArchitectureType.Archway.mesh(stencil: stencil,
                                                                 cutaway: cutaway,
                                                                 architectureType: architectureType)
            
            case .six, .eight,
                    .ten, .fourteen, .sixteen: return try ArchitectureType.Window.mesh(stencil: stencil,
                                                                                       cutaway: cutaway,
                                                                                       architectureType: architectureType)
            
            default: return try Self.mesh(stencil: stencil,
                                          architectureType: architectureType)
            }
        }
        
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
