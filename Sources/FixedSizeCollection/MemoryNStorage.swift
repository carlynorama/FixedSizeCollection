//
//  MemoryNStroage.swift
//  
//
//  Created by Carlyn Maw on 2/6/24.
//

import Foundation



//TODO: What is a DependenceToken used for (as seen in Array)
extension FixedSizeCollection {
    
    @inlinable
    internal func _checkSubscript(_ position: N) -> Bool {
        (0..<count).contains(position)
    }
    
    @inlinable
    internal func _checkSubscript(_ range: Range<N>) -> Bool {
        (0..<count).contains(range.lowerBound) && (0..<count).contains(range.upperBound)
    }
    
}

//MARK: Helpers
extension FixedSizeCollection {
    
    @inlinable
    static func _getVerifiedCount(storage:_Storage) -> N {
        storage.withUnsafeBytes { bytes in
            let tmpCount = bytes.count / MemoryLayout<Element>.stride
            precondition(tmpCount * MemoryLayout<Element>.stride == bytes.count)
            precondition(
                Int(bitPattern: bytes.baseAddress).isMultiple(of: MemoryLayout<Element>.alignment))
            return tmpCount
        }
        
    }
    
    @inlinable
    static func _confimSizeOfTuple<U>(tuple:U, expectedCount:N? = nil) throws -> N {
        let count = Mirror(reflecting: tuple).children.count
        if expectedCount != nil, expectedCount != count  {
            throw FSCError.unknownError(message: "tuple's children and tuple's expected count not the same.")
        }
        return count
    }
    
    @inlinable
    internal func _sliceOfStorage(_ range: Range<N>) throws -> _Storage.SubSequence {
        let startIndex = _storage.startIndex + _mStrideOffset(for: range.lowerBound)
        let endIndex = _storage.startIndex + _mStrideOffset(for: range.upperBound)
        return _storage[startIndex..<endIndex]
    }
    
    @inlinable
    internal var _mStrideFull: N { MemoryLayout<Element>.stride * count }
    
    @inlinable
    internal var _mStrideElem: N { MemoryLayout<Element>.stride }
    
    @inlinable
    internal func _mStrideOffset(for count: N) -> N { MemoryLayout<Element>.stride * count }


    //Less safe in the case that the memory is not in fact bound to this.
    @inlinable
    internal static func _getFixedSizeCArrayAssumed<T, R>(source:T, boundToType:R.Type, withCount count:N? = nil) -> [R] {
        return Swift.withUnsafeBytes(of: source) { (rawPointer) -> [R] in
            let bufferPointer = rawPointer.assumingMemoryBound(to: boundToType)
            return [R](bufferPointer)
        }
    }
    
    //TODO: Having difficulties. 
//    @inlinable
//    internal static func loadFixedSizeCArray<T, R>(source:T, ofType:R.Type) -> [R]? {
//        Swift.withUnsafeBytes(of: source) { (rawPointer) -> [R]? in
//            rawPointer.baseAddress?.load(as: [R].self)
//        }
//    }
}
