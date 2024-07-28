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
}
