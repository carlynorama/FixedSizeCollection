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
    
    
    func testFunctionInits() {
        let numericDefault = FixedSizeCollection(4, defaultsTo: 12) { [1, 2, 3] }
        XCTAssertEqual(numericDefault[0], 1, "collection 0 incorrect")
        XCTAssertEqual(numericDefault[1], 2, "collection 1 incorrect")
        XCTAssertEqual(numericDefault[2], 3, "collection 2 incorrect")
        XCTAssertEqual(numericDefault[3], 12, "collection 3 incorrect")
        
        let optionalDefault = FixedSizeCollection<Int?>(5, defaultsTo: nil) { [1, 2, 3] }
        XCTAssertEqual(optionalDefault[0], 1, "collection 0 incorrect")
        XCTAssertEqual(optionalDefault[1], 2, "collection 1 incorrect")
        XCTAssertEqual(optionalDefault[2], 3, "collection 2 incorrect")
        XCTAssertEqual(optionalDefault[3], nil, "collection 3 incorrect")
        XCTAssertEqual(optionalDefault[4], nil, "collection 4 incorrect")
    }
    
    func testVariadicInferredInit() {
        let expectedArray = [ 1, 2, 3 ]
        let testCollection = FixedSizeCollection(1,2,3)
        XCTAssertEqual(expectedArray.count, testCollection.count, "collection 4 incorrect")
        for i in 0..<testCollection.count {
            XCTAssertEqual(
                testCollection[i], expectedArray[i], "inferred count array wrong at \(i)"
            )
        }
    }
        
    func testVariadicExplicitCountInit() {
        let expectedArray = [ 1, 2, 3, nil, nil ]
        let testCollection = FixedSizeCollection<Int?>(5, defaultsTo: nil, 1,2,3)
        XCTAssertEqual(expectedArray.count, testCollection.count, "collection 4 incorrect")
        for i in 0..<testCollection.count {
            XCTAssertEqual(
                testCollection[i], expectedArray[i], "explicit count array wrong at \(i)"
            )
        }
    }
    
    func testBufferPointerInit() {
        let baseArray = [ 0, 1, 2, 3, 4, 5, 6]
        let testCollection:FixedSizeCollection<Int> = baseArray.withUnsafeBufferPointer { bufferPointer in
            return FixedSizeCollection(asCopy: bufferPointer, defaultsTo: 0)
        }
        for i in 0..<testCollection.count {
            XCTAssertEqual(
                testCollection[i], baseArray[i], "collection did not retrieve expected value")
        }
    }
    
    func testExplicitCountCode() {
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
