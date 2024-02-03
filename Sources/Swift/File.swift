//
//  CCallsForTests.swift
//
//
//  Created by Carlyn Maw on 2/3/24.
//

import Foundation
import CSupport

extension FixedSizeCollection {

//  TODO: Fix.
//   14:28: error: cannot convert value of type 'UnsafeMutablePointer<FixedSizeCollection<Int>>' to expected argument type 'UnsafeMutablePointer<Int32>'
//            acknowledge_buffer(&testCollection, testCollection.count)
//                               ^
//   14:28: note: arguments to generic parameter 'Pointee' ('FixedSizeCollection<Int>' and 'Int32') are expected to be equal
//            acknowledge_buffer(&testCollection, testCollection.count)
//                               ^
//   18:32: error: cannot convert value of type 'UnsafeRawBufferPointer' to expected argument type 'UnsafeMutablePointer<Int32>?'
//                acknowledge_buffer(pointer, testCollection.count)
//                                   ^

    static func basicPrint() {
        var testCollection = FixedSizeCollection<Int>(5, default: 5)
        acknowledge_buffer(&testCollection, testCollection.count)
        
        let testCollection2 = FixedSizeCollection<Int>(5, default: 12)
        testCollection2.withUnsafeBytes { pointer in
            acknowledge_buffer(pointer, testCollection.count)
        }
    }
}
