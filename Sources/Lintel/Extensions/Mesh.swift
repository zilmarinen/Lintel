//
//  Mesh.swift
//
//  Created by Zack Brown on 24/12/2025.
//

import Deltille
import Euclid
import Lattice

extension Mesh {
    
    public static func building(_ septomino: Triangle.Septomino) -> Self {
        
        let footprint = Triangle.Footprint(.zero,
                                           septomino.coordinates)
        
        let tiles = footprint.tiles
        let perimeter = footprint.perimeter
        let vertices = footprint.vertices
        let scale = Triangle.Scale.tile
        let size = 0.2
        let apex = Vector(0.0, scale.edgeLength, 0.0)
        
        var polygons: [Polygon] = []
        
        for tile in perimeter {
            
            let corners = tile.vertices.filter { vertices.contains($0) }
            
            let wedge = Wedge(tile,
                              corners)
            
            switch wedge {
                        
            case .corner(_,
                         let corner):
                
                let corners = corner.edges.flatMap {
                    
                    $0.corners.filter { $0 != corner }
                }
                
                guard let lhs = corners.first,
                      let rhs = corners.last else { break }
                
                let v0 = tile.vertex(lhs).position(scale)
                let v1 = tile.vertex(rhs).position(scale)
                let v2 = tile.vertex(corner).position(scale)
                let v3 = v2.lerp(v0, size)
                let v4 = v2.lerp(v1, size)
                let v5 = v3 + apex
                let v6 = v4 + apex
                
                let p0 = [v4 + apex, v3 + apex, v2 + apex].path(.red)
                let p1 = [v5, v6, v4, v3].path(.blue)
                
                guard let peak = Polygon(shape: p0),
                      let edge = Polygon(shape: p1) else { break }
                
                polygons.append(contentsOf: [peak,
                                             edge])
                
            case .edge(_,
                       let edge):
                
                let corners = tile.corners.filter {
                    
                    !edge.corners.contains($0)
                }
                
                guard let corner = corners.first,
                      let lhs = edge.corners.first,
                      let rhs = edge.corners.last  else { break }
                
                let v0 = tile.vertex(lhs).position(scale)
                let v1 = tile.vertex(rhs).position(scale)
                let v2 = tile.vertex(corner).position(scale)
                let v3 = v0.lerp(v2, size)
                let v4 = v1.lerp(v2, size)
                let v5 = v3 + apex
                let v6 = v4 + apex
                
                let p0 = [v1 + apex, v0 + apex, v3 + apex, v4 + apex].path(.green)
                let p1 = [v3, v4, v6, v5].path(.blue)
                
                guard let peak = Polygon(shape: p0),
                      let edge = Polygon(shape: p1) else { break }
                
                polygons.append(contentsOf: [peak,
                                             edge])
                
            case .tile: break
            }
        }
        
        return Mesh(polygons)
    }
}
