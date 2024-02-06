//
//  FixedSizeCollection.swift
//  TestingTwo
//
//  Created by Carlyn Maw on 2/2/24.

import Foundation

//Unresolved. Should perhaps be N:Int in the generic.
public struct FixedSizeCollection<Element>: RandomAccessCollection {
    public typealias N = Int
    public typealias _Storage = Data  //Could be buffer or storage some day.
                                      //TODO: buffer vs storage in Array vs Collection semantics
    
    public let count: N  //Unresolved. Int, UInt, CInt... For now starting with Int.
    public var startIndex: Int { 0 }
    public var endIndex: Int { count }
    
    //MAY GO AWAY!!!
    //TODO: Double Optional Possible
    //- for use in pulling in arrays from C where 0 may need to be nil
    //- or inserts to replace append where "next available spot that == default" might be handy.
    //- or "nil out this value" when communicating with a language that doesn't have nil.
    //But not everyone may need those functions, and if you don't having to set it is annoying.
    //Don't love this. Could be required on those functions and initializers instead.
    let _defaultValue: Element?
    
    //What is the best storage type?
    
    //Data good for prototyping
    @usableFromInline
    internal var _storage: _Storage
    
}
//MARK: Inits
extension FixedSizeCollection {
    
    //TODO: Should these be [Element] or of some Collection<Element>
    //Best for ergonomics? Easiest for complexity?
    //How to make sure that all the Data looks like the same type of
    //Collection of Elements when getting the bytes.
    
    
    //----- Explicit Count
    
    //Truncates.
    //TODO: probably should ask what the desired behavior is.
    public init(_ count: Int, defaultsTo d: Element, values:[Element]) {
        self.count = count
        self._defaultValue = d
        var result = values.prefix(count)
        //if result.count > count { return nil }
        for _ in 0..<(count - result.count) {
            result.append(d)
        }
        self._storage = result.withUnsafeMutableBufferPointer { pointer in
            Data(buffer: pointer)
        }
    
        assert(self.count <= Self._getVerifiedCount(storage:_storage), "Storage did not reserve enough room.")
    }
    
    @inlinable
    static func makeFixedSizeCollection(count:N, defaultsTo d: Element? = nil, values:[Element]) -> FixedSizeCollection {
        Self.init(defaultsTo: d, values:values)
    }
    
    
    public init(_ count: Int, defaultsTo d: Element, initializer: () -> [Element] = { [] }) {
        self = Self.init(count, defaultsTo: d, values: initializer())
    }
    
    public init(_ count: Int, defaultsTo d: Element, _ values:Element...) {
        self = Self.init(count, defaultsTo: d, values: values)
    }

        //Implies a potential "asView" (fingers crossed.)

    
    
    // ---- Inferred Count
    
    public init(defaultsTo d: Element? = nil, values:[Element]) {
        self._defaultValue = d
        var tmp = values
        self._storage = tmp.withUnsafeMutableBufferPointer { pointer in
            Data(buffer: pointer)
        }
        self.count = values.count
        
        assert(self.count <= Self._getVerifiedCount(storage:_storage), "Storage did not reserve enough room.")
    }
    
    @inlinable
    static func makeFixedSizeCollection(defaultsTo d: Element? = nil, values:[Element]) -> FixedSizeCollection {
        Self.init(defaultsTo: d, values:values)
    }
    
    public init(defaultsTo d: Element? = nil, initializer: () -> [Element]) {
        self = Self.makeFixedSizeCollection(defaultsTo:d, values: initializer())
    }
    
    public init(defaultsTo d: Element? = nil, _ values:Element...) {
        self = Self.makeFixedSizeCollection(defaultsTo:d, values: values)
    }
    
    //Implies a potential "asView" (fingers crossed.)
    public init(asCopy pointer:UnsafeBufferPointer<Element>, defaultsTo d: Element? = nil) {
        self._defaultValue = d
        self._storage = Data(buffer: pointer)
        self.count = pointer.count
        
        assert(self.count <= Self._getVerifiedCount(storage:_storage), "Storage did not reserve enough room.")
    }

    public init<T>(asCopyOfTuple source:T, ofType:Element.Type, defaultsTo d: Element? = nil) {
        let tmp = Self._getFixedSizeCArrayAssumed(source: source, boundToType: Element.self)
        self = Self.makeFixedSizeCollection(count:tmp.count , defaultsTo: d, values: tmp)
        do {
            let _ = try Self._confimSizeOfTuple(tuple: source, expectedCount: self.count)
        } catch {
            assertionFailure("tuple count and collection count don't match. tuple was likely not homogenous or not of the type indicated.")
        }
    }
    
    
    internal
    init(storage: _Storage, as: Element.Type, count:N, defaultsTo d: Element? = nil)
    {
        self._defaultValue = d
        self._storage = storage
        self.count = count
        
        assert(self.count <= Self._getVerifiedCount(storage:_storage), "Storage did not reserve enough room.")
    }
    
}

//What is the better way?
//extension FixedSizeCollection where Element:OptionalProtocol {
//    //TODO: should throw? return the Optional(index) of the insert?
//    //TODO: What does nil look like in the Data buffer
//    func insert(_ newValue:Element)  {
//        print(dataBlob)
//        print(newValue)
//        dataBlob.withUnsafeBytes { rawPointer in
//            if var tmp = rawPointer.baseAddress?.load(as: [Element].self) {
//                //TODO: Make this work.
//                if let i = tmp.firstIndex(where: {$0.isNil()}) {
//                    tmp[i] = newValue
//                }
//            }
//        }
//    }
//}

//
//protocol OptionalProtocol {
//  // the metatype value for the wrapped type.
//  static var wrappedType: Any.Type { get }
//    func isNil() -> Bool
//}
//
//extension OptionalProtocol {
//
//}
//
//extension Optional : OptionalProtocol {
//  static var wrappedType: Any.Type { return Wrapped.self }
//    func isNil() -> Bool {
//        self == nil
//    }
//}
