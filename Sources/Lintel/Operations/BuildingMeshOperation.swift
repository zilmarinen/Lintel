//
//  BuildingMeshOperation.swift
//
//  Created by Zack Brown on 15/10/2023.
//

import Bivouac
import Deltille
import Dependencies
import Euclid
import Foundation
import PeakOperation

internal class BuildingMeshOperation: ConcurrentOperation,
                                      ProducesResult {
    
    @Dependency(\.prefabCache) var prefabCache
    
    internal var output: Result<Mesh, Error> = Result { throw ResultError.noResult }
    
    internal let architectureType: ArchitectureType
    internal let septomino: Grid.Triangle.Septomino
    internal let floors: Int
    
    internal init(_ architectureType: ArchitectureType,
                  _ septomino: Grid.Triangle.Septomino,
                  _ floors: Int) {
        
        self.architectureType = architectureType
        self.septomino = septomino
        self.floors = floors
        
        super.init()
    }
    
    public override func execute() {
        
        do {
            
            var floorPlan = FloorPlan(foundation: septomino.coordinates)
            
            var mesh = Mesh([])
            
            for floor in 0..<floors {
                
                for vertex in floorPlan.perimeter {
                    
                    guard let edge = floorPlan.edge(vertex.coordinate) else { throw GeometryError.invalidPolygon }
                    
                    let identifier = PrefabCache.identifier(architectureType, edge == .edge ? .wallFull : .wallHalf)
                    
                    guard let prefab = prefabCache.mesh(identifier) else { throw GeometryError.invalidStencil }
                    
                    let transform = Transform(offset: Vector(vertex.coordinate,
                                                             Grid.Triangle.Scale.tile) + (Double(floor) * Vector.unitY),
                                              rotation: floorPlan.rotation(vertex.coordinate))
                    
                    mesh = mesh.merge(prefab.transformed(by: transform))
                }
                
                floorPlan = floorPlan.collapse()
            }
            
            self.output = .success(mesh)
        }
        catch { self.output = .failure(error) }
        
        finish()
    }
}
