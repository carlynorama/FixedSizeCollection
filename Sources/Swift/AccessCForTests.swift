//
//  CCallsForTests.swift
//
//
//  Created by Carlyn Maw on 2/3/24.
//


//TODO: in a package manager how to have a per file target inclusion? 
//TODO: withUnsafe are all optional pointers even though they throw? Confirm.


import Foundation
import CSupport


extension FixedSizeCollection {
    
    //TODO: Split into separate tests. [ ]
    //TODO: Check mutators do in fact mutate.
    
    
    //TODO: Try to fix &fsc, ignore direct data access.
    /*
    static func basicPrint() throws {
        var testCollection = FixedSizeCollection<Int32>(5, default: 5)
        
        //TODO: I would like for this to work. override the prefix how?
        //error: cannot convert value of type 'UnsafeMutablePointer<FixedSizeCollection<Int32>>' to expected argument type 'UnsafeMutablePointer<Int32>'
        //acknowledge_buffer(&testCollection, testCollection.count)
        
        //Expected Failure. Data doesn't know what Element is.
        //error: cannot convert value of type 'UnsafeMutablePointer<(Data)>' to expected argument type 'UnsafeMutablePointer<Int32>'
        //acknowledge_buffer(&(testCollection.dataBlob), testCollection.count)
    }
     */
    
    static func rawBufferPointerPrint() throws {
        let testCollection = FixedSizeCollection<Int32>(5, default: 5)
        //Swift Type: 'UnsafeRawBufferPointer'
        //C func: void (const void*, const size_t)
        try testCollection.withUnsafeBytes { rawBufferPointer in
            print_opaque_const(rawBufferPointer.baseAddress, rawBufferPointer.count)
        }
    }
    
    static func mutableRawBufferPointerPrint() throws {
        var testCollection = FixedSizeCollection<Int32>(5, default: 5)
        //Swift Type:  'UnsafeMutableRawBufferPointer'
        //C func: void (void*, const size_t )
        try testCollection.withUnsafeMutableBytes { rawBufferPointer in
            print_opaque(rawBufferPointer.baseAddress, rawBufferPointer.count)
        }
    }
    
//    static func boundBufferPointerPrint() throws {
//        var testCollection = FixedSizeCollection<Int32>(5, default: 5)
//        //Expected Failure. C function takes int* array, which is an ask for the base address.
//        //TODO: Check against ??
//        //error: cannot convert value of type 'UnsafeBufferPointer<Int32>?' to expected argument type 'UnsafeMutablePointer<Int32>?'
//        testCollection.withUnsafeBufferPointer { pointer in
//            acknowledge_cint_buffer(pointer, testCollection.count)
//        }
//    }
//    
//    static func boundMutableBufferPointerPrint() throws {
//        var testCollection = FixedSizeCollection<Int32>(5, default: 5)
//        //Expected Failure. C function takes int* array, which is an ask for the base address.
//        //TODO: Check against ??
//        //error: cannot convert value of type 'UnsafeMutableBufferPointer<Int32>?' to expected argument type 'UnsafeMutablePointer<Int32>?'
//        testCollection.withUnsafeMutableBufferPointer { pointer in
//            acknowledge_buffer(pointer, testCollection.count)
//        }
//    }
//    
//    
//    //-------------------------  //void acknowledge_buffer(int* array, const size_t n);
//    
//    static func mutableBufferPointerBaseaddressPrint() throws {
//        var testCollection = FixedSizeCollection<Int32>(5, default: 5)
//        let tmp_count = testCollection.count
//        //Safest way to handle this is with the buffer pointer.
//        try testCollection.withUnsafeMutableBufferPointer { bufferPointer in
//            if let bufferPointer {
//                precondition(tmp_count == bufferPointer.count)
//                acknowledge_buffer(bufferPointer.baseAddress, bufferPointer.count)
//            }
//        }
//        
//    }
//    
//    static func mutablePointerPrint() throws {
//        var testCollection = FixedSizeCollection<Int32>(5, default: 5)
//        let tmp_count = testCollection.count
//        //but if really want just the pointer
//        try testCollection.withUnsafeMutablePointer { pointer in
//            if let pointer {
//                //this check currently happens in withUnsafeMutablePointer.
//                //precondition(testCollection.count == bufferPointer.count)
//                acknowledge_buffer(pointer, tmp_count)
//            }
//        }
//    }
//    
    
}
