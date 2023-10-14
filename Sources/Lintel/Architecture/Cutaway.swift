//
//  Cutaway.swift
//
//  Created by Zack Brown on 09/10/2023.
//

import Bivouac
import Euclid
import Foundation

extension Grid.Triangle.Stencil {
    
    internal struct Cutaway {
        
        internal static let frameHeight = ArchitectureType.apex - 0.1
        internal static let transomHeight = 0.1
        internal static let cutawayWidth = 0.5
        internal static let cutawayHeight = 0.3
        internal static let frameDepth = 0.05
        internal static let innerRadius = outerRadius - frameDepth
        internal static let outerRadius = 0.1
        
        internal static let framePeak = Vector(0.0, frameHeight, 0.0)
        internal static let transomBase = Vector(0.0, frameHeight - transomHeight - frameDepth, 0.0)
        internal static let transomPeak = Vector(0.0, frameHeight - frameDepth, 0.0)
        internal static let cutawayPeak = Vector(0.0, frameHeight - transomHeight - (frameDepth * 2.0), 0.0)
        internal static let sillBase = Vector(0.0, frameHeight - transomHeight - cutawayHeight - (frameDepth * 3), 0.0)
        internal static let sillPeak = Vector(0.0, frameHeight - transomHeight - cutawayHeight - (frameDepth * 2), 0.0)
        
        internal enum Face {
            
            case inner
            case outer
        }
        
        internal enum Vertex {
            
            case center
            
            case cutawayBase
            case cutawayPeak
            
            case cutawayInsetBase
            case cutawayInsetPeak
            
            case frameBase
            case framePeak
            
            case frameInsetBase
            case frameInsetPeak
            
            case lintelBase
            case lintelPeak
            
            case sillBase
            case sillPeak
            
            case sillInsetBase
            case sillInsetPeak
            
            case transomBase
            case transomPeak
        }
        
        internal let center: Vector
        
        internal let cutawayBase: LineSegment
        internal let cutawayPeak: LineSegment
        
        internal let cutawayInsetBase: LineSegment
        internal let cutawayInsetPeak: LineSegment
        
        internal let frameBase: LineSegment
        internal let framePeak: LineSegment
        
        internal let frameInsetBase: LineSegment
        internal let frameInsetPeak: LineSegment
        
        internal let lintelBase: LineSegment
        internal let lintelPeak: LineSegment
        
        internal let sillBase: LineSegment
        internal let sillPeak: LineSegment
        
        internal let sillInsetBase: LineSegment
        internal let sillInsetPeak: LineSegment
        
        internal let transomBase: LineSegment
        internal let transomPeak: LineSegment
        
        internal func vertex(for vertex: Vertex,
                             side: LineSegment.Side) -> Vector {
            
            switch vertex {
                
            case .center: return center
            case .cutawayBase: return cutawayBase.vertex(for: side)
            case .cutawayPeak: return cutawayPeak.vertex(for: side)
            case .cutawayInsetBase: return cutawayInsetBase.vertex(for: side)
            case .cutawayInsetPeak: return cutawayInsetPeak.vertex(for: side)
            case .frameBase: return frameBase.vertex(for: side)
            case .framePeak: return framePeak.vertex(for: side)
            case .frameInsetBase: return frameInsetBase.vertex(for: side)
            case .frameInsetPeak: return frameInsetPeak.vertex(for: side)
            case .lintelBase: return lintelBase.vertex(for: side)
            case .lintelPeak: return lintelPeak.vertex(for: side)
            case .sillBase: return sillBase.vertex(for: side)
            case .sillPeak: return sillPeak.vertex(for: side)
            case .sillInsetBase: return sillInsetBase.vertex(for: side)
            case .sillInsetPeak: return sillInsetPeak.vertex(for: side)
            case .transomBase: return transomBase.vertex(for: side)
            case .transomPeak: return transomPeak.vertex(for: side)
                
            }
        }
        
        internal func apex(face: Face) -> (Vertex,
                                           Vertex,
                                           Vertex) {
            
            switch face {
                
            case .inner: return (.cutawayInsetBase,
                                 .cutawayPeak,
                                 .cutawayInsetPeak)
                
            case .outer: return (.lintelBase,
                                 .lintelPeak,
                                 .transomBase)
            }
        }
        
