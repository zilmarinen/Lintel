//
//  BuildingMeshOperation.swift
//
//  Created by Zack Brown on 15/10/2023.
//

import Bivouac
import Deltille
import Euclid
import Foundation
import PeakOperation

internal class BuildingMeshOperation: ConcurrentOperation,
                                      ProducesResult {
    
    internal var output: Result<Mesh, Error> = Result { throw ResultError.noResult }
    
    internal let architectureType: ArchitectureType
    internal let septomino: Grid.Triangle.Septomino
    internal let prefabs: [Prefab : Mesh]
    internal let floors: Int
    
    internal init(_ architectureType: ArchitectureType,
                  _ septomino: Grid.Triangle.Septomino,
                  _ prefabs: [Prefab : Mesh],
                  _ floors: Int) {
        
        self.architectureType = architectureType
        self.septomino = septomino
        self.prefabs = prefabs
        self.floors = floors
        
        super.init()
    }
    
    public override func execute() {
        
        do {
            
            let floorPlan = FloorPlan(foundation: septomino.coordinates)
            
            var mesh = Mesh([])
            
            for vertex in floorPlan.perimeter {
                
//                guard let edge = floorPlan.edge(vertex.coordinate) else { throw GeometryError.invalidPolygon }
//                
//                guard let prefab = prefabs[edge == .edge ? .wallFull : .wallHalf] else { throw GeometryError.invalidStencil }
                let prefab = prefabs[.wallFull]!
                
                let triangle = Grid.Triangle(vertex.coordinate)
                
                let transform = Transform(offset: Vector(triangle.position,
                                                         Grid.Triangle.Scale.tile),
                                          rotation: floorPlan.rotation(vertex.coordinate))
                
                mesh = mesh.union(prefab.transformed(by: transform))
            }
            
            self.output = .success(mesh)
        }
        catch { self.output = .failure(error) }
        
        finish()
    }
}
