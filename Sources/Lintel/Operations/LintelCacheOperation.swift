//
//  LintelCacheOperation.swift
//
//  Created by Zack Brown on 15/10/2023.
//

import Bivouac
import Euclid
import Foundation
import PeakOperation

public class LintelCacheOperation: ConcurrentOperation,
                                   ProducesResult {
    
    public var output: Result<[String : Mesh], Error> = Result { throw ResultError.noResult }
    
    public override func execute() {
     
        //
        self.output = .success([:])
        
        finish()
    }
}
