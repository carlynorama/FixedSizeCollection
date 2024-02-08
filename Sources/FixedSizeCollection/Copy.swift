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
    guncCopyRangeAsArray(self.range)
  }

  //Same as current subscript.
  public func copyValuesAsArray(range: Range<N>) throws -> [Element] {
    guard _checkSubscript(range) else {
      throw FSCError.outOfRange
    }
    return guncCopyRangeAsArray(range)
  }

  //TODO: Force user to confirm the type explicitly or no?
  public func copyIntoTupleDestination<U>(tuple: inout U) throws {
    //checks are in _load function
    let tupleCount = try Self._confirmSizeOfTuple(tuple: tuple)
    try _loadIntoTuple(tuple: &tuple, count: tupleCount, type: Element.self)
  }
}
