//
//  AppViewModel.swift
//
//  Created by Zack Brown on 08/09/2023.
//

import Bivouac
import Deltille
import Dependencies
import Euclid
import Lintel
import SceneKit

class AppViewModel: ObservableObject {
    
    enum State {
        
        case caching
        case viewer
    }
    
    @Dependency(\.buildingCache) var buildingCache
    
    @Published var architectureType: ArchitectureType = .bernina {
        
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
    
    @Published var profile: Mesh.Profile = .init(polygonCount: 0,
                                                 vertexCount: 0)
    
    @Published var state: State = .caching
    
    let scene = ModelViewScene()
    
    private let operationQueue = OperationQueue()
    
    init() {
        
        generateCache()
    }
}

extension AppViewModel {
    
    private func generateCache() {
            
        let operation = LintelCacheOperation()
        
        operation.enqueue(on: operationQueue) { [weak self] result in
            
            guard let self else { return }
            
            switch result {
                
            case .success(let meshes): buildingCache.merge(meshes)
            case .failure(let error): fatalError(error.localizedDescription)
            }
            
            self.updateScene()
            
            DispatchQueue.main.async { [weak self] in
                
                guard let self else { return }
                
                self.state = .viewer
            }
        }
    }
    
    private func updateScene() {
    
        scene.clear()
                
        scene.render(surface: septomino.footprint.coordinates.perimeter)
        
        guard let mesh = buildingCache.mesh(septomino.id) else { return }
        
        let geometry = SCNGeometry(mesh)
        
        geometry.program = Program(function: .geometry)
        
        scene.model.geometry = geometry
        
        updateProfile(for: mesh)
    }
    
    private func updateProfile(for mesh: Mesh) {
        
        DispatchQueue.main.async { [weak self] in
            
            guard let self else { return }
            
            self.profile = mesh.profile
        }
    }
}

extension AppViewModel {
 
    func presentExportModal() {
        
        let panel = NSOpenPanel()
        
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.canCreateDirectories = true
        panel.isExtensionHidden = true
        panel.showsHiddenFiles = false
        panel.showsTagField = false
        
        panel.begin { [weak self] response in
            
            switch response {
                
            case .OK:
                
                guard let self,
                      let url = panel.urls.first else { return }
                
                let operation = AssetCacheExportOperation(buildingCache,
                                                          url)
                
                operation.enqueue(on: self.operationQueue)
                
            default: break
            }
        }
    }
}
