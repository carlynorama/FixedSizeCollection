//
//  Copy.swift
//  
//
//  Created by Carlyn Maw on 2/4/24.
//


public extension FixedSizeCollection {
    //TODO: currently unchecked, because _checkSubscript(range)
    //would not catch a desync between _storage and count. 
    func copyValuesAsArray() throws -> [Element] {
        guncCopyRangeAsArray(0..<count)
    }
    
    //Same as current subscript.
    func copyValuesAsArray(range:Range<N>) throws -> [Element]{
        guard _checkSubscript(range) else {
            throw FSCError.outOfRange
        }
        return guncCopyRangeAsArray(range)
    }
}
