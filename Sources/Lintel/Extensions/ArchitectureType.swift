//
//  ArchitectureType.swift
//
//  Created by Zack Brown on 30/09/2023.
//

import Bivouac
import Euclid
import Foundation

extension ArchitectureType {
    
    enum Bernina {}
    enum Daisen {}
}

extension ArchitectureType {
    
    public static let apex = Double(Grid.Scale.tile.rawValue)
    public static let lintel = apex - 0.2
    
    internal func mesh(stencil: Grid.Triangle.Stencil,
                       corner: Classification.Corner) throws -> Mesh {
        
        switch corner {
            
        default: return try Grid.Triangle.Corner.mesh(stencil: stencil,
                                                      color: colorPalette.primary)
        }
    }
    
    internal func mesh(stencil: Grid.Triangle.Stencil,
                       edge: Classification.Edge) throws -> Mesh {
        
        switch edge {
            
        case .four: return try Door.mesh(stencil: stencil,
                                         architectureType: self)
        
        default: return try Grid.Triangle.Edge.mesh(stencil: stencil,
                                                    color: colorPalette.secondary)
        }
    }
    
    internal func mesh(stencil: Grid.Triangle.Stencil,
                       triangle: Classification.Triangle) throws -> Mesh {
        
        switch triangle {
            
        default: return try Grid.Triangle.Tile.mesh(stencil: stencil,
                                                    color: colorPalette.primary)
        }
    }
}

extension ArchitectureType {
    
    public var colorPalette: ColorPalette {
        
        switch self {
            
        case .bernina: return .init(primary: .init(.systemBrown), secondary: .init(.systemGreen))
        case .daisen: return .init(primary: .init(.systemTeal), secondary: .init(.systemGray))
        case .elna: return .init(primary: .init(.systemOrange), secondary: .init(.systemIndigo))
        case .juki: return .init(primary: .init(.systemGreen), secondary: .init(.systemBrown))
        case .merrow: return .init(primary: .init(.systemGreen), secondary: .init(.systemBrown))
        case .necchi: return .init(primary: .init(.systemGreen), secondary: .init(.systemBrown))
        case .singer: return .init(primary: .init(.systemGreen), secondary: .init(.systemBrown))
        }
    }
}
