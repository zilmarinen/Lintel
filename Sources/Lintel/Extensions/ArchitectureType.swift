//
//  ArchitectureType.swift
//
//  Created by Zack Brown on 30/09/2023.
//

import Bivouac
import Foundation

extension ArchitectureType {
    
    public var colorPalette: ColorPalette {
        
        switch self {
            
        case .bernina: return .init(primary: .init(.systemGreen), secondary: .init(.systemBrown))
        case .daisen: return .init(primary: .init(.systemTeal), secondary: .init(.systemGray))
        case .elna: return .init(primary: .init(.systemGreen), secondary: .init(.systemBrown))
        case .juki: return .init(primary: .init(.systemGreen), secondary: .init(.systemBrown))
        case .merrow: return .init(primary: .init(.systemGreen), secondary: .init(.systemBrown))
        case .necchi: return .init(primary: .init(.systemGreen), secondary: .init(.systemBrown))
        case .singer: return .init(primary: .init(.systemGreen), secondary: .init(.systemBrown))
        }
    }
}
