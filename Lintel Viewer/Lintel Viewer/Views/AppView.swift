//
//  AppView.swift
//
//  Created by Zack Brown on 24/12/2025.
//

import Bivouac
import Deltille
import SceneKit
import SwiftUI

struct AppView: View {
    
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
        
        ZStack(alignment: .bottomTrailing) {
            
            sceneView
        }
    }
    
    var sceneView: some View {
        
        SceneView(scene: viewModel.scene,
                  options: [.allowsCameraControl,
                            .autoenablesDefaultLighting])
        .toolbar {
            
            ToolbarItemGroup {
                
                toolbar
            }
        }
        .navigationTitle("Lintel")
    }
    
    @ViewBuilder
    var toolbar: some View {
        
        Picker("Septomino",
               selection: $viewModel.septomino) {
            
            ForEach(Triangle.Septomino.allCases, id: \.self) { septomino in
                
                Text(septomino.id)
                    .id(septomino)
            }
        }
    }
}
