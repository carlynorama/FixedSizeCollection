// XCTest Documentation
// https://developer.apple.com/documentation/xctest

// Defining Test Cases and Test Methods
// https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods

import XCTest

@testable import FixedSizeCollection

final class AccessAndProvide: XCTestCase {

  //MARK: Bounds Checkers
  func testFastContainsInt() {
    let h = 50
    let l = -4
    let valuesToTest = Array(l - h...h + h)
    for _ in 0...100 {
      let i = valuesToTest.randomElement()!
      XCTAssertEqual(
        FixedSizeCollection<Int>.fastContains(l: l, h: h, x: i), (l..<h).contains(i),
        "fastContains and .contains not same result")
    }
  }

  //MARK: Getters

  func testIndividualAccess() {
    let baseArray = [1, 2, 3, 7]
    let testCollection = FixedSizeCollection<Int?>(baseArray.count, fillValue: nil) { baseArray }
    measure {
      for i in 0..<testCollection.count {
        XCTAssertEqual(
          testCollection[i], baseArray[i], "did not retrieve expected value")
      }
    }
  }

  func testUncheckedRangedAccess() throws {
    let baseArray = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    //let baseArray = [1, 2, 3, 7]
    let testCollection = FixedSizeCollection<Int> { baseArray }
    let range = 3..<7
    let base_sub = Array(baseArray[range])
    measure {
      let tc_sub = testCollection.guncCopyRangeAsArray(range)
      for i in 0..<base_sub.count {
        XCTAssertEqual(
          tc_sub[i], base_sub[i], "did not retrieve expected value at \(i)")
      }
    }
  }

  func testCheckedRangedAccess() {
    let baseArray = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    //let baseArray = [1, 2, 3, 7]
    let testCollection = FixedSizeCollection<Int> { baseArray }
    let range = 3..<7
    let base_sub = Array(baseArray[range])
    measure {
      let tc_sub = try! testCollection.copyValuesAsArray(range: range)
      for i in 0..<base_sub.count {
        XCTAssertEqual(
          tc_sub[i], base_sub[i], "did not retrieve expected value at \(i)")
      }
    }
  }

  func testSubscriptRangedAccess() {
    let baseArray = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    //let baseArray = [1, 2, 3, 7]
    let testCollection = FixedSizeCollection<Int> { baseArray }
    let range = 3..<7
    let base_sub = Array(baseArray[range])
    measure {
      let tc_sub = testCollection[range]
      for i in 0..<base_sub.count {
        XCTAssertEqual(
          tc_sub[i], base_sub[i], "did not retrieve expected value at \(i)")
      }
    }
  }
  func testForEach() {
    let exptdValue = 34
    let testCollection = FixedSizeCollection<Int>(5, fillValue: exptdValue)
    measure {
      testCollection.forEach {
        XCTAssertEqual($0, exptdValue, "did not retrieve expected value")
      }
    }
  }

  func testUpdateForIn() {
    let exptdValue = 34
    let testCollection = FixedSizeCollection<Int>(5, fillValue: exptdValue)
    measure {
      for item in testCollection {
        XCTAssertEqual(item, exptdValue, "did not retrieve expected value")
      }
    }
  }

}
