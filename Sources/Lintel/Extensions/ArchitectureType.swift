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
}

extension ArchitectureType {
    
    internal func mesh(stencil: Grid.Triangle.Stencil,
                       corner: Classification.Corner) throws -> Mesh {
        
        switch corner {
            
        default: return try Grid.Triangle.Corner.mesh(stencil: stencil,
                                                      architectureType: self)
        }
    }
    
    internal func mesh(stencil: Grid.Triangle.Stencil,
                       cutaway: Grid.Triangle.Stencil.Cutaway,
                       edge: Classification.Edge) throws -> Mesh {
        
        switch edge {
            
        case .four, .nine: return try Door.mesh(stencil: stencil,
                                                cutaway: cutaway,
                                                architectureType: self)
        
        case .five: return try Archway.mesh(stencil: stencil,
                                            cutaway: cutaway,
                                            architectureType: self)
        
        case .six, .eight,
                .ten, .fourteen, .sixteen: return try Window.mesh(stencil: stencil,
                                                                  cutaway: cutaway,
                                                                  architectureType: self)
        
        default: return try Grid.Triangle.Edge.mesh(stencil: stencil,
                                                    architectureType: self)
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
    
    internal var doorColor: Color {
        
        switch self {
            
        case .bernina: return .init("B2533E")
            
        case .daisen: return .init("C8AE7D")
            
        case .elna: return .init("765827")
            
        case .juki: return .init("BCA37F")
            
        case .merrow: return .init("482121")
            
        case .necchi: return .init("321E1E")
            
        case .singer: return .init("9E6F21")
        }
    }
    
    internal var colorPalette: ColorPalette {
        
        switch self {
            
        case .bernina: return .init(primary: .init("F3DEBA"),
                                    secondary: .init("A9907E"),
                                    tertiary: .init("675D50"),
                                    quaternary: .init("ABC4AA"))
            
        case .daisen: return .init(primary: .init("B9B4C7"),
                                   secondary: .init("352F44"),
                                   tertiary: .init("FAF0E6"),
                                   quaternary: .init("5C5470"))
            
        case .elna: return .init(primary: .init("E19898"),
                                 secondary: .init("A2678A"),
                                 tertiary: .init("4D3C77"),
                                 quaternary: .init("3F1D38"))
            
        case .juki: return .init(primary: .init("96B6C5"),
                                 secondary: .init("EEE0C9"),
                                 tertiary: .init("ADC4CE"),
                                 quaternary: .init("F1F0E8"))
            
        case .merrow: return .init(primary: .init("FF6969"),
                                   secondary: .init("F4DFB6"),
                                   tertiary: .init("DE8F5F"),
                                   quaternary: .init("80B3FF"))
            
        case .necchi: return .init(primary: .init("9A4444"),
                                   secondary: .init("F4DFB6"),
                                   tertiary: .init("DE8F5F"),
                                   quaternary: .init("80B3FF"))
            
        case .singer: return .init(primary: .init("9A4444"),
                                   secondary: .init("F4DFB6"),
                                   tertiary: .init("DE8F5F"),
                                   quaternary: .init("80B3FF"))
        }
    }
}
