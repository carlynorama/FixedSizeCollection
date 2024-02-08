////
////  File.swift
////
////
////  Created by Carlyn Maw on 2/6/24.
////
//
//import Foundation
//
//
//internal extension FixedSizeCollection {
//
//    //MARK: Utilities
//
//    @inlinable
//    static func _confirmSizeOfTuple<each T>(tuple:(repeat each T), expectedCount:N? = nil) throws -> N {
//        let count = Mirror(reflecting: tuple).children.count
//        if expectedCount != nil, expectedCount != count  {
//            throw FSCError.unknownError(message: "tuple's children and tuple's expected count not the same.")
//        }
//        return count
//    }
//
//
//    //MARK: Getting Values Out
//    //Less safe in the case that the memory is not in fact bound to this.
//    @inlinable
//    static func _getFixedSizeCArrayAssumed<each T, R>(_ source:(repeat each T), boundToType:R.Type) -> [R] {
//        return Swift.withUnsafeBytes(of: source) { (rawPointer) -> [R] in
//            let bufferPointer = rawPointer.assumingMemoryBound(to: boundToType)
//            return [R](bufferPointer)
//        }
//    }
//
//    //TODO: Having difficulties.
//    //    @inlinable
//    //    internal static func loadFixedSizeCArray<T, R>(source:T, ofType:R.Type) -> [R]? {
//    //        Swift.withUnsafeBytes(of: source) { (rawPointer) -> [R]? in
//    //            rawPointer.baseAddress?.load(as: [R].self)
//    //        }
//    //    }
//
//        //Can't use parameter packs to enforce single type conformance yet.
//    static func newRegularTuple<each T>(_ item: repeat each T) -> (repeat each T) {
//        //return (repeat each item as? E) for example, not a thing.
//        return (repeat each item)
//    }
//
//    //TODO: Compare speed. This version checks type.
//    //The currently use one other is a pinky swear from the client
//    //keep an eye on https://github.com/apple/swift/pull/70227
//    static func _get<each T, R>(valuesBoundTo:R.Type, from tuple: (repeat each T)) -> [R] {
//            var newArray:[R] = []
//            Mirror(reflecting: tuple).children.forEach { child in
//            if let newValue = child.value as? R {
//                newArray.append(newValue)
//            }
//        }
//        return newArray
//    }
//
//    //MARK: Putting Back
//    //Uses withMemoryRebound. Be sure target's memory is in fact bound to that.
//    @inlinable
//    func _loadIntoTuple<each T, R>(tuple: inout (repeat each T), count:N, type:R.Type) throws {
//        precondition(count == self.count)
//        precondition(type == Element.self)
//        precondition(MemoryLayout.size(ofValue: tuple) == MemoryLayout<R>.stride * count)
//
//        Swift.withUnsafeMutablePointer(to: &tuple) { tuplePointer in
//            precondition(Int(bitPattern: tuplePointer).isMultiple(of: MemoryLayout<R>.alignment))
//            tuplePointer.withMemoryRebound(to: Element.self, capacity: count) { reboundPointer in
//                let bufferPointer = UnsafeMutableBufferPointer(start: UnsafeMutablePointer(reboundPointer), count: count)
//                for i in stride(from: bufferPointer.startIndex, to: bufferPointer.endIndex, by: 1) {
//                    bufferPointer[i] = self[i]
//                }
//            }
//
//        }
//    }
//
//    //YOLO transfer.
//    //Don't use this. Especially for anything more complicated than a Int, which you might get away with, but I didn't say that.
//    //This one also doesn't accept upgrading to variadic generics.
//    //TODO, figure out why but give it a minute because should use this anyway.
//    @inlinable
//    func _memCopyToTuple<U, R>(tuple: inout U, count:Int, type:R.Type) throws {
//    //func _memCopyToTuple<each T, R>(tuple: inout (repeat each T), count:Int, type:R.Type) throws {
//        precondition(count == self.count)
//        precondition(type == Element.self)
//        precondition(MemoryLayout.size(ofValue: tuple) == MemoryLayout<R>.stride * count)
//        precondition(MemoryLayout.size(ofValue: tuple) == MemoryLayout<R>.stride * self.count)
//
//        try Swift.withUnsafeMutablePointer(to: &tuple) { tuplePointer in
//            precondition(Int(bitPattern: tuplePointer).isMultiple(of: MemoryLayout<R>.alignment))
//            let _ = try self.withUnsafeBufferPointer { bufferPointer in
//                memcpy(tuplePointer, bufferPointer?.baseAddress, count * MemoryLayout<R>.stride)
//            }
//        }
//    }
//
//}
