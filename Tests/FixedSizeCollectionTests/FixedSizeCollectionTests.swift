// XCTest Documentation
// https://developer.apple.com/documentation/xctest

// Defining Test Cases and Test Methods
// https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods

import XCTest
@testable import FixedSizeCollection

final class FixedSizeCollectionTests: XCTestCase {
    func testBasicInitWithDefault() {
        let testCollection = FixedSizeCollection(4, default: 12) { [1, 2, 3] }
        XCTAssertEqual(testCollection[0], 1, "collection 0 incorrect")
        XCTAssertEqual(testCollection[1], 2, "collection 1 incorrect")
        XCTAssertEqual(testCollection[2], 3, "collection 2 incorrect")
        XCTAssertEqual(testCollection[3], 12, "collection 3 incorrect")
        
    }
    
    func testBasicInitWithOptional() {
        let testCollection = FixedSizeCollection<Int?>(5, default: nil) { [1, 2, 3] }
        XCTAssertEqual(testCollection[0], 1, "collection 0 incorrect")
        XCTAssertEqual(testCollection[1], 2, "collection 1 incorrect")
        XCTAssertEqual(testCollection[2], 3, "collection 2 incorrect")
        XCTAssertEqual(testCollection[3], nil, "collection 3 incorrect")
        XCTAssertEqual(testCollection[4], nil, "collection 3 incorrect")
    }
    
    func testAccess() {
        let baseArray = [1, 2, 3, 7]
        let testCollection = FixedSizeCollection<Int?>(baseArray.count, default: nil) { baseArray }
        measure {
            for i in 0..<testCollection.count {
                XCTAssertEqual(testCollection[i], baseArray[i], "collection did not retrieve expected value")
            }
        }
    }
    
    func testUpdate() {
        var testCollection = FixedSizeCollection<Int>(5, default: 0)
        measure {
            for i in 0..<testCollection.count {
                let newVar = Int.random(in: 0...100)
                testCollection[i] = newVar
                XCTAssertEqual(testCollection[i], newVar, "collection did not update correctly")
            }
        }
    }
    
    func testUpdateForEach() {
        let testCollection = FixedSizeCollection<Int>(5, default: 0)
        measure {
            testCollection.forEach {
                XCTAssertEqual($0, 0, "collection did not retrieve expected value")
            }
        }
    }
    
    //Better way to test C? 
    //TODO: Split off C to different test group.
    func testC_rawBufferPointerPrint() throws {
        try FixedSizeCollection<CInt>.rawBufferPointerPrint()
    }
    
    func testC_mutableRawBufferPointerPrint() throws {
        try FixedSizeCollection<CInt>.mutableRawBufferPointerPrint()
    }
    
    func testC_boundBufferPointerPrint() throws {
        try FixedSizeCollection<CInt>.boundBufferPointerPrint()
    }
    
    func testC_boundMutableBufferPointerPrint() throws {
        try FixedSizeCollection<CInt>.boundMutableBufferPointerPrint()
    }
    
    func testC_boundPointerPrint() throws {
        try FixedSizeCollection<CInt>.boundPointerPrint()
    }
    
    func testC_boundMutablePointerPrint() throws {
        try FixedSizeCollection<CInt>.boundMutablePointerPrint()
    }
}


