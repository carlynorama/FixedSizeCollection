//
//  Unchecked.swift
//
//
//  Created by Carlyn Maw on 2/4/24.
//

//Not NO checking of anything, just not bounds checked per access.

import Foundation

extension FixedSizeCollection {
  @inlinable
  func gunc(at position: N) -> Element {
    return _storage.withUnsafeBytes { rawPointer in
      let bufferPointer = rawPointer.assumingMemoryBound(to: Element.self)
      return bufferPointer[position]
    }
  }

  //TODO: Should this return a discardable success?
  //Not currently @inlinable as written
  @inlinable
  mutating
    func sunc(at position: N, newValue: Element)
  {
    let startIndex = _storage.startIndex + _mStrideOffset(for: position)
    let endIndex = startIndex + _mStrideElem
    Swift.withUnsafePointer(to: newValue) { sourceValuePointer in
      _storage.replaceSubrange(startIndex..<endIndex, with: sourceValuePointer, count: _mStrideElem)
    }
  }

  @inlinable
  func guncCopyRangeAsArray(_ range: Range<N>) -> [Element] {
    let sourceByteCount = _mStrideOffset(for: range.count)
    let tmp = [Element](unsafeUninitializedCapacity: sourceByteCount) {
      destBuffer, initializedCount in
      _storage.withUnsafeBytes { sourceBuffer in
        //dest, source, num
        memcpy(
          destBuffer.baseAddress,
          sourceBuffer.baseAddress?.advanced(by: _mStrideOffset(for: range.lowerBound)),
          sourceByteCount)
        initializedCount = sourceByteCount
      }
    }
    return tmp
  }

  @inlinable
  mutating
    func suncReplacingSubrange(range: Range<N>, with newValue: [Element])
  {
    let startIndex = _storage.startIndex + _mStrideOffset(for: range.lowerBound)
    let endIndex = _storage.startIndex + _mStrideOffset(for: range.upperBound)
    newValue.withUnsafeBufferPointer { bufferPointer in
      _storage.replaceSubrange(
        startIndex..<endIndex, with: bufferPointer.baseAddress!,
        count: bufferPointer.count * _mStrideElem)
    }
  }
}
