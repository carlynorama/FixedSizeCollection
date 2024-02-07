//
//  Replace.swift
//  
//
//  Created by Carlyn Maw on 2/6/24.
//

import Foundation

extension FixedSizeCollection {
    
    @inlinable
    mutating
    public func replace(at position:N, with newValue:Element) {
        guard _checkSubscript(position) else {
          //TODO: What's the right error
          fatalError()
        }
        let startIndex = _storage.startIndex + _mStrideOffset(for: position)
        let endIndex = startIndex + _mStrideElem
        Swift.withUnsafePointer(to: newValue) { sourceValuePointer in
          _storage.replaceSubrange(
            startIndex..<endIndex, with: sourceValuePointer, count: _mStrideElem)
        }
    }
    
    
    @inlinable
    mutating
    public func replace(at range: Range<N>, with newValue: [Element]) {
        //TODO: Write actual range check subscript?
        guard _checkSubscript(range) else {
          //TODO: What's the right error
          fatalError("subscript invalid")
        }
        guard range.count == newValue.count else {
          fatalError("replacement value doesn't match range")
        }
        suncReplacingSubrange(range: range, with: newValue)
    }
    
    @inlinable
    mutating
    public func replace(at range: Range<N>, with newValue: Element) {
        //TODO: Write actual range check subscript?
        guard _checkSubscript(range) else {
          //TODO: What's the right error
          fatalError("subscript invalid")
        }
        //TODO: Implementation without patch array & compare speed
        let patch_array = Array(repeating: newValue, count:range.count)
        guard range.count == patch_array.count else {
          fatalError("replacement value doesn't match range")
        }
        suncReplacingSubrange(range: range, with: patch_array)
    }
}

extension FixedSizeCollection where Element:Equatable {
    @inlinable
    mutating
    public func replace(first indexFlag: Element, with newValue: Element) throws {
        let idx = try self.withUnsafeMutableBufferPointer{ bufferPointer in
            if let idx = bufferPointer?.firstIndex(where: {$0 == indexFlag}) {
                return idx
            } else {
                throw FSCError.unknownError(message: "could not locate value to replace")
            }
        }
        self[idx] = newValue
    }
}
