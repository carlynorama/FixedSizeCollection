//
//  File.swift
//
//
//  Created by Carlyn Maw on 2/5/24.
//

import XCTest
@testable import FixedSizeCollection

//MARK: Inits & Sotrage Support

final class InitsNStorage: XCTestCase {
    
    
    func testExplictCountCode() {
        let testValues = [ 0, 1, 2, 3, 4, 5, 6]
        let count = 15
        let _defaultValue = 0
        var result = testValues.prefix(count)
        //if result.count > count { return nil }
        for _ in 0..<(count - result.count) {
            result.append(_defaultValue)
        }
        let _storage = result.withUnsafeMutableBufferPointer { pointer in
            Data(buffer: pointer)
        }
        
        XCTAssertEqual(count, _storage.count / MemoryLayout<Int>.stride, "count and storage size didn't work")
        
        //current code of getVerifiedCount
        typealias Element = Int
        let gVC = _storage.withUnsafeBytes { bytes in
                let tmpCount = bytes.count / MemoryLayout<Element>.stride
                XCTAssertEqual(tmpCount * MemoryLayout<Element>.stride, bytes.count, "bytes wrong.")
                XCTAssert(
                    Int(bitPattern: bytes.baseAddress).isMultiple(of: MemoryLayout<Element>.alignment)
                )
                return tmpCount
        }
        
        
        //testValues are Ints.
        XCTAssertEqual(count, gVC, "count and storage size didn't work")

        XCTAssertEqual(count, FixedSizeCollection<Int>.getVerifiedCount(storage:_storage), "Storage did not save the expected amount.")
    }
    
    func testInferredCountCode() {
        let testValues = [ 0, 1, 2, 3, 4, 5, 6]
        let count = testValues.count
        
        var tmp = testValues
        let _storage = tmp.withUnsafeMutableBufferPointer { pointer in
            Data(buffer: pointer)
        }
        
        XCTAssertEqual(count, _storage.count / MemoryLayout<Int>.stride, "count and storage size didn't work")
        
        //current code of getVerifiedCount
        typealias Element = Int
        let gVC = _storage.withUnsafeBytes { bytes in
            let tmpCount = bytes.count / MemoryLayout<Element>.stride
            XCTAssertEqual(tmpCount * MemoryLayout<Element>.stride, bytes.count, "bytes wrong.")
            XCTAssert(
                Int(bitPattern: bytes.baseAddress).isMultiple(of: MemoryLayout<Element>.alignment)
            )
            return tmpCount
        }
        
        
        //testValues are Ints.
        XCTAssertEqual(count, gVC, "count and storage size didn't work")
        
        XCTAssertEqual(count, FixedSizeCollection<Int>.getVerifiedCount(storage:_storage), "Storage did not save the expected amount.")
        
    }
    
    
}

