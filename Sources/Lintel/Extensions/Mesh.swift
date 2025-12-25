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
        
        var polygons: [Polygon] = []
        
        for tile in perimeter {
            
            let corners = tile.vertices.filter { vertices.contains($0) }
            
            let wedge = Wedge(tile,
                              corners)
            
            switch wedge {
                
            case .corner(let corner):
                
                
                
            case .edge(let edge):
                
            case .tile: break
            }
        }
        
        return Mesh(polygons)
    }
}
