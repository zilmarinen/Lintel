//
//  AppView.swift
//
//  Created by Zack Brown on 08/09/2023.
//

import Bivouac
import SceneKit
import SwiftUI

struct AppView: View {

    @ObservedObject private var viewModel = AppViewModel()
    
    var body: some View {
        
        #if os(iOS)
            NavigationStack {
        
                sceneView
            }
        #else
            
            ZStack(alignment: .bottomTrailing) {
                
                sceneView
                
                Text("Polygons: [\(viewModel.profile.polygonCount)] Vertices: [\(viewModel.profile.vertexCount)]")
                    .foregroundColor(.black)
                    .padding()
            }
            
        #endif
    }
    
    var sceneView: some View {
        
        SceneView(scene: viewModel.scene,
                  pointOfView: viewModel.scene.camera.pov,
                  options: [.allowsCameraControl,
                            .autoenablesDefaultLighting])
        .toolbar {
            
            ToolbarItemGroup {
                
                toolbar
            }
        }
    }
    
    @ViewBuilder
    var toolbar: some View {
        
        Picker("Architecture",
               selection: $viewModel.architectureType) {
            
            ForEach(ArchitectureType.allCases, id: \.self) { architectureType in
                
                Text(architectureType.id.capitalized)
                    .id(architectureType)
            }
        }
        
        Picker("Septomino",
               selection: $viewModel.septomino) {
            
            ForEach(Grid.Triangle.Septomino.allCases, id: \.self) { septomino in
                
                Text(septomino.id.capitalized)
                    .id(septomino)
            }
        }
        
        Picker("Layers",
               selection: $viewModel.layers) {
            
            ForEach(AppViewModel.Layer.allCases, id: \.self) { layer in
                
                Text(layer.id.capitalized)
                    .id(layer)
            }
        }
    }
}
