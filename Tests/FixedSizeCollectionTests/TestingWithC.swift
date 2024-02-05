// XCTest Documentation
// https://developer.apple.com/documentation/xctest

// Defining Test Cases and Test Methods
// https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods

import XCTest

@testable import FixedSizeCollection
@testable import TestSwiftBridge
@testable import TestCSupport

final class WithCTests: XCTestCase {
    
    
    //    func storagePointerPrint() throws {
    //        try FixedSizeCollection<CInt>.storageInout()
    //    }
    
    
    func rawBufferPointerPrint() throws {
        try FixedSizeCollection<CInt>.rawBufferPointerPrint()
    }
    
    func mutableRawBufferPointerPrint() throws {
        try FixedSizeCollection<CInt>.mutableRawBufferPointerPrint()
    }
    
    func boundBufferPointerPrint() throws {
        try FixedSizeCollection<CInt>.boundBufferPointerPrint()
    }
    
    func boundMutableBufferPointerPrint() throws {
        try FixedSizeCollection<CInt>.boundMutableBufferPointerPrint()
    }
    
    func boundPointerPrint() throws {
        try FixedSizeCollection<CInt>.boundPointerPrint()
    }
    
    func boundMutablePointerPrint() throws {
        try FixedSizeCollection<CInt>.boundMutablePointerPrint()
    }
    
    
    func testPointerPassing() {
        //swift test --filter WithCTests.testPointerPassing
        //https://developer.apple.com/documentation/swift/calling-functions-with-pointer-parameters
        //https://github.com/apple/swift/pull/15543
        
        func takesAnUnsafePointer(_ p: UnsafePointer<CInt>?)  {
            // ...
        }
        
        func takesAnUnsafeMutablePointer(_ p: UnsafeMutablePointer<CInt>?)  {
            // ...
        }
        
        //void acknowledge_int_buffer(int* array, const size_t n);
        //void acknowledge_int_buffer_const(const int* values, const size_t n);
        
        
        
        let constIntArray: [CInt] = [1, 2, 3]
        let constIntAlone: CInt = 42
        var mIntArray: [CInt] = [2, 4, 6]
        var mIntAlone: CInt = 84
        
        // ---------------------------------------------------------------------
        // ----------------------- const + swift
        
        //takesAnUnsafePointer(constIntAlone) //<= failed when array didn't
        takesAnUnsafePointer(constIntArray) //pass
        
        //takesAnUnsafeMutablePointer(&constIntAlone) //expected fail
        //takesAnUnsafeMutablePointer(&constIntArray) //expected fail
        
        // ---------------------------------------------------------------------
        // ----------------------- mutable + swift
        //takesAnUnsafePointer(mIntAlone) //<= failed when array didn't
        takesAnUnsafePointer(mIntArray)  //pass
        
        takesAnUnsafeMutablePointer(&mIntAlone) //<= inconsistent but appreciated pass
        takesAnUnsafeMutablePointer(&mIntArray) //pass
        
        // ---------------------------------------------------------------------
        // ----------------------- const + C
        
        //void acknowledge_cint_buffer_const(const int* values, const size_t n);
        
        //error: cannot convert value of type 'CInt' (aka 'Int32')
        //to expected argument type 'UnsafePointer<Int32>?'
        
        //acknowledge_cint_buffer_const(constIntAlone, 1) //<= consistent fail
        
        //error: cannot pass immutable value as inout argument:
        //'constIntAlone' is a 'let' constant
        
        acknowledge_cint_buffer_const(constIntArray, 3) //<= C treated as inout
        //                                                //   unlike the Swift
        
        //error: cannot pass immutable value as inout argument:
        //'constIntArray'/'constIntAlone' is a 'let' constant
        
        //(&constIntAlone, 1) //expected fail
        //acknowledge_cint_buffer(&constIntArray, 3) //expected fail
        
        // ---------------------------------------------------------------------
        // ----------------------- mutable + C
        
        //error: cannot convert value of type 'CInt' (aka 'Int32')
        //to expected argument type 'UnsafePointer<Int32>?'
        
        //acknowledge_cint_buffer_const(mIntAlone, 1) //<= consistent fail
        
        
        acknowledge_cint_buffer_const(mIntArray, 3) //<= newly unexpected fail
        
        acknowledge_cint_buffer(&mIntAlone, 1) //<= inconsistent but appreciated pass
        acknowledge_cint_buffer(&mIntArray, 3)
        
        XCTAssertEqual(5, 5, "everything's fine.")
    }
}
