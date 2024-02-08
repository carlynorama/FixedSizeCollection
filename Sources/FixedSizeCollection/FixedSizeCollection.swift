//
//  FixedSizeCollection.swift
//  TestingTwo
//
//  Created by Carlyn Maw on 2/2/24.

import Foundation

//Unresolved. Should perhaps be N:Int in the generic.
public struct FixedSizeCollection<Element>: RandomAccessCollection {
  public typealias N = Int
  public typealias _Storage = Data  //Could be buffer or storage some day.
  //TODO: how to set this up to be a StorageView once available.

  public let count: N  //Unresolved. Int, UInt, CInt... For now starting with Int.
  public var startIndex: Int { 0 }
  public var endIndex: Int { count }

  @inlinable
  public var range: Range<N> { 0..<count }

  //What is the best storage type?

  //Data good for prototyping
  @usableFromInline
  internal var _storage: _Storage

}
//MARK: Inits
extension FixedSizeCollection {

  //TODO: Should these be [Element] or of some Collection<Element>
  //Best for ergonomics? Easiest for complexity?
  //How to make sure that all the Data looks like the same type of
  //Collection of Elements when getting the bytes.

  //----- Explicit Count

  //Truncates.
  //TODO: probably should ask what the desired behavior is.
  public init(_ count: Int, fillValue d: Element, values: [Element]) {
    self.count = count
    var result = values.prefix(count)
    //if result.count > count { return nil }
    for _ in 0..<(count - result.count) {
      result.append(d)
    }
    self._storage = result.withUnsafeMutableBufferPointer { pointer in
      Data(buffer: pointer)
    }

      do {
          let _ = try Self._verifyCount(of: _storage, expectedCount: count)
      }
      catch {
          preconditionFailure("storage size verification failed.")
      }
  }

  @inlinable
  static func makeFixedSizeCollection(count: N, fillValue d: Element, values: [Element])
    -> FixedSizeCollection
  {
    Self.init(count, fillValue: d, values: values)
  }

  public init(_ count: Int, fillValue d: Element, initializer: () -> [Element] = { [] }) {
    self = Self.init(count, fillValue: d, values: initializer())
  }

  public init(_ count: Int, fillValue d: Element, values: Element...) {
    self = Self.init(count, fillValue: d, values: values)
  }

  //Implies a potential "asView" (fingers crossed.)

  // ---- Inferred Count

  public init(_ values: [Element]) {
    var tmp = values
    self._storage = tmp.withUnsafeMutableBufferPointer { pointer in
      Data(buffer: pointer)
    }
    self.count = values.count

      do {
          let _ = try Self._verifyCount(of: _storage, expectedCount: count)
      }
      catch {
          preconditionFailure("storage size verification failed.")
      }
  }

  @inlinable
  static func makeFixedSizeCollection(_ values: [Element]) -> FixedSizeCollection {
    Self.init(values)
  }

  public init(fillValue d: Element? = nil, initializer: () -> [Element]) {
    self = Self.makeFixedSizeCollection(initializer())
  }

  public init(_ values: Element...) {
    self = Self.makeFixedSizeCollection(values)
  }

  //Implies a potential "asView" (fingers crossed.)
  public init(asCopy pointer: UnsafeBufferPointer<Element>) {
    self._storage = Data(buffer: pointer)
    self.count = pointer.count

      do {
          let _ = try Self._verifyCount(of: _storage, expectedCount: count)
      }
      catch {
          preconditionFailure("storage size verification failed.")
      }
  }

  public init<T>(asCopyOfTuple source: T, ofType: Element.Type) {
    //There is a safer version that goes through array.
    //It confirms the type.
    //_get(valueOfType:from:(repeat each T)), but it's
    //causing compiler crashed when used with init.
    //TODO: figure out how to make an init with a Parameter Pack tuple that doesn't crash.
    let tmp = Self._getAssuming(valuesBoundTo: Element.self, from: source)
    self = Self.makeFixedSizeCollection(tmp)
    do {
      let _ = try Self._verifyCount(of: source, expectedCount: self.count)
    } catch {
      assertionFailure(
        "tuple count and collection count don't match. tuple was likely not homogenous or not of the type indicated."
      )
    }
  }

  internal
    init(storage: _Storage, as: Element.Type, count: N, fillValue d: Element? = nil)
  {
    self._storage = storage
    self.count = count

      do {
          let _ = try Self._verifyCount(of: _storage, expectedCount: count)
      }
      catch {
          preconditionFailure("storage size verification failed.")
      }

  }

}

//What is the better way?
//extension FixedSizeCollection where Element:OptionalProtocol {
//    //TODO: should throw? return the Optional(index) of the insert?
//    //TODO: What does nil look like in the Data buffer
//    func insert(_ newValue:Element)  {
//        print(dataBlob)
//        print(newValue)
//        dataBlob.withUnsafeBytes { rawPointer in
//            if var tmp = rawPointer.baseAddress?.load(as: [Element].self) {
//                //TODO: Make this work.
//                if let i = tmp.firstIndex(where: {$0.isNil()}) {
//                    tmp[i] = newValue
//                }
//            }
//        }
//    }
//}

//
//protocol OptionalProtocol {
//  // the metatype value for the wrapped type.
//  static var wrappedType: Any.Type { get }
//    func isNil() -> Bool
//}
//
//extension OptionalProtocol {
//
//}
//
//extension Optional : OptionalProtocol {
//  static var wrappedType: Any.Type { return Wrapped.self }
//    func isNil() -> Bool {
//        self == nil
//    }
//}
