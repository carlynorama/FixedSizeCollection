//
//  Copy.swift
//
//
//  Created by Carlyn Maw on 2/4/24.
//

extension FixedSizeCollection {
  //TODO: currently unchecked, because _checkSubscript(range)
  //would not catch a desync between _storage and count.
  public func copyValuesAsArray() throws -> [Element] {
    guncCopyRangeAsArray(0..<count)
  }

  //Same as current subscript.
  public func copyValuesAsArray(range: Range<N>) throws -> [Element] {
    guard _checkSubscript(range) else {
      throw FSCError.outOfRange
    }
    return guncCopyRangeAsArray(range)
  }
}
