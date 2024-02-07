// XCTest Documentation
// https://developer.apple.com/documentation/xctest

// Defining Test Cases and Test Methods
// https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods

import XCTest

@testable import FixedSizeCollection
@testable import TestSwiftCBridge
@testable import TestCSupport

final class WithCTests: XCTestCase {
    
    
    //MARK: CArrays
    
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
    
    func testLoadIntoCArray() throws {
        //uint8_t fsc_uint8_array[27]
        let baseArray:[UInt8] = Array(repeating: UInt8.random(in: 0..<100), count: 27)
        let tC = FixedSizeCollection(values:baseArray)
        try tC.copyIntoTupleDestination(tuple:&fsc_uint8_array)
        
        XCTAssertEqual(baseArray[0], fsc_uint8_array.0, "collection did not retrieve expected value")
        XCTAssertEqual(baseArray[1], fsc_uint8_array.1, "collection did not retrieve expected value")
        XCTAssertEqual(baseArray[2], fsc_uint8_array.2, "collection did not retrieve expected value")
        XCTAssertEqual(baseArray[3], fsc_uint8_array.3, "collection did not retrieve expected value")
        XCTAssertEqual(baseArray[4], fsc_uint8_array.4, "collection did not retrieve expected value")
        XCTAssertEqual(baseArray[5], fsc_uint8_array.5, "collection did not retrieve expected value")
        XCTAssertEqual(baseArray[6], fsc_uint8_array.6, "collection did not retrieve expected value")
        XCTAssertEqual(baseArray[7], fsc_uint8_array.7, "collection did not retrieve expected value")
        XCTAssertEqual(baseArray[8], fsc_uint8_array.8, "collection did not retrieve expected value")
        XCTAssertEqual(baseArray[9], fsc_uint8_array.9, "collection did not retrieve expected value")
        XCTAssertEqual(baseArray[10], fsc_uint8_array.10, "collection did not retrieve expected value")
        XCTAssertEqual(baseArray[11], fsc_uint8_array.11, "collection did not retrieve expected value")
        XCTAssertEqual(baseArray[12], fsc_uint8_array.12, "collection did not retrieve expected value")
        XCTAssertEqual(baseArray[13], fsc_uint8_array.13, "collection did not retrieve expected value")
        XCTAssertEqual(baseArray[14], fsc_uint8_array.14, "collection did not retrieve expected value")
        XCTAssertEqual(baseArray[15], fsc_uint8_array.15, "collection did not retrieve expected value")
        XCTAssertEqual(baseArray[16], fsc_uint8_array.16, "collection did not retrieve expected value")
        XCTAssertEqual(baseArray[17], fsc_uint8_array.17, "collection did not retrieve expected value")
        XCTAssertEqual(baseArray[18], fsc_uint8_array.18, "collection did not retrieve expected value")
        XCTAssertEqual(baseArray[26], fsc_uint8_array.26, "collection did not retrieve expected value")
    }
    
    
    //MARK: Unsafe
    
    //    func storagePointerPrint() throws {
    //        try FixedSizeCollection<CInt>.storageInout()
    //    }
    
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

