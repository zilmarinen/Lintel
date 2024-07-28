//
//  Dependencies.swift
//
//  Created by Zack Brown on 28/07/2024.
//

import Dependencies

extension DependencyValues {
    
    public var buildingCache: BuildingCache {
        
        get { self[BuildingCache.self] }
        set { self[BuildingCache.self] = newValue }
    }
}
