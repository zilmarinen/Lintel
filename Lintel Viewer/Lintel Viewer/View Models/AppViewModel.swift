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
    
    enum Layer: Int,
                CaseIterable,
                Identifiable {
        
        case one = 1
        case two = 2
        case three = 3
        
        var id: String {
            
            switch self {
                
            case .one: return "One"
            case .two: return "Two"
            case .three: return "Three"
            }
        }
    }
    
    @Published var architectureType: ArchitectureType = .juki {
        
        didSet {
            
            guard oldValue != architectureType else { return }
            
            updateScene()
        }
    }
    
    @Published var septomino: Grid.Triangle.Septomino = .maia {
        
        didSet {
            
            guard oldValue != septomino else { return }
            
            updateScene()
        }
    }
    
    @Published var layers: Layer = .two {
        
        didSet {
            
            guard oldValue != layers else { return }
            
            updateScene()
        }
    }
    
    @Published var profile: Mesh.Profile = .init(polygonCount: 0,
                                                 vertexCount: 0)
    
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
                                              septomino: septomino,
                                              totalLayers: layers.rawValue)
                
        operation.enqueue(on: operationQueue) { [weak self] result in
            
            guard let self else { return }
            
            switch result {
                
            case .success(let mesh):
                
                self.scene.clear()
                
                self.updateSurface()
                
                self.updateProfile(for: mesh)
                
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
    
    private func updateProfile(for mesh: Mesh) {
        
        DispatchQueue.main.async { [weak self] in
            
            guard let self else { return }
            
            self.profile = mesh.profile
        }
    }
}
