//
//  File.swift
//
//
//  Created by Carlyn Maw on 2/6/24.
//

import Foundation


internal extension FixedSizeCollection {
    
    //MARK: Utilities
    
    //Can't use parameter packs to enforce single type conformance yet.
    static func newRegularTuple<each T>(_ item: repeat each T) -> (repeat each T) {
        //return (repeat each item as? E) for example, not a thing.
        return (repeat each item)
    }
    
    //Not a thing yet...
    // static func newRegularTuple<each T, E>(ofType:E.Type, _ item: repeat each T) -> (repeat each T) {
    //     return (repeat each item as? E)
    // }
    
    @inlinable
    static func _confirmSizeOfTuple<U>(tuple:U, expectedCount:N? = nil) throws -> N {
        let count = Mirror(reflecting: tuple).children.count
        if expectedCount != nil, expectedCount != count  {
            throw FSCError.unknownError(message: "tuple's children and tuple's expected count not the same.")
        }
        return count
    }
    
    //TODO: Compare speed. This version checks type.
    //The other is a pinky swear from the client.
    @inlinable
    static func _tupleAsArray<U, T>(tuple:U, isType:T.Type) throws -> [T] {
        var newArray:[T] = []
        Mirror(reflecting: tuple).children.forEach { child in
            if let newValue = child.value as? T {
                newArray.append(newValue)
            }
        }
        return newArray
    }
    
    
    //MARK: Getting Out
    
    //Less safe in the case that the memory is not in fact bound to this.
    @inlinable
    static func _getFixedSizeCArrayAssumed<T, R>(source:T, boundToType:R.Type, withCount count:N? = nil) -> [R] {
        return Swift.withUnsafeBytes(of: source) { (rawPointer) -> [R] in
            let bufferPointer = rawPointer.assumingMemoryBound(to: boundToType)
            return [R](bufferPointer)
        }
    }
    
    //TODO: Having difficulties.
    //    @inlinable
    //    internal static func loadFixedSizeCArray<T, R>(source:T, ofType:R.Type) -> [R]? {
    //        Swift.withUnsafeBytes(of: source) { (rawPointer) -> [R]? in
    //            rawPointer.baseAddress?.load(as: [R].self)
    //        }
    //    }
    
    //MARK: Putting Back
    @inlinable
    func _loadIntoTuple<U, T>(tuple: inout U, count:N, type:T.Type) throws {
        precondition(count == self.count)
        precondition(type == Element.self)
        precondition(MemoryLayout.size(ofValue: tuple) == MemoryLayout<T>.stride * count)
        
        Swift.withUnsafeMutablePointer(to: &tuple) { tuplePointer in
            precondition(Int(bitPattern: tuplePointer).isMultiple(of: MemoryLayout<T>.alignment))
            tuplePointer.withMemoryRebound(to: Element.self, capacity: count) { reboundPointer in
                let bufferPointer = UnsafeMutableBufferPointer(start: UnsafeMutablePointer(reboundPointer), count: count)
                for i in stride(from: bufferPointer.startIndex, to: bufferPointer.endIndex, by: 1) {
                    bufferPointer[i] = self[i]
                }
            }
            
        }
    }
    
    //YOLO transfer.
    //Don't use this. Especially for anything more complicated than a Int, which you might get away with, but I didn't say that.
    @inlinable
    func _memCopyToTuple<U>(tuple: inout U, count:Int, type:N.Type) throws {
        precondition(count == self.count)
        precondition(type == Element.self)
        precondition(MemoryLayout.size(ofValue: tuple) == MemoryLayout<N>.stride * count)
        precondition(MemoryLayout.size(ofValue: tuple) == MemoryLayout<N>.stride * self.count)
        
        try Swift.withUnsafeMutablePointer(to: &tuple) { tuplePointer in
            precondition(Int(bitPattern: tuplePointer).isMultiple(of: MemoryLayout<N>.alignment))
            let _ = try self.withUnsafeBufferPointer { bufferPointer in
                memcpy(tuplePointer, bufferPointer?.baseAddress, count * MemoryLayout<N>.stride)
            }
            
        }
    }
    
}
