//
//  File.swift
//  
//
//  Created by Carlyn Maw on 2/4/24.
//

import Foundation



public extension FixedSizeCollection {
    
    //MARK: Unsafe
    //------------------------------------------------ RAW
    //-------- Anything Data does...
    func withUnsafeBytes<ResultType>(body: (UnsafeRawBufferPointer) throws -> ResultType) throws -> ResultType {
        try self._storage.withUnsafeBytes(body)
    }
    
    mutating
    func withUnsafeMutableBytes<ResultType>(body: (UnsafeMutableRawBufferPointer) throws -> ResultType) throws -> ResultType {
        try _storage.withUnsafeMutableBytes(body)
    }
    
    //----------------------------------- Bound to Element
    //'UnsafeMutablePointer<(Data)>' doesn't cut it.
    
    func withUnsafeBufferPointer<ResultType>(body: (UnsafeBufferPointer<Element>?) throws -> ResultType) throws -> ResultType {
        return try _storage.withUnsafeBytes { unsafeRawBufferPointer in
            //Think this might be okay in this context.
            //declared an element pointer works, but gets freed prematurely.
            //var elementPointer = unsafeMutableRawBufferPointer.load(as: [Element].self)
            return try unsafeRawBufferPointer.withMemoryRebound(to: Element.self) { bufferPointer in
                return try body(bufferPointer)
            }
        }
    }
    
    mutating
    func withUnsafeMutableBufferPointer<ResultType>(body: (UnsafeMutableBufferPointer<Element>?) throws -> ResultType) throws -> ResultType {
        try _storage.withUnsafeMutableBytes { unsafeMutableRawBufferPointer in
            return try unsafeMutableRawBufferPointer.withMemoryRebound(to: Element.self) { bufferPointer in
                return try body(bufferPointer)
            }
        }
    }
    
    func withUnsafePointer<ResultType>(body: (UnsafePointer<Element>?) throws -> ResultType) throws -> ResultType {
        return try _storage.withUnsafeBytes { unsafeRawBufferPointer in
            return try unsafeRawBufferPointer.withMemoryRebound(to: Element.self) { bufferPointer in
                return try body(bufferPointer.baseAddress)
            }
        }
    }
    

    mutating
    func withUnsafeMutablePointer<ResultType>(body: (UnsafeMutablePointer<Element>?) throws -> ResultType) throws -> ResultType {
        return try _storage.withUnsafeMutableBytes { unsafeMutableRawBufferPointer in
            return try unsafeMutableRawBufferPointer.withMemoryRebound(to: Element.self) { bufferPointer in
                return try body(bufferPointer.baseAddress)
            }
        }
    }
}
