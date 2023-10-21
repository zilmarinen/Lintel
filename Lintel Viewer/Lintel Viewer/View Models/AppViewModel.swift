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
    
    enum State {
        
        case caching
        case viewer
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
    
    @Published var layers: Grid.Triangle.Septomino.Layer = .two {
        
        didSet {
            
            guard oldValue != layers else { return }
            
            updateScene()
        }
    }
    
    @Published var profile: Mesh.Profile = .init(polygonCount: 0,
                                                 vertexCount: 0)
    
    @Published var state: State = .caching
    
    let scene = Scene()
    
    private let operationQueue = OperationQueue()
    
    private var cache: BuildingCache?
    
    init() {
        
        generateCache()
    }
}

extension AppViewModel {
    
    private func generateCache() {
            
        let operation = BuildingCacheOperation()
        
        operation.enqueue(on: operationQueue) { [weak self] result in
            
            guard let self else { return }
            
            switch result {
                
            case .success(let cache): self.cache = cache
            case .failure(let error): fatalError(error.localizedDescription)
            }
            
            self.updateScene()
            
            DispatchQueue.main.async { [weak self] in
                
                guard let self else { return }
                
                self.state = .viewer
            }
        }
    }
    
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
    
        self.scene.clear()
                
        self.updateSurface()
        
        guard let cache,
              let mesh = cache.mesh(for: architectureType,
                                    septomino: septomino,
                                    layers: layers),
              let node = self.createNode(with: mesh) else { return }
        
        self.scene.rootNode.addChildNode(node)
        
        self.updateProfile(for: mesh)
    }
    
    private func updateSurface() {
        
        var polygons: [Euclid.Polygon] = []
        
        for coordinate in septomino.footprint.perimeter {
            
            let triangle = Grid.Triangle(coordinate)
            
            let vertices = triangle.corners(for: .tile).map { Vertex($0, .up, nil, .white) }
            
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
