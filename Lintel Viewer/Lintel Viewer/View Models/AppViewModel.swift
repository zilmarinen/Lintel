//
//  AppViewModel.swift
//
//  Created by Zack Brown on 24/12/2023.
//

import Alluvium
import Bivouac
import Combine
import Deltille
import Euclid
import Foundation
import Lintel
import SceneKit
import SwiftUI

@MainActor
internal class AppViewModel: ObservableObject {
    
    @Published internal var septomino: Triangle.Septomino = .antlia {
        
        didSet {
            
            guard oldValue != septomino else { return }
            
            updateScene()
        }
    }
    
    internal let scene = SCNScene()
    
    internal let gridColor: NSColor = .grid
    internal let gridAlternateColor: NSColor = .gridAlternate
    
    internal let model = SCNNode()
    internal let wireframe = SCNNode()
    internal let surface = SCNNode()
    
    internal init() {
        
        updateScene()
        
        scene.rootNode.addChildNode(model)
        scene.rootNode.addChildNode(surface)
        
        model.addChildNode(wireframe)
    }
}

extension AppViewModel {
    
    private func updateScene() {
        
        updateModel()
        
        updateSurface()
    }
    
    private func updateModel() {
        
        let mesh = Mesh.building(septomino)
        
        model.geometry = .init(mesh)
        wireframe.geometry = .init(wireframe: mesh)
    }
    
    private func updateSurface() {
            
        let footprint = Triangle.Footprint(.zero,
                                           septomino.coordinates)
        
        var mesh = Mesh.empty
        
        for tile in footprint.perimeter {
                
            let color = tile.isPointy ? gridColor : gridAlternateColor
            
            guard let surface = Mesh.surface(tile.vertices.position(.tile),
                                             .init(color)) else { continue }
            
            mesh = mesh.merge(surface)
        }
        
        surface.geometry = .init(mesh)
    }
}
