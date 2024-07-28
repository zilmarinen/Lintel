//
//  ArchitectureType.swift
//
//  Created by Zack Brown on 28/07/2024.
//

import Bivouac
import Foundation

public enum ArchitectureType: String,
                              CaseIterable,
                              Codable,
                              Identifiable {
    
    case bernina
    case daisen
    case elna
    case juki
    case merrow
    case necchi
    case singer
    
    public var id: String { rawValue.capitalized }
}

extension ArchitectureType {
    
    public var colorPalette: ColorPalette {
        
        switch self {
            
        case .bernina: return .init("BDA928",
                                    "473F2D",
                                    "543310",
                                    "74512D")
            
        case .daisen: return .init("63424B",
                                   "3A243B",
                                   "543310",
                                   "74512D")
            
        case .elna: return .init("63424B",
                                 "3A243B",
                                 "543310",
                                 "74512D")
            
        case .juki: return .init("8B7D3A",
                                 "534A32",
                                 "543310",
                                 "74512D")
            
        case .merrow: return .init("FFA631",
                                   "CB7E1F",
                                   "543310",
                                   "74512D")
            
        case .necchi: return .init("6B9362",
                                   "2A603B",
                                   "543310",
                                   "74512D")
            
        case .singer: return .init("BDA928",
                                   "473F2D",
                                   "543310",
                                   "74512D")
        }
    }
}
