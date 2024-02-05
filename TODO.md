# Wishlist & TODOs



## Proto Specs

A done in this context means initial interface, no assurance on quality of implementations yet.  


- [ ] Must work well with C
    - [ ] examples from C interop section
        - [ ] make [nonmutable inout prefix](https://forums.swift.org/t/accessing-address-of-a-c-global-const-variable-cannot-pass-immutable-value-as-inout-argument/69468/1), please. to compliment mutable gotten from &
    - [ ] ?? coerce it to and from an equivalent tuple form using "as" 
    - [ ] ?? looking for zeros / default value as nil?
    - [ ] pass an individual Element or slice to a C function.
    - [ ] FixedSizeCollection(copyOf: TypedPointer, count:N)
    - [ ]
    - [ ] ?? Misc Options from the post
        - [ ] ?? importing C array fields twice, once under their own fieldName as the existing homogeneous tuple representation, and again as fieldNameArray or something similar as a fixed size array?
        - - [ ] ?? behavior based on language version mode, so that Swift 6 code sees the imported field in its array form?
- [ ] If called a Collection it should match Collection preconceptions as much as possible. 
    - [ ~ ] proto get and set subscripts already done, but don't have bounds checking and subscript should [match collections](https://github.com/apple/swift-collections/blob/main/Sources/SortedCollections/SortedSet/SortedSet%2BSubscripts.swift), they need the bounds check.
        - [ x ] subscript check function
            - [ ] what kind of fatal error should that be? 
        - [ x ] get individual
        - [ x ] set individual
        - [ x ] test individual [x] get, [x] set
        - [ ~ ] get bounds (have a version that returns Array copy, not Slice)
        - [ x ] set bounds
        - [ x ] test bounds [ x] get [ x ] set
    - [ ] when [unchecked:] becomes a thing, implement it, but in the mean time an unsafe insert that will skip bounds checking. `.gunc(at: )`, `.sunc(at:)`
        - [x] proto gunc
        - [x] proto sunc
        - [x] tests [x] gunc [x] sunc
    - [ ] No `append`. Makes no sense. But yes an insert on FSC with optional Element type that will look for a nil value to replace.
    - [ ] variadic inits
    - [ ] [Subsequence](https://github.com/apple/swift-collections/blob/427083e64d5c4321fd45654db48f1e7682d2798e/Sources/OrderedCollections/OrderedSet/OrderedSet%2BSubSequence.swift#L24)?
        - [ ] get subsequence range, @inlinable and self.defaultValue ans SubSequence
    - pointer prefix sugar
        - [ ] & returns mutable pointer like Collection
- [ ] a safe accessor that will throw instead of fatal error if out of bounds
- [ ] matrix[0][24] style init of some format
- [ ] matrix access


## Documentation

### inline
- [ ] all of it
- [ ] make headers look more like official headers, but not official headers

### reference
- [ ] all of it
- [ ] the badges / swift level info
- [ ] make README more like normal readme. Add context in to different doc

### meta
- [ ] Split this TODO into separate files

## Testing Meta & Misc
-  ~~ [ ] in a package manager how to have a per file target inclusion? (testing functions) ~~
- [x] separate testing code C and Swift Bridge for testing code C into own targets 
    - [ ] is this best approach for using C (C++?) with XCTest

## Repo Meta
- [ x ] [swift-format](https://github.com/apple/swift-format/) CLI installed & ran with default rules.
        ```
            #on new branch b/c -i is in-place
            #note flags are NOT -ri, . works for all current directory
            swift-format format -r -i
            swift-format lint -r . 
        ``` `)
- [   ] add plugin? it's not in the other Swift repos, which do official Swift projects actually use? 
- [ ] 
- [ ] platform info in Package.swift, TBD how far back? 
- [ ] what .clang-format file to use? 

## Misc & General Research Q's 
- [ ] tuple inits were improved weren't they? no more limit on SwiftUI Group{}, look that up.
- [ ] default is a keyword, is there a better label 
- [ ] Iterators and Stream, what comes with Random Access Collection? 
- [ ] SIL Builtins,  @inline(always), @alwaysEmitIntoClient for making Matrix type (https://forums.swift.org/t/approaches-for-fixed-size-arrays/58894/9)
- [ ] [Cxx too?]
    - [] [Which Types](https://forums.swift.org/t/approaches-for-fixed-size-arrays/58894/19)?(CXType_ConstantArray, CXType_Vector, CXType_IncompleteArray, CXType_VariableArray, CXType_DependentSizedArray)
    - [] [Matrix<10,100>](https://forums.swift.org/t/approaches-for-fixed-size-arrays/58894/24)
- [ ] "getting a pointer to it promotes the value to the heap AFAIK" [post](https://forums.swift.org/t/approaches-for-fixed-size-arrays/58894/25) how to test?
- [ ] [faster bounds comparator](https://forums.swift.org/t/why-does-swift-use-signed-integers-for-unsigned-indices/69812/5)`UInt(bitPattern: x &- l) < UInt(bitPattern: h - l)`


## C interop targets

- see: https://forums.swift.org/t/approaches-for-fixed-size-arrays/58894/59

- [ ] [nonmutable inout](https://forums.swift.org/t/accessing-address-of-a-c-global-const-variable-cannot-pass-immutable-value-as-inout-argument/69468/1), please.

[SysEx messages in CoreMIDI](https://forums.swift.org/t/approaches-for-fixed-size-arrays/58894/25)

From: https://forums.swift.org/t/approaches-for-fixed-size-arrays/58894/59
Looked reasonable. See Color example in UnsafeExplorer.

```swift
struct Sensor_t {
  var name: (CChar, CChar, CChar, CChar.. 256 times...)
  var valuesCount: Int
  var values : (Double, Double, Double.. 8192 times... ?) // No, Boom !! Simply not possible !! Swift Tuple size limit is 4096 elements    
}
```

```swift
// Swift Side I would like:

// The C struct imported in Swift like this
struct Sensor_t {
  var name: FixedArray<CChar> //Note: auto detected the final 0 for count.
  var valuesCount: Int //Note: that would be part of the FixedArray
  var values: FixedArray<Double>   
}

// I can use the struct like this to read the sensor
var sensor = Sensor_t()
readSensor(&sensor)

let sensorName: String = String(cstring: sensor.name)
print(“The sensor name is: \(sensorName)”)

for index in 0..<sensor.valuesCount {
    sensorValue = sensor.values[index]
    print(sensorValue)
}

// or better

for sensorValue in sensor.values {
    print(sensorValue)
}

// I can use the struct like this to write to the sensor

var sensor = Sensor_t()
sensor.name = FixedArray<CChar>(fromString: "Temperature Sensor")

sensor.valuesCount = 6000
var simulatedTemperature = 20.0
for index in 0..< sensor.valuesCount {
    sensor.values[index] = simulatedTemperature
    simulatedTemperature += 1.5
}

writeSensor(&sensor)
```




//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2024 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//
For C or C++ source or header files, the code header should look this:

//===-- subfolder/Filename.h - Very brief description -----------*- C++ -*-===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2024 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//
///
/// \file
/// This file contains stuff that I am describing here in the header and will
/// be sure to keep up to date.
///
//===----------------------------------------------------------------------===//
