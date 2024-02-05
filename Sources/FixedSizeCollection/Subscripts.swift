//
//  Subscripts.swift
//
//
//  Created by Carlyn Maw on 2/4/24.
//

import Foundation


public extension FixedSizeCollection {
    
    //@_borrowed ? https://github.com/apple/swift/blob/main/stdlib/public/core/Collection.swift#L425C3-L425C13
    @inlinable
    subscript(_ position: Int) -> Element {
        get {
            guard _checkSubscript(position) else {
                //TODO: What's the right error
                fatalError()
            }
            return _storage.withUnsafeBytes { rawPointer in
                let bufferPointer = rawPointer.assumingMemoryBound(to: Element.self)
                return bufferPointer[position]
            }
        }
        set {
            guard _checkSubscript(position) else {
                //TODO: What's the right error
                fatalError()
            }
            let startIndex = _storage.startIndex + _mStrideOffset(for: position)
            let endIndex = startIndex + _mStrideElem
            Swift.withUnsafePointer(to: newValue) { sourceValuePointer in
                _storage.replaceSubrange(startIndex..<endIndex, with: sourceValuePointer, count: _mStrideElem)
            }
        }
    }

    
    //TODO: redo as indices and subsequence?
    
    //TODO: //@inlinable can't be used with defaultValue
    //can't make inlineable if use self.defaultValue
    //more ergonomic to pass along existing, but what is the speed hit.
    //if a subsequence does that fix that?
    subscript(_ r:Range<N>) ->  [Element] {
        get {
            guard _checkSubscript(r) else {
                //TODO: What's the right error
                fatalError("subscript invalid")
            }
            return guncCopyRangeAsArray(r)
        }
    }
}
    
    //TODO:Subsequence and Index?
    //https://github.com/apple/swift-collections/blob/main/Sources/SortedCollections/SortedSet/SortedSet%2BSubscripts.swift
    
    //    @inlinable
        //where Element:Comparable
    //    public subscript(range: Range<Element>) -> SubSequence {
    //      let start = _root.startIndex(forKey: range.lowerBound)
    //      let end = _root.startIndex(forKey: range.upperBound)
    //      let range = _Tree.SubSequence(base: _root, bounds: start..<end)
    //      return SubSequence(range)
    //    }
    //    @inlinable
    //    public subscript(bounds: Range<Index>) -> SubSequence {
    //      bounds.lowerBound._index.ensureValid(forTree: self._root)
    //      bounds.upperBound._index.ensureValid(forTree: self._root)
    //      let bounds = bounds.lowerBound._index ..< bounds.upperBound._index
    //      return SubSequence(_root[bounds])
    //    }
    //
    
