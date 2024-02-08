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
    
    func testTupleEnforcement() throws {
        let tmp_array = FixedSizeCollection<Int32>._get(valuesBoundTo: Int32.self, from: fsc_int32_array)
        
        let tC = FixedSizeCollection(tmp_array)
        
        XCTAssertEqual(tC[0], fsc_int32_array.0, "0: no match.")
        XCTAssertEqual(tC[1], fsc_int32_array.1, "1: no match.")
        XCTAssertEqual(tC[2], fsc_int32_array.2, "2: no match.")
        XCTAssertEqual(tC[3], fsc_int32_array.3, "3: no match.")
        XCTAssertEqual(tC[4], fsc_int32_array.4, "4: no match.")
        XCTAssertEqual(tC[5], fsc_int32_array.5, "5: no match.")
        XCTAssertEqual(tC[6], fsc_int32_array.6, "6: no match.")
        
        
    }
    
    func testInitFromCArrays() {
        //uint8_t random_provider_uint8_array[27];
        //uint32_t random_provider_RGBA_array[9];
        
        let tmp_Array = FixedSizeCollection<Int32>._getFixedSizeCArrayAssumed(source: fsc_int32_array, boundToType: Int32.self)
        let tC = FixedSizeCollection.makeFixedSizeCollection(count:tmp_Array.count , fillValue: 0, values: tmp_Array)
        //print(tC.count)
        //
        XCTAssertEqual(tC[0], fsc_int32_array.0, "0: no match.")
        XCTAssertEqual(tC[1], fsc_int32_array.1, "1: no match.")
        XCTAssertEqual(tC[2], fsc_int32_array.2, "2: no match.")
        XCTAssertEqual(tC[3], fsc_int32_array.3, "3: no match.")
        XCTAssertEqual(tC[4], fsc_int32_array.4, "4: no match.")
        XCTAssertEqual(tC[5], fsc_int32_array.5, "5: no match.")
        XCTAssertEqual(tC[6], fsc_int32_array.6, "6: no match.")
        
        
        //let testCT = FixedSizeCollection(valuesOfType: Int32.self, from: fsc_int32_array)
        
        let testCT = FixedSizeCollection(asCopyOfTuple: fsc_int32_array, ofType:Int32.self)
        
        XCTAssertEqual(testCT[0], fsc_int32_array.0, "0: no match")
        XCTAssertEqual(testCT[1], fsc_int32_array.1, "1: no match")
        XCTAssertEqual(testCT[2], fsc_int32_array.2, "2: no match")
        XCTAssertEqual(testCT[3], fsc_int32_array.3, "3: no match")
        XCTAssertEqual(testCT[4], fsc_int32_array.4, "4: no match")
        XCTAssertEqual(testCT[5], fsc_int32_array.5, "5: no match")
        XCTAssertEqual(testCT[6], fsc_int32_array.6, "6: no match")
        
    }
    
    func testLoadIntoCArray() throws {
        //uint8_t fsc_uint8_array[27]
        let baseArray:[UInt8] = Array(repeating: UInt8.random(in: 0..<100), count: 27)
        let tC = FixedSizeCollection(baseArray)
        try tC.copyIntoTupleDestination(tuple:&fsc_uint8_array)
        
          XCTAssertEqual(baseArray[0], fsc_uint8_array.0, "00: no match")
          XCTAssertEqual(baseArray[1], fsc_uint8_array.1, "01: no match")
          XCTAssertEqual(baseArray[2], fsc_uint8_array.2, "02: no match")
          XCTAssertEqual(baseArray[3], fsc_uint8_array.3, "03: no match")
          XCTAssertEqual(baseArray[4], fsc_uint8_array.4, "04: no match")
          XCTAssertEqual(baseArray[5], fsc_uint8_array.5, "05: no match")
          XCTAssertEqual(baseArray[6], fsc_uint8_array.6, "06: no match")
          XCTAssertEqual(baseArray[7], fsc_uint8_array.7, "07: no match")
          XCTAssertEqual(baseArray[8], fsc_uint8_array.8, "08: no match")
          XCTAssertEqual(baseArray[9], fsc_uint8_array.9, "09: no match")
        XCTAssertEqual(baseArray[10], fsc_uint8_array.10, "10: no match")
        XCTAssertEqual(baseArray[11], fsc_uint8_array.11, "11: no match")
        XCTAssertEqual(baseArray[12], fsc_uint8_array.12, "12: no match")
        XCTAssertEqual(baseArray[13], fsc_uint8_array.13, "13: no match")
        XCTAssertEqual(baseArray[14], fsc_uint8_array.14, "14: no match")
        XCTAssertEqual(baseArray[15], fsc_uint8_array.15, "15: no match")
        XCTAssertEqual(baseArray[16], fsc_uint8_array.16, "16: no match")
        XCTAssertEqual(baseArray[17], fsc_uint8_array.17, "17: no match")
        XCTAssertEqual(baseArray[18], fsc_uint8_array.18, "18: no match")
        XCTAssertEqual(baseArray[26], fsc_uint8_array.26, "26: no match")
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

