//
//  FixedSizeCollection.swift
//  TestingTwo
//
//  Created by Carlyn Maw on 2/2/24.


import Foundation

//Unresolved. Should perhaps be N:Int in the generic.
public struct FixedSizeCollection<Element> : RandomAccessCollection {
    public typealias N = Int
    public typealias _Storage = Data
    //TODO: buffer vs storage in Array vs Collection semantics
    
    public let count:N   //Unresolved. Int, UInt, CInt... For now starting with Int.
    public var startIndex: Int { 0 }
    public var endIndex: Int { count }
    
    //MAY GO AWAY.
    let defaultValue:Element? //TODO: if Element:Optional
    
    //What is the best storage type?
    
    //Data good for prototyping
    @usableFromInline
    internal var _storage:_Storage
    
    //TODO: Believe this is copy,copy not COW?
    var all:[Element] {
        loadFixedSizeCArray(source: _storage, ofType: Element.self) ?? []
    }
    

    

    
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
        self._storage = result.withUnsafeMutableBufferPointer { pointer in
            Data(buffer: pointer)
        }
    }
    
    init(default d:Element? = nil, initializer:() -> [Element]) {
        self.defaultValue = d
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
    
    init(dataBlob: Data, as: Element.Type, default d:Element? = nil) {
        self.defaultValue = d
        self._storage = dataBlob
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

//TODO: What is a DependenceToken (as seen in Array)
extension FixedSizeCollection {
    
    @inlinable
    internal func _checkSubscript(_ position:N) -> Bool {
        //TODO: Okay to depend on Range or, Nah. Can't do for Range(Range)
        (0..<count).contains(position)
    }
    
}


//MARK: Helpers
extension FixedSizeCollection {
    
    //TODO: To cache or not to cache
    @inlinable
    internal var _mStrideFull:N {  MemoryLayout<Element>.stride * count }
    
    @inlinable
    internal var _mStrideElem:N {  MemoryLayout<Element>.stride }
    
    @inlinable
    internal func _offsetStride(itemCount:N) -> N { MemoryLayout<Element>.stride * itemCount }
    
    @inlinable
    internal var _mSizeFull:N {  MemoryLayout<Element>.size * count }
    
    @inlinable
    internal var _mSizeElem:N {  MemoryLayout<Element>.size }
    
    @inlinable
    internal func _offsetSize(itemCount:N) -> N { MemoryLayout<Element>.size * itemCount }
    
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



