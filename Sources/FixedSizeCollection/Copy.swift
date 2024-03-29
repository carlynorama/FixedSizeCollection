//
//  Copy.swift
//
//
//  Created by Carlyn Maw on 2/4/24.
//

extension FixedSizeCollection {
  //currently unchecked, because _checkSubscript(range)
  //would not catch a desync between _storage and count.
  public func copyValuesAsArray() throws -> [Element] {
    _guncCopyRangeAsArray(self.range)
  }

  //Same as current subscript.
  public func copyValuesAsArray(from range: Range<N>) throws -> [Element] {
    guard _checkSubscript(range) else {
      throw FSCError.outOfRange
    }
    return _guncCopyRangeAsArray(range)
  }

  //TODO: Force user to confirm the type explicitly or no?
  public func copyValuesInto<U>(tuple: inout U) throws {
    //checks are in _load function
    let tupleCount = try Self._verifyCount(of: tuple)
    try _load(tupleCount, bytesOfType: Element.self, into: &tuple)
  }
}
