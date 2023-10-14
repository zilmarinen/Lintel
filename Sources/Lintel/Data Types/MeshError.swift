//
//  MeshError.swift
//
//  Created by Zack Brown on 02/10/2023.
//

import Euclid
import Foundation

internal enum MeshError: Error {
    
    case invalid(corner: Classification.Corner)
    case invalid(edge: Classification.Edge)
    case invalid(triangle: Classification.Triangle)
    
    case invalid(face: [Vertex])
}
