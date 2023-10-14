//
//  Style.swift
//
//  Created by Zack Brown on 07/10/2023.
//

import Bivouac
import Euclid
import Foundation

extension ArchitectureType {
 
    internal enum Style: Equatable {
        
        case angled
        case curved(steps: Int)
        case straight(transom: Bool)
        
        var curved: Bool {
            
            switch self {
                
            case .curved: return true
            default: return false
            }
        }
    }
    
    internal var style: Style {
        
        switch self {
            
        case .bernina: return .straight(transom: false)
        case .daisen: return .straight(transom: true)
        case .elna: return .curved(steps: 5)
        case .juki: return .angled
        case .merrow: return .curved(steps: 5)
        case .necchi: return .angled
        case .singer: return .straight(transom: false)
        }
    }
}

extension ArchitectureType.Style {
    
    func start(for cutaway: Grid.Triangle.Stencil.Cutaway,
               face: Grid.Triangle.Stencil.Cutaway.Face) -> Vector {
        
        switch self {
            
        case .straight(let transom): return cutaway.vertex(for: (face == .inner ? .cutawayPeak :
                                                                (transom ? .framePeak : .lintelPeak)),
                                                           side: .left)
            
        default: return cutaway.vertex(for: (face == .inner ? .cutawayInsetBase : .lintelBase),
                                       side: .left)
            
        
        }
    }
}

extension ArchitectureType.Style {
    
    internal func stencil(frame cutaway: Grid.Triangle.Stencil.Cutaway) -> [Vector] {
        
        [cutaway.vertex(for: .frameBase,
                        side: .left)] +
        apex(cutaway: cutaway,
             face: .outer) +
        [cutaway.vertex(for: .frameBase,
                        side: .right),
         cutaway.vertex(for: .frameBase,
                        side: .left)]
    }
    
    internal func stencil(archway cutaway: Grid.Triangle.Stencil.Cutaway) -> [Vector] {
        
        switch self {
            
        case .straight(let transom): return [cutaway.vertex(for: .cutawayBase,
                                                            side: .left),
                                             cutaway.vertex(for: (transom ? .transomPeak : .cutawayPeak),
                                                            side: .left),
                                             cutaway.vertex(for: (transom ? .transomPeak : .cutawayPeak),
                                                            side: .right),
                                             cutaway.vertex(for: .cutawayBase,
                                                            side: .right),
                                             cutaway.vertex(for: .cutawayBase,
                                                            side: .left),]
            
        default: return stencil(door: cutaway)
        }
    }
    
    internal func stencil(door cutaway: Grid.Triangle.Stencil.Cutaway) -> [Vector] {
        
        [cutaway.vertex(for: .cutawayBase,
                        side: .left)] +
        apex(cutaway: cutaway,
             face: .inner) +
        [cutaway.vertex(for: .cutawayBase,
                        side: .right),
        cutaway.vertex(for: .cutawayBase,
                       side: .left)]
    }
    
    internal func stencil(transom cutaway: Grid.Triangle.Stencil.Cutaway) -> [Vector] {
        
        [cutaway.vertex(for: .transomBase,
                            side: .left),
         cutaway.vertex(for: .transomPeak,
                        side: .left),
         cutaway.vertex(for: .transomPeak,
                        side: .right),
         cutaway.vertex(for: .transomBase,
                        side: .right),
         cutaway.vertex(for: .transomBase,
                        side: .left)]
    }
    
    internal func stencil(window cutaway: Grid.Triangle.Stencil.Cutaway) -> [Vector] {
        
        apex(cutaway: cutaway,
             face: .inner) +
        base(cutaway: cutaway,
             face: .inner) +
        [start(for: cutaway,
               face: .inner)]
    }
    
    internal func stencil(windowFrame cutaway: Grid.Triangle.Stencil.Cutaway) -> [Vector] {
        
        apex(cutaway: cutaway,
             face: .outer) +
        base(cutaway: cutaway,
             face: .outer) +
        [start(for: cutaway,
               face: .outer)]
    }
    
    internal func apex(cutaway: Grid.Triangle.Stencil.Cutaway,
                       face: Grid.Triangle.Stencil.Cutaway.Face) -> [Vector] {
        
        let (v0, v1, v2) = cutaway.apex(face: face)
        
        switch self {
            
        case .angled: return [cutaway.vertex(for: v0,
                                             side: .left),
                              cutaway.vertex(for: v2,
                                             side: .left),
                              cutaway.vertex(for: v2,
                                             side: .right),
                              cutaway.vertex(for: v0,
                                             side: .right)]
            
        case .curved(let steps): return Vector.curve(from: cutaway.vertex(for: v0,
                                                                          side: .left),
                                                     towards: cutaway.vertex(for: v2,
                                                                             side: .left),
                                                     control: cutaway.vertex(for: v1,
                                                                             side: .left),
                                                     steps: steps) +
                                        Vector.curve(from: cutaway.vertex(for: v2,
                                                                          side: .right),
                                                     towards: cutaway.vertex(for: v0,
                                                                             side: .right),
                                                     control: cutaway.vertex(for: v1,
                                                                             side: .right),
                                                     steps: steps)
            
        case .straight(let transom): return [cutaway.vertex(for: face == .inner ? v1 : (transom ? .framePeak : v1),
                                                            side: .left),
                                             cutaway.vertex(for: face == .inner ? v1 : (transom ? .framePeak : v1),
                                                            side: .right)]
        }
    }
    
    internal func base(cutaway: Grid.Triangle.Stencil.Cutaway,
                       face: Grid.Triangle.Stencil.Cutaway.Face) -> [Vector] {
        
        let (v0, v1, v2) = cutaway.base(face: face)
        
        switch self {
            
        case .angled: return [cutaway.vertex(for: v0,
                                             side: .right),
                              cutaway.vertex(for: v2,
                                             side: .right),
                              cutaway.vertex(for: v2,
                                             side: .left),
                              cutaway.vertex(for: v0,
                                             side: .left)]
            
        case .curved(let steps): return Vector.curve(from: cutaway.vertex(for: v0,
                                                                          side: .right),
                                                     towards: cutaway.vertex(for: v2,
                                                                             side: .right),
                                                     control: cutaway.vertex(for: v1,
                                                                             side: .right),
                                                     steps: steps) +
                                        Vector.curve(from: cutaway.vertex(for: v2,
                                                                          side: .left),
                                                     towards: cutaway.vertex(for: v0,
                                                                             side: .left),
                                                     control: cutaway.vertex(for: v1,
                                                                             side: .left),
                                                     steps: steps)
            
        case .straight: return [cutaway.vertex(for: v1,
                                               side: .right),
                                cutaway.vertex(for: v1,
                                               side: .left)]
        }
    }
}
