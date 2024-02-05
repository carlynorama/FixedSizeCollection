//
//  FixedSizeCollection.swift
//  TestingTwo
//
//  Created by Carlyn Maw on 2/2/24.


import Foundation

//Unresolved. Should perhaps be N:Int in the generic.
public struct FixedSizeCollection<Element> : RandomAccessCollection {
    public typealias N = Int
    public typealias _Storage = Data  //Could be buffer or storage some day.
    //TODO: buffer vs storage in Array vs Collection semantics
    
    public let count:N   //Unresolved. Int, UInt, CInt... For now starting with Int.
    public var startIndex: Int { 0 }
    public var endIndex: Int { count }
    
    //MAY GO AWAY!!!
    //TODO: Double Optional Possible
    //- for use in pulling in arrays from C where 0 may need to be nil
    //- or inserts to replace append where "next available spot that == default" might be handy.
    //- or "nil out this value" when communicating with a language that doesn't have nil.
    //But not everyone may need those functions, and if you don't having to set it is annoying.
    //Don't love this. Could be required on those functions and initializers instead.
    let _defaultValue:Element?
    
    //What is the best storage type?
    
    //Data good for prototyping
    @usableFromInline
    internal var _storage:_Storage
    
}
//MARK: Inits
public extension FixedSizeCollection {
    
    init(_ count:Int, defaultsTo d:Element, initializer:() -> [Element] = { [] }) {
        self.count = count
        self._defaultValue = d
        var result = initializer().prefix(count)
        //if result.count > count { return nil }
        for _ in 0...(count - result.count) {
            result.append(d)
        }
        self._storage = result.withUnsafeMutableBufferPointer { pointer in
            Data(buffer: pointer)
        }
    }
    
    init(defaultsTo d:Element? = nil, initializer:() -> [Element]) {
        self._defaultValue = d
        var tmp = initializer()
        self._storage = tmp.withUnsafeMutableBufferPointer { pointer in
            Data(buffer: pointer)
        }
        self.count = _storage.withUnsafeBytes { bytes in
            let tmpCount = bytes.count / MemoryLayout<Element>.stride
            precondition(tmpCount * MemoryLayout<Element>.stride == bytes.count)
            precondition(Int(bitPattern: bytes.baseAddress).isMultiple(of: MemoryLayout<Element>.alignment))
            return tmpCount
        }
    }
    
    internal
    init(storage: _Storage, as: Element.Type, defaultsTo d:Element? = nil) {
        self._defaultValue = d
        self._storage = storage
        self.count = storage.withUnsafeBytes { bytes in
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

//TODO: What is a DependenceToken (as seen in Array)
extension FixedSizeCollection {
    
    @inlinable
    internal func _checkSubscript(_ position:N) -> Bool {
        (0..<count).contains(position)
    }
    
    @inlinable
    internal func _checkSubscript(_ range:Range<N>) -> Bool {
        (0..<count).contains(range.lowerBound) && (0..<count).contains(range.upperBound)
    }
    
}


//MARK: Helpers
extension FixedSizeCollection {
    @inlinable
    internal func _sliceOfStorage(_ range:Range<N>) throws -> _Storage.SubSequence {
        let startIndex = _storage.startIndex + _mStrideOffset(for: range.lowerBound)
        let endIndex = _storage.startIndex + _mStrideOffset(for: range.upperBound)
        return _storage[startIndex..<endIndex]
    }
    
    @inlinable
    internal var _mStrideFull:N {  MemoryLayout<Element>.stride * count }
    
    @inlinable
    internal var _mStrideElem:N {  MemoryLayout<Element>.stride }
    
    @inlinable
    internal func _mStrideOffset(for count:N) -> N { MemoryLayout<Element>.stride * count }
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



