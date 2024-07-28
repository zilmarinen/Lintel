//
//  AppView.swift
//
//  Created by Zack Brown on 08/09/2023.
//

import Bivouac
import Deltille
import Dependencies
import SceneKit
import SwiftUI

struct AppView: View {
    
    @Dependency(\.deviceManager) var deviceManager

    @ObservedObject private var viewModel = AppViewModel()
    
    var body: some View {
            
        #if os(iOS)
            NavigationStack {
        
                viewer
            }
        #else
            viewer
        #endif
    }
    
    var viewer: some View {
        
        ZStack(alignment: viewModel.state == .caching ? .center : .bottomTrailing) {
            
            sceneView
            
            switch viewModel.state {
                
            case .caching:
                
                Text("Caching Models")
                    .foregroundColor(.black)
                    .padding()
                
            case .viewer:
                
                Text("Polygons: [\(viewModel.profile.polygonCount)] Vertices: [\(viewModel.profile.vertexCount)]")
                    .foregroundColor(.black)
                    .padding()
            }
        }
    }
    
    var sceneView: some View {
        
        SceneView(scene: viewModel.scene,
                  pointOfView: viewModel.scene.camera.pov,
                  options: [.allowsCameraControl,
                            .autoenablesDefaultLighting],
                  technique: deviceManager.technique)
        .toolbar {
            
            ToolbarItemGroup {
                
                toolbar
            }
        }
        .disabled(viewModel.state != .viewer)
    }
    
    @ViewBuilder
    var toolbar: some View {
        
        Picker("Septomino",
               selection: $viewModel.septomino) {
            
            ForEach(Grid.Triangle.Septomino.allCases, id: \.self) { septomino in
                
                Text(septomino.id)
                    .id(septomino)
            }
        }
    }
}
