//
//  InitsNStorage.swift
//
//
//  Created by Carlyn Maw on 2/5/24.
//

import XCTest

@testable import FixedSizeCollection

//MARK: Inits & Sotrage Support

final class InitsNStorage: XCTestCase {

  func testFunctionInits() {
    let numericDefault = FixedSizeCollection(4, fillValue: 12) { [1, 2, 3] }
    XCTAssertEqual(numericDefault[0], 1, "0 incorrect")
    XCTAssertEqual(numericDefault[1], 2, "1 incorrect")
    XCTAssertEqual(numericDefault[2], 3, "2 incorrect")
    XCTAssertEqual(numericDefault[3], 12, "3 incorrect")

    let optionalDefault = FixedSizeCollection<Int?>(5, fillValue: nil) { [1, 2, 3] }
    XCTAssertEqual(optionalDefault[0], 1, "0 incorrect")
    XCTAssertEqual(optionalDefault[1], 2, "1 incorrect")
    XCTAssertEqual(optionalDefault[2], 3, "2 incorrect")
    XCTAssertEqual(optionalDefault[3], nil, "3 incorrect")
    XCTAssertEqual(optionalDefault[4], nil, "4 incorrect")
  }

  func testVariadicInferredInit() {
    let expectedArray = [1, 2, 3]
    let testCollection = FixedSizeCollection(1, 2, 3)
    XCTAssertEqual(expectedArray.count, testCollection.count, "count incorrect")
    for i in 0..<testCollection.count {
      XCTAssertEqual(
        testCollection[i], expectedArray[i], "\(i): no match"
      )
    }
  }

  func testVariadicExplicitCountInit() {
    let expectedArray = [1, 2, 3, nil, nil]
    let testCollection = FixedSizeCollection<Int?>(5, fillValue: nil, values: 1, 2, 3)
    XCTAssertEqual(expectedArray.count, testCollection.count, "count incorrect")
    for i in 0..<testCollection.count {
      XCTAssertEqual(
        testCollection[i], expectedArray[i], "\(i): no match"
      )
    }
  }

  func testBufferPointerInit() {
    let baseArray = [0, 1, 2, 3, 4, 5, 6]
    let testCollection: FixedSizeCollection<Int> = baseArray.withUnsafeBufferPointer {
      bufferPointer in
      return FixedSizeCollection(asCopy: bufferPointer)
    }
    for i in 0..<testCollection.count {
      XCTAssertEqual(
        testCollection[i], baseArray[i], "\(i): no match")
    }
  }

  func testInitFromTuple() throws {
    let baseTuple = (45, 27, 83, 26, 44, 98, 5)

    let tmpArray = FixedSizeCollection<Int>._getAssuming(
      valuesBoundTo: Int.self, from: baseTuple)
    let tC = FixedSizeCollection.makeFixedSizeCollection(
      count: tmpArray.count, fillValue: 0, values: tmpArray)

    XCTAssertEqual(tC[0], baseTuple.0, "0: no match")
    XCTAssertEqual(tC[1], baseTuple.1, "1: no match")
    XCTAssertEqual(tC[2], baseTuple.2, "2: no match")
    XCTAssertEqual(tC[3], baseTuple.3, "3: no match")
    XCTAssertEqual(tC[4], baseTuple.4, "4: no match")
    XCTAssertEqual(tC[5], baseTuple.5, "5: no match")
    XCTAssertEqual(tC[6], baseTuple.6, "6: no match")

    let testCT = FixedSizeCollection(asCopyOfTuple: baseTuple, ofType: Int.self)

    XCTAssertEqual(testCT[0], baseTuple.0, "0: no match")
    XCTAssertEqual(testCT[1], baseTuple.1, "1: no match")
    XCTAssertEqual(testCT[2], baseTuple.2, "2: no match")
    XCTAssertEqual(testCT[3], baseTuple.3, "3: no match")
    XCTAssertEqual(testCT[4], baseTuple.4, "4: no match")
    XCTAssertEqual(testCT[5], baseTuple.5, "5: no match")
    XCTAssertEqual(testCT[6], baseTuple.6, "6: no match")

  }

  func testExplicitCountCode() {
    let testValues = [0, 1, 2, 3, 4, 5, 6]
    let count = 15
    let _defaultValue = 0
    var result = testValues.prefix(count)
    //if result.count > count { return nil }
    for _ in 0..<(count - result.count) {
      result.append(_defaultValue)
    }
    let _storage = result.withUnsafeMutableBufferPointer { pointer in
      Data(buffer: pointer)
    }

    XCTAssertEqual(
      count, _storage.count / MemoryLayout<Int>.stride, "count and storage size didn't work")

    //current code of getVerifiedCount
    typealias Element = Int
    let gVC = _storage.withUnsafeBytes { bytes in
      let tmpCount = bytes.count / MemoryLayout<Element>.stride
      XCTAssertEqual(tmpCount * MemoryLayout<Element>.stride, bytes.count, "bytes wrong.")
      XCTAssert(
        Int(bitPattern: bytes.baseAddress).isMultiple(of: MemoryLayout<Element>.alignment)
      )
      return tmpCount
    }

    //testValues are Ints.
    XCTAssertEqual(count, gVC, "count and storage size didn't work")

    do {
      let _ = try FixedSizeCollection<Int>._verifyCount(of: _storage, expectedCount: count)
    } catch {
      XCTFail("storage size verification failed.")
    }

  }

  func testInferredCountCode() throws {
    let testValues = [0, 1, 2, 3, 4, 5, 6]
    let count = testValues.count

    var tmp = testValues
    let _storage = tmp.withUnsafeMutableBufferPointer { pointer in
      Data(buffer: pointer)
    }

    XCTAssertEqual(
      count, _storage.count / MemoryLayout<Int>.stride, "count and storage size didn't work")

    //current code of getVerifiedCount
    typealias Element = Int
    let gVC = _storage.withUnsafeBytes { bytes in
      let tmpCount = bytes.count / MemoryLayout<Element>.stride
      XCTAssertEqual(tmpCount * MemoryLayout<Element>.stride, bytes.count, "bytes wrong.")
      XCTAssert(
        Int(bitPattern: bytes.baseAddress).isMultiple(of: MemoryLayout<Element>.alignment)
      )
      return tmpCount
    }

    //testValues are Ints.
    XCTAssertEqual(count, gVC, "count and storage size didn't work")

    do {
      let _ = try FixedSizeCollection<Int>._verifyCount(of: _storage, expectedCount: count)
    } catch {
      XCTFail("storage size verification failed.")
    }

  }

}
