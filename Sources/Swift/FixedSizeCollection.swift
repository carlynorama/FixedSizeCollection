//
//  FixedWidth.swift
//  TestingTwo
//
//  Created by Carlyn Maw on 2/2/24.
//  Inspired by 25:52 of WWDC 2020 "Safely Manage Pointers in Swift."

// In the subscript, using .load(fromByteOffset:as) prevents rebinding of memory for access. This struct can point to memory bound as a different type without overriding.

import Foundation


public struct FixedSizeCollection<Element> : RandomAccessCollection {
    public let count:Int
    public var startIndex: Int { 0 }
    public var endIndex: Int { count }
    
    //What is the best storage type?
    //Data good for prototyping
    private var dataBlob:Data
    
}
//MARK: Inits
public extension FixedSizeCollection {
    init(_ count:Int, default d:Element, initializer:() -> [Element] = { [] }) {
        self.count = count
        var result = initializer().prefix(count)
        //if result.count > count { return nil }
        for _ in 0...(count - result.count) {
            result.append(d)
        }
        self.dataBlob = result.withUnsafeMutableBufferPointer { pointer in
            Data(buffer: pointer)
        }
    }
    
    init(initializer:() -> [Element]) {
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
    
    
    
    init(dataBlob: Data, as: Element.Type) {
        
        self.dataBlob = dataBlob
        self.count = dataBlob.withUnsafeBytes { bytes in
            let tmpCount = bytes.count / MemoryLayout<Element>.stride
            precondition(tmpCount * MemoryLayout<Element>.stride == bytes.count)
            precondition(Int(bitPattern: bytes.baseAddress).isMultiple(of: MemoryLayout<Element>.alignment))
            return tmpCount
        }
    }
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
            withUnsafePointer(to: newValue) { sourceValuePointer in
                dataBlob.replaceSubrange(startIndex..<endIndex, with: sourceValuePointer, count: MemoryLayout<Element>.stride)
            }
        }
    }
    
    var all:[Element] {
        loadFixedSizeCArray(source: dataBlob, ofType: Element.self) ?? []
    }
    
    //Anything Data does...
    func withUnsafeBytes<ResultType>(body: (UnsafeRawBufferPointer) throws -> ResultType) throws -> ResultType {
        try dataBlob.withUnsafeBytes(body)
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


