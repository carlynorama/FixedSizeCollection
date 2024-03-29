//
//  CCallsForTests.swift
//
//
//  Created by Carlyn Maw on 2/3/24.
//

//TODO: in a package manager how to have a per file target inclusion?
//TODO: withUnsafe are all optional pointers even though they throw? Confirm.

import FixedSizeCollection
import Foundation
import TestCSupport

extension FixedSizeCollection {

  //TODO: Check mutators do in fact mutate.

  //TODO: Try to fix &fsc, (ignore direct data access.)
  //static func basicPrint() throws {
  //    static func storageInout() {
  //       var testCollection = FixedSizeCollection<Int32>(5, fillValue: 5)
  ////  TODO: I would like for this to work. override the prefix how?
  ////  //When var: error: cannot convert value of type 'UnsafeMutablePointer<FixedSizeCollection<Int32>>' to expected argument type 'UnsafeMutablePointer<Int32>'
  //    //When let: requires mutable.
  //    acknowledge_cint_buffer(&testCollection, testCollection.count)
  //
  //    //cannot convert value of type 'FixedSizeCollection<Int32>' to expected argument type 'UnsafePointer<Int32>?'
  //    acknowledge_cint_buffer_const(testCollection, testCollection.count)
  //
  //    let test:[CInt] = [42, 45, 48]
  //    acknowledge_cint_buffer_const(test, testCollection.count)
  //
  ////  //Expected Failure. Data doesn't know what Element is.
  //    //back when internal _storage was a private dataBlob
  ////  //error: cannot convert value of type 'UnsafeMutablePointer<(Data)>' to expected //argument type 'UnsafeMutablePointer<Int32>'
  ////  acknowledge_cint_buffer(&(testCollection.dataBlob), testCollection.count)
  //  }

  static func rawBufferPointerPrint() throws {
    let testCollection = FixedSizeCollection<Int32>(5, fillValue: 5)
    //Swift Type: 'UnsafeRawBufferPointer'
    //C func: void (const void*, const size_t)
    try testCollection.withUnsafeBytes { rawBufferPointer in
      print_opaque_const(rawBufferPointer.baseAddress, rawBufferPointer.count)
    }
  }

  static func mutableRawBufferPointerPrint() throws {
    var testCollection = FixedSizeCollection<Int32>(5, fillValue: 5)
    //Swift Type:  'UnsafeMutableRawBufferPointer'
    //C func: void (void*, const size_t )
    try testCollection.withUnsafeMutableBytes { rawBufferPointer in
      print_opaque(rawBufferPointer.baseAddress, rawBufferPointer.count)
    }
  }

  //------------------------------------------------------- HERE.
  //--------------------------------------------------------------------
  //error: Exited with signal code 11
  static func boundBufferPointerPrint() throws {
    let testCollection = FixedSizeCollection<Int32>(5, fillValue: 5)
    //Swift Type:  'UnsafeBufferPointer<Int32>'
    //C func: void (const int*, const size_t)
    try testCollection.withUnsafeBufferPointer { bufferPointer in
      if let bufferPointer {
        acknowledge_cint_buffer_const(bufferPointer.baseAddress, bufferPointer.count)
      }
    }
  }

  //Safest way to handle this is with the buffer pointer.
  static func boundMutableBufferPointerPrint() throws {
    var testCollection = FixedSizeCollection<Int32>(5, fillValue: 5)
    //Swift Type:  'UnsafeMutableBufferPointer<Int32>'
    //C func: void (int*, const size_t)
    try testCollection.withUnsafeMutableBufferPointer { bufferPointer in
      if let bufferPointer {
        acknowledge_cint_buffer(bufferPointer.baseAddress, bufferPointer.count)
      }
    }
  }

  //but if really want just the pointer
  static func boundPointerPrint() throws {
    let testCollection = FixedSizeCollection<Int32>(5, fillValue: 5)
    let tmpCount = testCollection.count
    //Swift Type:  'UnsafePointer<Int32>'
    //C func: void (cont int*, const size_t)
    try testCollection.withUnsafePointer { pointer in
      if let pointer {
        acknowledge_cint_buffer_const(pointer, tmpCount)
      }
    }
  }

  static func boundMutablePointerPrint() throws {
    var testCollection = FixedSizeCollection<Int32>(5, fillValue: 5)
    let tmpCount = testCollection.count
    //Swift Type:  'UnsafePointer<Int32>'
    //C func: void (int*, const size_t)
    try testCollection.withUnsafeMutablePointer { pointer in
      if let pointer {
        acknowledge_cint_buffer(pointer, tmpCount)
      }
    }
  }

}
