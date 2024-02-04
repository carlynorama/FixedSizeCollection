//
//  FixedWidth.swift
//  TestingTwo
//
//  Created by Carlyn Maw on 2/2/24.
//  Inspired by 25:52 of WWDC 2020 "Safely Manage Pointers in Swift."

// In the subscript, using .load(fromByteOffset:as) prevents rebinding of memory for access. This struct can point to memory bound as a different type without overriding.

import Foundation

//Unresolved. Should perhaps be N:Int in the generic.
public struct FixedSizeCollection<Element> : RandomAccessCollection {
    public typealias N = Int
    public let count:N   //Unresolved. Int, UInt, CInt... For now starting with Int.
    public var startIndex: Int { 0 }
    public var endIndex: Int { count }
    
    //MAY GO AWAY.
    let defaultValue:Element? //TODO: if Element:Optional
    
    //What is the best storage type?
    //Data good for prototyping
    private var dataBlob:Data
    
    private var memSizeFull:N {  MemoryLayout<Element>.size * count }
    private var memSizeElem:N {  MemoryLayout<Element>.size }
    private func offsetSize(itemCount:N) -> N { MemoryLayout<Element>.size * itemCount }
    

    
}
//MARK: Inits
public extension FixedSizeCollection {
    init(_ count:Int, default d:Element, initializer:() -> [Element] = { [] }) {
        self.count = count
        self.defaultValue = d
        var result = initializer().prefix(count)
        //if result.count > count { return nil }
        for _ in 0...(count - result.count) {
            result.append(d)
        }
        self.dataBlob = result.withUnsafeMutableBufferPointer { pointer in
            Data(buffer: pointer)
        }
    }
    
    init(default d:Element? = nil, initializer:() -> [Element]) {
        self.defaultValue = d
        var tmp = initializer()
        self.dataBlob = tmp.withUnsafeMutableBufferPointer { pointer in
            Data(buffer: pointer)
        }
        self.count = dataBlob.withUnsafeBytes { bytes in
            let tmpCount = bytes.count / MemoryLayout<Element>.stride
            precondition(tmpCount * MemoryLayout<Element>.stride == bytes.count)
            precondition(Int(bitPattern: bytes.baseAddress).isMultiple(of: MemoryLayout<Element>.alignment))
            return tmpCount
        }
    }
    
    init(dataBlob: Data, as: Element.Type, default d:Element? = nil) {
        self.defaultValue = d
        self.dataBlob = dataBlob
        self.count = dataBlob.withUnsafeBytes { bytes in
            let tmpCount = bytes.count / MemoryLayout<Element>.stride
            precondition(tmpCount * MemoryLayout<Element>.stride == bytes.count)
            precondition(Int(bitPattern: bytes.baseAddress).isMultiple(of: MemoryLayout<Element>.alignment))
            return tmpCount
        }
    }
    
    //TODO: Initialize/Factory method COPY that works well retrieving copy of C array
    /*
     public func makeArrayOfRandomIntClosure(count:Int) -> [Int] {
         //Count for this initializer is really MAX count possible, function may return an array with fewer items defined.
         //both buffer and initializedCount are inout
         let tmp = Array<CInt>(unsafeUninitializedCapacity: count) { buffer, initializedCount in
             //C:-- void random_array_of_zero_to_one_hundred(int* array, const size_t n);
             random_array_of_zero_to_one_hundred(buffer.baseAddress, count)
             initializedCount = count // if initializedCount is not set, Swift assumes 0, and the array returned is empty.
         }
         return tmp.map { Int($0) }
     }
     */
}

