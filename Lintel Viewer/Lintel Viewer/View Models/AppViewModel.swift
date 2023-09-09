//
//  AppViewModel.swift
//
//  Created by Zack Brown on 08/09/2023.
//

import Bivouac
import Euclid
import Foundation
import SceneKit

class AppViewModel: ObservableObject {
    
    enum Constant {
        
        static let cameraY = 1.5
        static let cameraZ = 1.5
    }
    
    @Published var architectureType: ArchitectureType = .bernina {
        
        didSet {
            
            guard oldValue != architectureType else { return }
            
            updateScene()
        }
    }
    
    let scene = Scene()
    
    private var footprint: Grid.Footprint { .init(origin: .zero,
                                                  area: .rhombus) }
    
    init() {
        
        updateScene()
    }
}

extension AppViewModel {
    
    private func createNode(with mesh: Mesh?) -> SCNNode? {
        
        guard let mesh else { return nil }
        
        let node = SCNNode()
        let wireframe = SCNNode()
        let material = SCNMaterial()
        
        node.geometry = SCNGeometry(mesh)
        node.geometry?.firstMaterial = material
        
        wireframe.geometry = SCNGeometry(wireframe: mesh)
        
        node.addChildNode(wireframe)
        
        return node
    }
    
    private func updateScene() {
        
        scene.clear()
        
        var polygons: [Euclid.Polygon] = []
        
        for coordinate in footprint.coordinates {
            
            let triangle = Grid.Triangle(coordinate)
            
            let vertices = triangle.vertices(for: .tile).map { Vertex($0, .up) }
            
            guard let polygon = Polygon(vertices) else { continue }
            
            polygons.append(polygon)
        }
        
        let mesh = Mesh(polygons)
        
        guard let node = createNode(with: mesh) else { return }
        
        scene.rootNode.addChildNode(node)
    }
}