        internal func base(face: Face) -> (Vertex,
                                           Vertex,
                                           Vertex) {
            
            switch face {
                
            case .inner: return (.sillInsetPeak,
                                 .sillPeak,
                                 .sillInsetBase)
                
            case .outer: return (.frameInsetPeak,
                                 .sillBase,
                                 .frameInsetBase)
            }
        }
    }
    
    var cutaway: Cutaway {
        
        let guide = edge
        let center = guide.center
        let halfWidth = (Cutaway.cutawayWidth / 2.0)
        
        let frameBase = LineSegment(center.derp(guide.start, halfWidth),
                                    center.derp(guide.end, halfWidth))!
        
        let cutawayBase = LineSegment(frameBase.start.derp(center, Cutaway.frameDepth),
                                      frameBase.end.derp(center, Cutaway.frameDepth))!
        
        let framePeak = LineSegment(frameBase.start + Cutaway.framePeak,
                                    frameBase.end + Cutaway.framePeak)!
        
        let cutawayPeak = LineSegment(cutawayBase.start + Cutaway.cutawayPeak,
                                      cutawayBase.end + Cutaway.cutawayPeak)!
        
        let sillBase = LineSegment(frameBase.start + Cutaway.sillBase,
                                   frameBase.end + Cutaway.sillBase)!
        
        let sillPeak = LineSegment(cutawayBase.start + Cutaway.sillPeak,
                                   cutawayBase.end + Cutaway.sillPeak)!
        
        return Cutaway(center: center,
                       cutawayBase: cutawayBase,
                       cutawayPeak: LineSegment(cutawayBase.start + Cutaway.cutawayPeak,
                                                cutawayBase.end + Cutaway.cutawayPeak)!,
                       cutawayInsetBase: LineSegment(cutawayPeak.start.derp(sillPeak.start, Cutaway.innerRadius),
                                                     cutawayPeak.end.derp(sillPeak.end, Cutaway.innerRadius))!,
                       cutawayInsetPeak: LineSegment(cutawayPeak.start.derp(cutawayPeak.center, Cutaway.innerRadius),
                                                     cutawayPeak.end.derp(cutawayPeak.center, Cutaway.innerRadius))!,
                       frameBase: frameBase,
                       framePeak: framePeak,
                       frameInsetBase: LineSegment(sillBase.start.derp(sillBase.center, Cutaway.outerRadius),
                                                   sillBase.end.derp(sillBase.center, Cutaway.outerRadius))!,
                       frameInsetPeak: LineSegment(sillBase.start.derp(framePeak.start, Cutaway.outerRadius),
                                                   sillBase.end.derp(framePeak.end, Cutaway.outerRadius))!,
                       lintelBase: LineSegment(frameBase.start + Cutaway.cutawayPeak,
                                               frameBase.end + Cutaway.cutawayPeak)!,
                       lintelPeak: LineSegment(frameBase.start + Cutaway.transomBase,
                                               frameBase.end + Cutaway.transomBase)!,
                       sillBase: LineSegment(frameBase.start + Cutaway.sillBase,
                                             frameBase.end + Cutaway.sillBase)!,
                       sillPeak: sillPeak,
                       sillInsetBase: LineSegment(sillPeak.start.derp(sillPeak.center, Cutaway.innerRadius),
                                                  sillPeak.end.derp(sillPeak.center, Cutaway.innerRadius))!,
                       sillInsetPeak: LineSegment(sillPeak.start.derp(cutawayPeak.start, Cutaway.innerRadius),
                                                  sillPeak.end.derp(cutawayPeak.end, Cutaway.innerRadius))!,
                       transomBase: LineSegment(cutawayBase.start + Cutaway.transomBase,
                                                cutawayBase.end + Cutaway.transomBase)!,
                       transomPeak: LineSegment(cutawayBase.start + Cutaway.transomPeak,
                                                cutawayBase.end + Cutaway.transomPeak)!)
    }
}
