//
//  Stencil.swift
//
//  Created by Zack Brown on 06/10/2023.
//

import Bivouac
import Euclid
import Foundation

extension Grid.Triangle.Stencil {
    
    enum Component {
        
        case corner
        case edge
    }
    
    var corner: LineSegment { LineSegment(vertex(for: .v3),
                                          vertex(for: .v4))! }
    
    var edge: LineSegment { LineSegment(vertex(for: .v12),
                                        vertex(for: .v4))! }
    
    func normal(for component: Component) -> Vector {
        
        switch component {
            
        case .corner: return (vertex(for: .v13) - vertex(for: .v0)).normalized()
        case .edge: return (vertex(for: .v2) - vertex(for: .v5)).normalized()
        }
    }
}
