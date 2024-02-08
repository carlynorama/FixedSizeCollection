//
//  Replace.swift
//
//
//  Created by Carlyn Maw on 2/6/24.
//

import Foundation

//MARK: Replace
//lhs.count == rhs.count e.g.
//single value with single value,
//range with collection size of range.

extension FixedSizeCollection {
  @inlinable
  mutating
    public func replace(at position: N, with newValue: Element)
  {
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
    public func replace(with newValue: [Element])
  {
    replace(self.range, with: newValue)
  }

  //TODO: Why does providing default value to first param ruin recognition of element?
  @inlinable
  mutating
    public func replace(_ range: Range<N>, with newValue: [Element])
  {
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

  //TODO: RangeReplaceableCollection
  //public func replaceSubrange(_:with:) {}
  //protocol RangeReplaceableCollection<Element> : Collection where Self.SubSequence : RangeReplaceableCollection
}

extension FixedSizeCollection where Element: Equatable {
  @inlinable
  mutating
    public func replace(first indexFlag: Element, with newValue: Element) throws
  {
    let idx = try self.withUnsafeMutableBufferPointer { bufferPointer in
      if let idx = bufferPointer?.firstIndex(where: { $0 == indexFlag }) {
        return idx
      } else {
        throw FSCError.unknownError(message: "could not locate value to replace")
      }
    }
    self[idx] = newValue
  }
}

//TODO: ?? call these flood?
//lhs.count > rhs.count  e.g.
//range with single value.

extension FixedSizeCollection {
  @inlinable
  mutating
    public func replaceAll(with newValue: Element)
  {
    replace(self.range, with: newValue)
  }

  //TODO: Why does providing default value to first param ruin recognition of element?
  @inlinable
  mutating
    public func replace(_ range: Range<N>, with newValue: Element)
  {
    //TODO: Write actual range check subscript?
    guard _checkSubscript(range) else {
      //TODO: What's the right error
      fatalError("subscript invalid")
    }
    //TODO: Implementation without patch array & compare speed
    let patchArray = Array(repeating: newValue, count: range.count)
    guard range.count == patchArray.count else {
      fatalError("replacement value doesn't match range")
    }
    suncReplacingSubrange(range: range, with: patchArray)
  }

}

//MARK: Clear
//special case of replace (flood) that available on Numerics and Optionals that
//set their values back to O or nil.
//Possible future: a "HasDefault" protocol or something like that.
extension FixedSizeCollection where Element: Numeric {
  @inlinable
  mutating
    public func clear()
  {
    self._storage.resetBytes(in: _storage.startIndex..<_storage.endIndex)
  }

  @inlinable
  mutating
    public func clear(at position: N)
  {
    //checked because i is client submitted without a clear ask for unchecked
    //behavior
    replace(at: position, with: Element.zero)
  }
}

extension FixedSizeCollection where Element: ExpressibleByNilLiteral {
  @inlinable
  mutating
    public func clear()
  {
    //probably can find a faster way
    //TODO: Inspect the bytes of some Optionals set to nil
    //unchecked because self is sending the values.
    for i in self.range {
      sunc(at: i, newValue: nil)
    }
  }

  @inlinable
  mutating
    public func clear(at position: N)
  {
    //checked because i is client submitted without a clear ask for unchecked
    //behavior
    replace(at: position, with: nil)
  }
}
