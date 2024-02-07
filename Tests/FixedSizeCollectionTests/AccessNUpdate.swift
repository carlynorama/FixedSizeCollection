// XCTest Documentation
// https://developer.apple.com/documentation/xctest

// Defining Test Cases and Test Methods
// https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods

import XCTest
@testable import FixedSizeCollection

final class AccessingAndUpdating: XCTestCase {
    
    //MARK: Bounds Checkers
    func testFastContainsInt() {
        let h = 50, l = -4
        let valuesToTest = Array(l-h...h+h)
        for _ in 0...100 {
            let i = valuesToTest.randomElement()!
            XCTAssertEqual(FixedSizeCollection<Int>.fastContains(l:l, h:h, x:i), (l..<h).contains(i), "fastContains and .contains not same result" )
        }
    }
    
    //MARK: Getters
    
    func testIndividualAccess() {
        let baseArray = [1, 2, 3, 7]
        let testCollection = FixedSizeCollection<Int?>(baseArray.count, defaultsTo: nil) { baseArray }
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
        let testCollection = FixedSizeCollection<Int>(5, defaultsTo: exptdValue)
        measure {
            testCollection.forEach {
                XCTAssertEqual($0, exptdValue, "did not retrieve expected value")
            }
        }
    }
    
    func testUpdateForIn() {
        let exptdValue = 34
        let testCollection = FixedSizeCollection<Int>(5, defaultsTo: exptdValue)
        measure {
            for item in testCollection {
                XCTAssertEqual(item, exptdValue, "did not retrieve expected value")
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
            tC.suncReplacingSubrange(range: range, with: newValue)
            for i in 0..<expectedArray.count {
                XCTAssertEqual(
                    tC[i], expectedArray[i], "did not retrieve expected value at \(i)")
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
        let baseArray = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        //let baseArray = [1, 2, 3, 7]
        var testCollection = FixedSizeCollection<Int> { baseArray }
        let newVar = Int.random(in: 0...100)
        //TODO: how to measure throwing functions
        try testCollection.replace(first: 3, with: newVar)
        XCTAssertEqual(testCollection[4], newVar, "did not update correctly at position 4")
    }
    
    func testReplaceRwR() throws {
        let baseArray: [Int32] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        let expectedArray: [Int32] = [0, 1, 44, 43, 42, 5, 6, 7, 8, 9]
        let newValue: [Int32] = [44, 43, 42]
        let range = (2..<5)
        //let baseArray = [1, 2, 3, 7]
        var tC = FixedSizeCollection<Int32> { baseArray }
        measure {
            tC.replace(at: range, with: newValue)
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
            tC.replace(at: range, with: newValue)
            for i in range {
                XCTAssertEqual(
                    tC[i], 63, "did not retrieve expected value at \(i)")
            }
        }
    }
    
    
}
