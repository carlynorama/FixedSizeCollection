// XCTest Documentation
// https://developer.apple.com/documentation/xctest

// Defining Test Cases and Test Methods
// https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods

import XCTest

@testable import FixedSizeCollection
@testable import TestSwiftCBridge
@testable import TestCSupport

final class WithCTests: XCTestCase {
    
    
    //    func storagePointerPrint() throws {
    //        try FixedSizeCollection<CInt>.storageInout()
    //    }
    
    func testInitFromCArrays() {
        //uint8_t random_provider_uint8_array[27];
        //uint32_t random_provider_RGBA_array[9];
        
        let tmp_Array = FixedSizeCollection<Int32>._getFixedSizeCArrayAssumed(source: fsc_int32_array, boundToType: Int32.self)
        let tC = FixedSizeCollection.makeFixedSizeCollection(count:tmp_Array.count , defaultsTo: 0, values: tmp_Array)
        print(tC.count)
//
        XCTAssertEqual(tC[0], fsc_int32_array.0, "collection did not retrieve expected value")
        XCTAssertEqual(tC[1], fsc_int32_array.1, "collection did not retrieve expected value")
        XCTAssertEqual(tC[2], fsc_int32_array.2, "collection did not retrieve expected value")
        XCTAssertEqual(tC[3], fsc_int32_array.3, "collection did not retrieve expected value")
        XCTAssertEqual(tC[4], fsc_int32_array.4, "collection did not retrieve expected value")
        XCTAssertEqual(tC[5], fsc_int32_array.5, "collection did not retrieve expected value")
        XCTAssertEqual(tC[6], fsc_int32_array.6, "collection did not retrieve expected value")
        
        
        let testCT = FixedSizeCollection(asCopyOfTuple:fsc_int32_array, ofType: Int32.self)
        
        XCTAssertEqual(testCT[0], fsc_int32_array.0, "collection did not retrieve expected value")
        XCTAssertEqual(testCT[1], fsc_int32_array.1, "collection did not retrieve expected value")
        XCTAssertEqual(testCT[2], fsc_int32_array.2, "collection did not retrieve expected value")
        XCTAssertEqual(testCT[3], fsc_int32_array.3, "collection did not retrieve expected value")
        XCTAssertEqual(testCT[4], fsc_int32_array.4, "collection did not retrieve expected value")
        XCTAssertEqual(testCT[5], fsc_int32_array.5, "collection did not retrieve expected value")
        XCTAssertEqual(testCT[6], fsc_int32_array.6, "collection did not retrieve expected value")
        
    }
    
    
    func testRawBufferPointerPrint() throws {
        try FixedSizeCollection<CInt>.rawBufferPointerPrint()
    }
    
    func testMutableRawBufferPointerPrint() throws {
        try FixedSizeCollection<CInt>.mutableRawBufferPointerPrint()
    }
    
    func testBoundBufferPointerPrint() throws {
        try FixedSizeCollection<CInt>.boundBufferPointerPrint()
    }
    
    func testBoundMutableBufferPointerPrint() throws {
        try FixedSizeCollection<CInt>.boundMutableBufferPointerPrint()
    }
    
    func testBoundPointerPrint() throws {
        try FixedSizeCollection<CInt>.boundPointerPrint()
    }
    
    func testBoundMutablePointerPrint() throws {
        try FixedSizeCollection<CInt>.boundMutablePointerPrint()
    }
}

