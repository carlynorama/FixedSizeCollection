//
//  File.swift
//
//
//  Created by Carlyn Maw on 2/6/24.
//

import Foundation

//Here for reference.

// protocol P {}
// struct A: P {}
// struct B: P {}

// func foo<each T>(_ value: repeat each T) -> (repeat each T) where repeat each T: P {
//     (repeat each value)
// }

// func test<each T>(_ value: repeat each T) -> (repeat each T) where repeat each T: P {
//     let tuple = (repeat foo(each value))
//     return (repeat foo(each tuple))
// }
// func typeTest() -> some P {
//     let y = test(A(), B(), B())
// }

//func buildBlock<each Content>(_ content: repeat each Content)
//-> TupleView<(repeat each Content)> where repeat each Content : View

extension FixedSizeCollection {

  //MARK: amazing. Go parameter packs.
  fileprivate static func eachFirst<FirstT: Collection, each T: Collection>(
    _ firstItem: FirstT, _ item: repeat each T
  ) -> (repeat (each T).Element?) {
    return (repeat (each item).first)
  }

  fileprivate func pairUp2<each T, each U>(firstPeople: repeat each T, secondPeople: repeat each U)
    -> (repeat (first: each T, second: each U))
  {
    return (repeat (each firstPeople, each secondPeople))
  }

  //MARK: Assembler

  //This function is the simpler case than the assembler, but the assembler uses this pattern
  // of making a rawBuffer that lasts just for the duration of the function.
  fileprivate static func rawBufferWork<T>(count: Int, initializer: T) {
    let rawPointer = UnsafeMutableRawPointer.allocate(
      byteCount: MemoryLayout<T>.stride * count, alignment: MemoryLayout<T>.alignment)
    let tPtr = rawPointer.initializeMemory(as: T.self, repeating: initializer, count: count)

    //Do something that needs a pointer bound to T
    //to hand to C? Create a tmp variable to pass out after dealloc?

    tPtr.deinitialize(count: count)
    rawPointer.deallocate()
  }

  //Make a rawBuffer to hand of to C that lasts just for the duration of the function.
  fileprivate static func exampleAssembler<Header, DataType: Numeric>(
    header: Header, data: [DataType]
  ) {
    let offset = MemoryLayout<Header>.stride

    let byteCount = offset + MemoryLayout<DataType>.stride * data.count
    print(
      "offset:\(offset), dataCount:\(data.count), dataTypeStride:\(MemoryLayout<DataType>.stride),  byteCount:\(byteCount)"
    )
    assert(MemoryLayout<Header>.alignment >= MemoryLayout<DataType>.alignment)

    //Start of whole message
    let rawPointer = UnsafeMutableRawPointer.allocate(
      byteCount: byteCount, alignment: MemoryLayout<Header>.alignment)

    //Start of header. In this case headerPointer.baseAddress == rawPointer.baseAddress,
    //But headerPointer is bound to Header type.
    let headerPointer = rawPointer.initializeMemory(as: Header.self, repeating: header, count: 1)

    //Initialize region to take in data of proper DataType.
    //DataType:Numeric so I could use 0 but one could pass in an initializer.
    let elementPointer = (rawPointer + offset).initializeMemory(
      as: DataType.self, repeating: 0, count: data.count)

    data.withUnsafeBufferPointer { sourcePointer in
      elementPointer.update(from: sourcePointer.baseAddress!, count: sourcePointer.count)
    }
    print("raw:\(rawPointer)")
    print("header:\(headerPointer)")
    print("element:\(elementPointer)")

    //---------------  DO Something
    //        let bufferPointer = UnsafeRawBufferPointer(start: rawPointer, count: byteCount)
    //
    //        print(bufferPointer)

    // cant just return Data(bytes: rawPointer, count: byteCount) because must deallocate before leaving.
    let tmp = Data(bytes: rawPointer, count: byteCount)

    for dataByte in tmp {
      print(dataByte, terminator: ", ")
    }
    print()

    //--------------- END DO Something

    elementPointer.deinitialize(count: data.count)
    headerPointer.deinitialize(count: 1)
    rawPointer.deallocate()

    //--------------- IF NEEDED: return tmp
  }

  //MARK: Load From Data

  //---------------
  //Functions require aligned data unless specified.
  //aligned data is data where byte[0] of the desired type is being cheated from a pointer with a value that matches the granularity of that type. Eg. if start pointer is &data[0] + offset, then offset % MemoryLayout<T>.stride must == 0
  //https://developer.ibm.com/articles/pa-dalign/

  //Note checks one could add:
  //precondition(data.count == MemoryLayout<N>.stride)
  //precondition(offset % MemoryLayout<T>.stride == 0)

