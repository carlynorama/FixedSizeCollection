//
//  DetachedCopy.swift
//
//
//  Created by Carlyn Maw on 2/4/24.
//

import Foundation

//TODO: Untested

public extension FixedSizeCollection {
    
    //TODO: Believe this is copy,copy not COW?
    func copyValuesAsArray() throws -> [Element] {
        try self.withUnsafeBytes { pointer in
            pointer.load(as: [Element].self)
        }
    }
    
    func copyValuesAsArray(range:Range<N>) throws -> [Element]{
        guard _checkSubscript(range) else {
            //TODO: What's the right error
            fatalError()
        }
       return try guncCopyRange(range: range)
    }
    
}

