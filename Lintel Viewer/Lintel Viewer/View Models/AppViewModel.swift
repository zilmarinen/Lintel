//
//  AppViewModel.swift
//
//  Created by Zack Brown on 08/09/2023.
//

import Bivouac
import Euclid
import Foundation
import Lintel
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
    
    @Published var septomino: Grid.Triangle.Septomino = .a {
        
        didSet {
            
            guard oldValue != septomino else { return }
            
            updateScene()
        }
    }
    
    let scene = Scene()
    
    private let operationQueue = OperationQueue()
    
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
        
        let operation = BuildingMeshOperation(architectureType: architectureType,
                                              septomino: septomino)
                
        operation.enqueue(on: operationQueue) { [weak self] result in
            
            guard let self else { return }
            
            switch result {
                
            case .success(let mesh):
                
                self.scene.clear()
                
                self.updateSurface()
                
                guard let node = self.createNode(with: mesh) else { return }
                
                self.scene.rootNode.addChildNode(node)
                
            case .failure(let error):
                
                fatalError(error.localizedDescription)
            }
        }
    }
    
    private func updateSurface() {
        
        var polygons: [Euclid.Polygon] = []
        
        for coordinate in septomino.footprint.perimeter {
            
            let triangle = Grid.Triangle(coordinate)
            
            let vertices = triangle.vertices(for: .tile).map { Vertex($0, .up, nil, .white) }
            
            guard let polygon = Polygon(vertices) else { continue }
            
            polygons.append(polygon)
        }
        
        let mesh = Mesh(polygons)
        
        guard let node = createNode(with: mesh) else { return }
        
        scene.rootNode.addChildNode(node)
    }
}
