//
//  TupleLove.swift
//
//
//  Created by Carlyn Maw on 2/6/24.
//

// Overlap in mission with functions in MemoryNStorage,
// but this file might be the only one of interest to CArray focused work.

import Foundation

extension FixedSizeCollection {
    
    //REFERENCE FUNCTION
    //Can't use parameter packs to enforce single type conformance yet.
    //But keep and eye on:
    //- type enforcement in general https://github.com/apple/swift/pull/70227
    //- catting Elemets from different types of Sequences may be possible!
    //  -- struct Container<E, each S: Sequence> where repeat (each S).Element == E
    static func newRegularTuple<each T>(_ item: repeat each T) -> (repeat each T) {
        //return (repeat each item as? E) for example, not a thing.
        return (repeat each item)
    }
    
    //MARK: Utilities
    
    //Complies, passes test.
    //See also MemoryNStroage._verifyCount(of storage:) with similar goals
    //but different approach.
    //TODO: The approaches should yield same result for a known hm-g tup
    @inlinable
    static func _verifyCount<each T>(of tuple: (repeat each T), expectedCount: N? = nil) throws
    -> N
    {
        let count = Mirror(reflecting: tuple).children.count
        if expectedCount != nil, expectedCount != count {
            throw FSCError.unknownError(
                message: "tuple's children and tuple's expected count not the same.")
        }
        return count
    }
    
    //MARK: Getting Values Out
    
    //Less safe than _get(valuesBoundTo:from) in the case that the memory is
    //not in fact bound to this.
    //Only use in functions where that check has been performed.
    //====> replacing with each T,  compiler crashes to non zero exit code
    @inlinable
    static func _getAssuming<T, R>(valuesBoundTo assumedType: R.Type, from source: T) -> [R] {
        return Swift.withUnsafeBytes(of: source) { (rawPointer) -> [R] in
            let bufferPointer = rawPointer.assumingMemoryBound(to: assumedType)
            return [R](bufferPointer)
        }
    }
    
    //TODO: Compare speed. This version checks type.
    //The currently use one other is a pinky swear from the client
    //Mirrors seem to work okay with Parameter pack
    //See TestingWithC.testTupleEnforcement()
    static func _get<each T, R>(valuesBoundTo: R.Type, from tuple: (repeat each T)) -> [R] {
        var newArray: [R] = []
        for child in  Mirror(reflecting: tuple).children {
            if let newValue = child.value as? R {
                newArray.append(newValue)
            }
        }
        return newArray
    }
    
    
    //TODO: Having difficulties.
    //    @inlinable
    //    internal static func loadFixedSizeCArray<T, R>(source:T, ofType:R.Type) -> [R]? {
    //        Swift.withUnsafeBytes(of: source) { (rawPointer) -> [R]? in
    //            rawPointer.baseAddress?.load(as: [R].self)
    //        }
    //    }
    
    //MARK: Putting Back
    //Uses withMemoryRebound. Be sure target's memory is in fact bound to that.
    //safer but slower than memcopy because can work when less sure of the memory layout of each.
    @inlinable
    func _load<each T, R>(_ count: N, bytesOfType type: R.Type, into tuple: inout (repeat each T)) throws {
        precondition(count == self.count)
        precondition(type == Element.self)
        precondition(MemoryLayout.size(ofValue: tuple) == MemoryLayout<R>.stride * count)
        
        Swift.withUnsafeMutablePointer(to: &tuple) { tuplePointer in
            precondition(Int(bitPattern: tuplePointer).isMultiple(of: MemoryLayout<R>.alignment))
            tuplePointer.withMemoryRebound(to: Element.self, capacity: count) { reboundPointer in
                let bufferPointer = UnsafeMutableBufferPointer(
                    start: UnsafeMutablePointer(reboundPointer), count: count)
                for i in stride(from: bufferPointer.startIndex, to: bufferPointer.endIndex, by: 1) {
                    bufferPointer[i] = self[i]
                }
            }
            
        }
    }
    
    //YOLO transfer.
    //Don't use this. Especially for anything more complicated than a Int, which you might get away with, but I didn't say that.
    //This one also doesn't accept upgrading to variadic generics.
    //TODO, figure out why but give it a minute because shouldn't use this anyway.
    @inlinable
    func _memCopyToTuple<U, R>(tuple: inout U, count: Int, type: R.Type) throws {
        //func _memCopyToTuple<each T, R>(tuple: inout (repeat each T), count:Int, type:R.Type) throws {
        precondition(count == self.count)
        precondition(type == Element.self)
        precondition(MemoryLayout.size(ofValue: tuple) == MemoryLayout<R>.stride * count)
        precondition(MemoryLayout.size(ofValue: tuple) == MemoryLayout<R>.stride * self.count)
        
        try Swift.withUnsafeMutablePointer(to: &tuple) { tuplePointer in
            precondition(Int(bitPattern: tuplePointer).isMultiple(of: MemoryLayout<R>.alignment))
            let _ = try self.withUnsafeBufferPointer { bufferPointer in
                //Pack expansion requires that 'each U' and '' have the same shape
                //on line below when switch from type erased
                memcpy(tuplePointer, bufferPointer?.baseAddress, count * MemoryLayout<R>.stride)
            }
        }
    }
    
}
