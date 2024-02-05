//
//  File.swift
//
//
//  Created by Carlyn Maw on 2/4/24.
//

import Foundation


internal extension FixedSizeCollection {
    @inlinable
    func gunc(at position:N) -> Element {
        return _storage.withUnsafeBytes { rawPointer in
            let bufferPointer = rawPointer.assumingMemoryBound(to: Element.self)
            return bufferPointer[position]
        }
    }
    
    //TODO: Should this return a discardable success?
    //Not currently @inlinable as written
    mutating
    func sunc(at position:N, newValue:Element) {
        let startIndex = _storage.startIndex + _mStrideOffset(for: position)
        let endIndex = startIndex + _mStrideElem
        Swift.withUnsafePointer(to: newValue) { sourceValuePointer in
            _storage.replaceSubrange(startIndex..<endIndex, with: sourceValuePointer, count: _mStrideElem)
        }
    }
    
     func guncCopyRangeAsArray(_ range:Range<N>) ->  [Element] {
         let sourceByteCount = _mStrideOffset(for: range.count)
         let tmp = Array<Element>(unsafeUninitializedCapacity: sourceByteCount) { destBuffer, initializedCount in
             _storage.withUnsafeBytes { sourceBuffer in
                 //dest, source, num
                 memcpy(destBuffer.baseAddress,
                        sourceBuffer.baseAddress?.advanced(by: _mStrideOffset(for: range.lowerBound)),
                        sourceByteCount)
                 initializedCount = sourceByteCount
             }
         }
         return tmp
     }
     
    
    //@inlinable  //no because FixedSizeCollection(storage: _storage, as: Element.self) is internal
//    func guncCopyRange(_ range:Range<N>) throws -> FixedSizeCollection<Element> {
//        let startIndex = _storage.startIndex + _mStrideOffset(for: range.lowerBound)
//        let endIndex = _storage.startIndex + _mStrideOffset(for: range.upperBound)
//        let tmp = _storage[startIndex..<endIndex]
//        return FixedSizeCollection(storage: _storage, as: Element.self)
//    }
    
//    func guncCopyRange(_ range:Range<N>) throws ->  {
//        
//        
//        let startIndex = _storage.startIndex + _mStrideOffset(for: range.lowerBound)
//        let endIndex = _storage.startIndex + _mStrideOffset(for: range.upperBound)
//        return _storage[startIndex..<endIndex]
//    }
//    
}