//MARK: Access
public extension FixedSizeCollection {
    subscript(position: Int) -> Element {
        get {
            dataBlob.withUnsafeBytes { rawPointer in
                let bufferPointer = rawPointer.assumingMemoryBound(to: Element.self)
                return bufferPointer[position]
            }
        }
        set {
            let startIndex = dataBlob.startIndex + position * MemoryLayout<Element>.stride
            let endIndex = startIndex + MemoryLayout<Element>.stride
            Swift.withUnsafePointer(to: newValue) { sourceValuePointer in
                dataBlob.replaceSubrange(startIndex..<endIndex, with: sourceValuePointer, count: MemoryLayout<Element>.stride)
            }
        }
    }
    
    //TODO: Believe this is copy,copy not COW.
    var all:[Element] {
        loadFixedSizeCArray(source: dataBlob, ofType: Element.self) ?? []
    }
    
    //MARK: Unsafe
    //------------------------------------------------ RAW
    //-------- Anything Data does...
    func withUnsafeBytes<ResultType>(body: (UnsafeRawBufferPointer) throws -> ResultType) throws -> ResultType {
        try dataBlob.withUnsafeBytes(body)
    }
    
    mutating
    func withUnsafeMutableBytes<ResultType>(body: (UnsafeMutableRawBufferPointer) throws -> ResultType) throws -> ResultType {
        try dataBlob.withUnsafeMutableBytes(body)
    }
    
    //----------------------------------- Bound to Element
    func withUnsafeBufferPointer<ResultType>(body: (UnsafeBufferPointer<Element>?) throws -> ResultType) throws -> ResultType {
        return try dataBlob.withUnsafeBytes { unsafeRawBufferPointer in
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
        try dataBlob.withUnsafeMutableBytes { unsafeMutableRawBufferPointer in
            return try unsafeMutableRawBufferPointer.withMemoryRebound(to: Element.self) { bufferPointer in
                return try body(bufferPointer)
            }
        }
    }
    
    func withUnsafePointer<ResultType>(body: (UnsafePointer<Element>?) throws -> ResultType) throws -> ResultType {
        return try dataBlob.withUnsafeBytes { unsafeRawBufferPointer in
            return try unsafeRawBufferPointer.withMemoryRebound(to: Element.self) { bufferPointer in
                return try body(bufferPointer.baseAddress)
            }
        }
    }
    

    mutating
    func withUnsafeMutablePointer<ResultType>(body: (UnsafeMutablePointer<Element>?) throws -> ResultType) throws -> ResultType {
        return try dataBlob.withUnsafeMutableBytes { unsafeMutableRawBufferPointer in
            return try unsafeMutableRawBufferPointer.withMemoryRebound(to: Element.self) { bufferPointer in
                return try body(bufferPointer.baseAddress)
            }
        }
    }
}

//MARK: Helpers
extension FixedSizeCollection {
    //Okay to use assumingMemoryBound here IF using type ACTUALLY bound to.
    //Else see UnsafeBufferView struct example using .loadBytes to recast read values
    private func fetchFixedSizeCArray<T, R>(source:T, boundToType:R.Type) -> [R] {
        Swift.withUnsafeBytes(of: source) { (rawPointer) -> [R] in
            let bufferPointer = rawPointer.assumingMemoryBound(to: boundToType)
            return [R](bufferPointer)
        }
    }
    
    //TODO: Test non-numerics
    private func loadFixedSizeCArray<T, R>(source:T, ofType:R.Type) -> [R]? {
        Swift.withUnsafeBytes(of: source) { (rawPointer) -> [R]? in
            rawPointer.baseAddress?.load(as: [R].self)
        }
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








////https://forums.swift.org/t/handling-the-new-forming-unsaferawpointer-warning/65523/4
//@inlinable
//func areOrderedSetsDuplicates<T>(_ lhs: OrderedSet<T>, _ rhs: OrderedSet<T>) -> Bool {
//  withUnsafePointer(to: lhs) { lhs in
//    withUnsafePointer(to: rhs) { rhs in
//      return memcmp(lhs, rhs, MemoryLayout<OrderedSet<T>>.size) == 0
//    }
//  } || lhs == rhs
//}