  fileprivate static func processData<T>(data: Data, as type: T.Type) -> T {
    let result = data.withUnsafeBytes { (buffer: UnsafeRawBufferPointer) -> T in
      return buffer.load(as: type)
    }
    print(result)
    return result
  }

  //
  //offset needs to be  offset % MemoryLayout<T>.stride == 0
  fileprivate static func processData2<T>(data: Data, as type: T.Type, offsetBy offset: Int = 0)
    -> T
  {
    //precondition(offset % MemoryLayout<T>.stride == 0)
    let result = data.withUnsafeBytes { buffer -> T in
      return buffer.load(fromByteOffset: offset, as: T.self)
    }
    print(result)
    return result
  }

  fileprivate static func processUnalignedData<T>(
    data: Data, as type: T.Type, offsetBy offset: Int = 0
  ) -> T {
    let result = data.withUnsafeBytes { buffer -> T in
      return buffer.loadUnaligned(fromByteOffset: offset, as: T.self)
    }
    print(result)
    return result
  }

  fileprivate static func processDataIntoArray<T>(data: Data, as type: T.Type, count: Int) -> [T] {
    precondition(data.count == MemoryLayout<T>.stride * count)
    let result = data.withUnsafeBytes { buffer -> [T] in
      var values: [T] = []
      for i in (0..<count) {
        values.append(buffer.load(fromByteOffset: MemoryLayout<T>.stride * i, as: T.self))
      }
      return values
    }
    return result
  }

  fileprivate static func processUnalignedDataIntoArray<T>(
    data: Data, as type: T.Type, byOffset offset: Int, count: Int
  ) -> [T] {
    precondition((data.count - offset) > (MemoryLayout<T>.stride * count))
    let result = data.withUnsafeBytes { buffer -> [T] in
      var values: [T] = []
      for i in (0..<count) {
        values.append(
          buffer.loadUnaligned(fromByteOffset: offset + (MemoryLayout<T>.stride * i), as: T.self))
      }
      return values
    }
    return result
  }

  //---- Special case solutions.

  //This function just shoves a copy of the bytes in.
  fileprivate static func readNumericFrom<N: Numeric>(
    correctCountData data: Data, as numericType: N.Type
  ) -> N {
    //Non numerics should really use stride.
    precondition(data.count == MemoryLayout<N>.size)  //Could determine type switch on data count with error.
    var newValue: N = 0
    let copiedCount = Swift.withUnsafeMutableBytes(of: &newValue, { data.copyBytes(to: $0) })
    precondition(copiedCount == MemoryLayout.size(ofValue: newValue))
    return newValue
  }

  //This function is needlessly low level for most cases. Better to use the .load function inside of closures like below. Leave this here as a reference for when absolutely need it.
  //withMemoryRebound, .load better choices
  fileprivate static func loadAsUInt8UseAsUInt32() {
    let uint8Pointer = UnsafeMutablePointer<UInt8>.allocate(capacity: 16)
    uint8Pointer.initialize(repeating: 127, count: 16)
    let uint32Pointer = UnsafeMutableRawPointer(uint8Pointer).bindMemory(
      to: UInt32.self, capacity: 4)
    //DO NOT TOUCH uint8Pointer ever again. Not for use if thing would exist outside of function
    //Do something with uint32Pointer pointer...
    uint32Pointer.deallocate()
  }

  //TODO: Initialize/Factory method COPY that works well retrieving copy of C array

  //  public func makeFromSecretArray(count:Int) -> [Int] {
  //  //Count for this initializer is really MAX count possible, function may return an array with fewer items defined.
  //  //both buffer and initializedCount are inout
  //  let tmp = Array<CInt>(unsafeUninitializedCapacity: count) { buffer, initializedCount in
  //  //C:-- void random_array_of_zero_to_one_hundred(int* array, const size_t n);
  //  random_array_of_zero_to_one_hundred(buffer.baseAddress, count)
  //  initializedCount = count // if initializedCount is not set, Swift assumes 0, and the array returned is empty.
  //  }
  //  return tmp.map { Int($0) }
  //  }

}

//MARK: Working With Structs

private protocol HasMyNumber {
  var myNumber: Int { get }
}

private func withPointerToMyNumber<T: HasMyNumber, R>(example: T, body: (UnsafeRawPointer) -> R)
  -> R
{
  withUnsafePointer(to: example) { (ptr: UnsafePointer<T>) in
    let rawPointer = (UnsafeRawPointer(ptr) + MemoryLayout<T>.offset(of: \.myNumber)!)
    return body(rawPointer)
  }
}
