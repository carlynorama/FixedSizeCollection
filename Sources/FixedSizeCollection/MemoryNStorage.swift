//
//  MemoryNStroage.swift
//
//
//  Created by Carlyn Maw on 2/6/24.
//

import Foundation

//TODO: What is a DependenceToken used for (as seen in Array)
extension FixedSizeCollection {

  //TellowKrinkle via Swift Forums, See TODO for link
  @inlinable
  internal static func fastContains(l: N, h: N, x: N) -> Bool {
    //TODO: for what values of N will this work? Any Numeric?
    UInt(bitPattern: x &- l) < UInt(bitPattern: h - l)
  }

  @inlinable
  internal func _checkSubscript(_ position: N) -> Bool {
    Self.fastContains(l: 0, h: count, x: position)
  }

  @inlinable
  internal func _checkSubscript(_ range: Range<N>) -> Bool {
    if range == self.range {
      return true
    } else {
      //Note: fC and .contains fail when range == self.range
      return Self.fastContains(l: 0, h: count, x: range.lowerBound)
        && Self.fastContains(l: 0, h: count, x: range.upperBound)
    }
  }

}

//MARK: Storage Helpers
extension FixedSizeCollection {

  @inlinable
  static func _verifyCount(of storage: _Storage, expectedCount: N? = nil) throws -> N {
    let count = storage.withUnsafeBytes { bytes in
      let tmpCount = bytes.count / MemoryLayout<Element>.stride
      precondition(tmpCount * MemoryLayout<Element>.stride == bytes.count)
      precondition(
        Int(bitPattern: bytes.baseAddress).isMultiple(of: MemoryLayout<Element>.alignment))
      return tmpCount
    }
    if expectedCount != nil, expectedCount != count {
      throw FSCError.unknownError(
        message: "_Storage's expected and calculated counts not the same.")
    }
    return count
  }

  static internal func _erasedVerifyCount<U, T>(
    of item: U, boundTo: T.Type, expectedCount: Int? = nil
  ) throws -> Int {
    let count = Swift.withUnsafeBytes(of: item) { bytes in
      let tmpCount = bytes.count / MemoryLayout<Int32>.stride
      precondition(tmpCount * MemoryLayout<Int32>.stride == bytes.count)
      precondition(
        Int(bitPattern: bytes.baseAddress).isMultiple(of: MemoryLayout<Int32>.alignment))
      return tmpCount
    }
    if expectedCount != nil, expectedCount != count {
      throw FSCError.unknownError(
        message: "_Storage's expected and calculated counts not the same.")
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

}
