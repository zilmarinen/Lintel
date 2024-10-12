//
//  BuildingCache.swift
//
//  Created by Zack Brown on 15/10/2023.
//

import Bivouac
import Deltille
import Dependencies
import Euclid

public final class BuildingCache: AssetCache,
                                  DependencyKey {
    
    static public var liveValue = BuildingCache([:])
    
    static public func identifier(_ architectureType: ArchitectureType,
                                  _ septomino: Grid.Triangle.Septomino,
                                  _ floor: Int) -> String {
            
        "\(architectureType.id)_\(septomino.id)_\(floor)"
    }
}

internal final class PrefabCache: AssetCache,
                                  DependencyKey {
    
    static public var liveValue = PrefabCache([:])
    
    static internal func identifier(_ architectureType: ArchitectureType,
                                    _ prefab: Prefab) -> String {
            
        "\(architectureType.id)_\(prefab.id)"
    }
}
