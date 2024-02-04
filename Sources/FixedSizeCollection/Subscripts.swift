//
//  Subscripts.swift
//
//
//  Created by Carlyn Maw on 2/4/24.
//

import Foundation


public extension FixedSizeCollection {
    
    //@_borrowed ? https://github.com/apple/swift/blob/main/stdlib/public/core/Collection.swift#L425C3-L425C13
    subscript(position: Int) -> Element {
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
            let startIndex = _storage.startIndex + position * _mStrideElem
            let endIndex = startIndex + _mStrideElem
            Swift.withUnsafePointer(to: newValue) { sourceValuePointer in
                _storage.replaceSubrange(startIndex..<endIndex, with: sourceValuePointer, count: _mStrideElem)
            }
        }
    }
}
