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
    
}