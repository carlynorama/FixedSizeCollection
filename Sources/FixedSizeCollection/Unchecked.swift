//
//  File.swift
//
//
//  Created by Carlyn Maw on 2/4/24.
//

import Foundation


public extension FixedSizeCollection {
    func gunc(at position:N) -> Element {
        return _storage.withUnsafeBytes { rawPointer in
            let bufferPointer = rawPointer.assumingMemoryBound(to: Element.self)
            return bufferPointer[position]
        }
    }
    
    //TODO: Should this return a discardable success?
    mutating
    func sunc(at position:N, newValue:Element) {
        let startIndex = _storage.startIndex + _offsetStride(itemCount: position)
        let endIndex = startIndex + _mStrideElem
        Swift.withUnsafePointer(to: newValue) { sourceValuePointer in
            _storage.replaceSubrange(startIndex..<endIndex, with: sourceValuePointer, count: _mStrideElem)
        }
    }
    
}
