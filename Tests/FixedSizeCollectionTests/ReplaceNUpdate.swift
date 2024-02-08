//
//  ReplaceNUpdate.swift
//
//
//  Created by Carlyn Maw on 2/7/24.
//

import XCTest

@testable import FixedSizeCollection

final class ReplaceNUpdate: XCTestCase {

  //MARK: Setters

  func testUpdateIndividual() {
    var testCollection = FixedSizeCollection<Int>(5, fillValue: 0)
    measure {
      for i in 0..<testCollection.count {
        let newVar = Int.random(in: 0...100)
        testCollection[i] = newVar
        XCTAssertEqual(testCollection[i], newVar, "did not update correctly at \(i)")
      }
    }
  }

  func testSuncRangedUpdate() {
    let baseArray: [Int32] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    let expectedArray: [Int32] = [0, 1, 44, 43, 42, 5, 6, 7, 8, 9]
    let newValue: [Int32] = [44, 43, 42]
    let range = (2..<5)
    //let baseArray = [1, 2, 3, 7]
    var tC = FixedSizeCollection<Int32> { baseArray }
    measure {
      tC._suncReplacingSubrange(range: range, with: newValue)
      for i in 0..<expectedArray.count {
        XCTAssertEqual(
          tC[i], expectedArray[i], "did not retrieve expected value at \(i)")
      }
    }
  }

  func testSubscriptRangedUpdate() {
    let baseArray: [Int32] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    let expectedArray: [Int32] = [0, 1, 2, 3, 44, 43, 42, 7, 8, 9]
    let newValue: [Int32] = [44, 43, 42]
    let range = (4..<7)
    //let baseArray = [1, 2, 3, 7]
    var tC = FixedSizeCollection<Int32> { baseArray }
    measure {
      tC[range] = newValue
      for i in 0..<expectedArray.count {
        XCTAssertEqual(
          tC[i], expectedArray[i], "did not retrieve expected value at \(i)")
      }
    }
  }

  func testReplaceIwE() {
    let baseArray = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    //let baseArray = [1, 2, 3, 7]
    var testCollection = FixedSizeCollection<Int> { baseArray }
    measure {
      for i in 0..<testCollection.count {
        let newVar = Int.random(in: 0...100)
        testCollection.replace(at: i, with: newVar)
        XCTAssertEqual(testCollection[i], newVar, "did not update correctly at \(i)")
      }
    }
  }

  func testReplaceFwE() throws {
    var baseArray = [12, 42, 85, 32, 41, 45, 27, 100, 18, 2]
    let testVar = baseArray[Int.random(in: 0..<baseArray.count)]
    let expectedIndex = baseArray.firstIndex(of: testVar)!
    //let baseArray = [1, 2, 3, 7]
    var testCollection = FixedSizeCollection<Int> { baseArray }
    let newVar = Int.random(in: 0...100)
    //TODO: how to measure throwing functions
    try testCollection.replace(first: testVar, with: newVar)
    baseArray[expectedIndex] = newVar
    for i in 0..<baseArray.count {
      XCTAssertEqual(
        testCollection[i], baseArray[i], "\(i) is \(testCollection[i]), expected \(baseArray[i])")
    }
  }

  func testReplaceRwR() throws {
    let baseArray: [Int32] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    let expectedArray: [Int32] = [0, 1, 44, 43, 42, 5, 6, 7, 8, 9]
    let newValue: [Int32] = [44, 43, 42]
    let range = (2..<5)
    //let baseArray = [1, 2, 3, 7]
    var tC = FixedSizeCollection<Int32> { baseArray }
    measure {
      tC.replace(range, with: newValue)
      for i in 0..<expectedArray.count {
        XCTAssertEqual(
          tC[i], expectedArray[i], "did not retrieve expected value at \(i)")
      }
    }
  }

  func testReplaceRwE() throws {
    let baseArray: [Int32] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    let newValue: Int32 = 63
    let range = (2..<5)
    //let baseArray = [1, 2, 3, 7]
    var tC = FixedSizeCollection<Int32> { baseArray }
    measure {
      tC.replace(range, with: newValue)
    }
    for i in range {
      XCTAssertEqual(
        tC[i], 63, "did not retrieve expected value at \(i)")
    }
  }

  func testReplaceAll() throws {
    let baseArray: [Int32] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    let newValue: Int32 = 63

    //let baseArray = [1, 2, 3, 7]
    var tC = FixedSizeCollection<Int32> { baseArray }
    measure {
      tC.replaceAll(with: newValue)
    }
    for i in tC.range {
      XCTAssertEqual(
        tC[i], 63, "did not retrieve expected value at \(i)")
    }
  }

  func testEBIntergerClear() {
    let baseArray: [Int32] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    var tC = FixedSizeCollection<Int32> { baseArray }
    measure {
      tC.clear()
    }
    for i in 0..<tC.count {
      XCTAssertEqual(
        tC[i], 0, "did not retrieve expected value at \(i)"
      )
    }

  }

  func testEBOtionalClear() {
    let baseArray: [Int32?] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    var tC = FixedSizeCollection<Int32?> { baseArray }
    measure {
      tC.clear()
    }
    for i in 0..<tC.count {
      XCTAssertEqual(
        tC[i], nil, "did not retrieve expected value at \(i)"
      )
    }

  }

}
