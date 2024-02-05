// XCTest Documentation
// https://developer.apple.com/documentation/xctest

// Defining Test Cases and Test Methods
// https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods

import XCTest

@testable import FixedSizeCollection

final class FixedSizeCollectionTests: XCTestCase {

  //MARK: Getters
  func testBasicInitWithDefault() {
    let testCollection = FixedSizeCollection(4, defaultsTo: 12) { [1, 2, 3] }
    XCTAssertEqual(testCollection[0], 1, "collection 0 incorrect")
    XCTAssertEqual(testCollection[1], 2, "collection 1 incorrect")
    XCTAssertEqual(testCollection[2], 3, "collection 2 incorrect")
    XCTAssertEqual(testCollection[3], 12, "collection 3 incorrect")

  }

  func testBasicInitWithOptional() {
    let testCollection = FixedSizeCollection<Int?>(5, defaultsTo: nil) { [1, 2, 3] }
    XCTAssertEqual(testCollection[0], 1, "collection 0 incorrect")
    XCTAssertEqual(testCollection[1], 2, "collection 1 incorrect")
    XCTAssertEqual(testCollection[2], 3, "collection 2 incorrect")
    XCTAssertEqual(testCollection[3], nil, "collection 3 incorrect")
    XCTAssertEqual(testCollection[4], nil, "collection 3 incorrect")
  }

  func testIndividualAccess() {
    let baseArray = [1, 2, 3, 7]
    let testCollection = FixedSizeCollection<Int?>(baseArray.count, defaultsTo: nil) { baseArray }
    measure {
      for i in 0..<testCollection.count {
        XCTAssertEqual(
          testCollection[i], baseArray[i], "collection did not retrieve expected value")
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
          tc_sub[i], base_sub[i], "collection sub range did not retrieve expected value")
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
          tc_sub[i], base_sub[i], "collection sub range did not retrieve expected value")
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
          tc_sub[i], base_sub[i], "collection sub range did not retrieve expected value")
      }
    }
  }

  //MARK: Setters

  func testUpdateIndividual() {
    var testCollection = FixedSizeCollection<Int>(5, defaultsTo: 0)
    measure {
      for i in 0..<testCollection.count {
        let newVar = Int.random(in: 0...100)
        testCollection[i] = newVar
        XCTAssertEqual(testCollection[i], newVar, "collection did not update correctly")
      }
    }
  }

  func testUpdateForEach() {
    let exptdValue = 34
    let testCollection = FixedSizeCollection<Int>(5, defaultsTo: exptdValue)
    measure {
      testCollection.forEach {
        XCTAssertEqual($0, exptdValue, "collection did not retrieve expected value")
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
      tC.suncReplacingSubrange(range: range, with: newValue)
      for i in 0..<expectedArray.count {
        XCTAssertEqual(
          tC[i], expectedArray[i], "collection sub range did not retrieve expected value")
      }
    }
  }

  func testSubscriptRangedUpdate() {
    let baseArray: [Int32] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    let expectedArray: [Int32] = [0, 1, 44, 43, 42, 5, 6, 7, 8, 9]
    let newValue: [Int32] = [44, 43, 42]
    let range = (2..<5)
    //let baseArray = [1, 2, 3, 7]
    var tC = FixedSizeCollection<Int32> { baseArray }
    measure {
      tC[range] = newValue
      for i in 0..<expectedArray.count {
        XCTAssertEqual(
          tC[i], expectedArray[i], "collection sub range did not retrieve expected value")
      }
    }
  }

}
