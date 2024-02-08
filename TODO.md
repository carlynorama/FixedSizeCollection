# Wishlist & TODOs


## Proto Specs

A done in this context means initial interface, no assurance on quality of implementations yet.  


- [ ] Must work well with C
    - [ ] examples from C interop section below
    - [ ] Fancy inits
        - [x] init directly from C fixed with array definition. (and test [x])
        - [~] improved tuple functions to use Parameter pack 
                - [x] some functions yes, 
                - [ ] others cause compiler crash.
        - [ ] ?? FixedSizeCollection(copyOf: TypedPointer, count:N)
        - [x] be able to put back into C var (and test [x])
        - [x] init from buffer view  (and test [x])
    - [ ] ?? coerce it to and from an equivalent tuple form using "as" 
    - [ ] pass an individual element or slice to a C function.
    - [ ] replace functions must work with tuples, too.
    - [ ] provide copy that is a tuple version 
- [ ] Default Values initial call
    - [ ] ~~?? Stored value?~~ remove stored value in favor of explicit functions
    - [ ] enable certain methods for when Element is `ExpressibleByIntegerLiteral` or Optional
    - - ~~[ ] default is a keyword, is there a better label ~~ no longer going to be a thing. 
- [ ] If called a Collection it should match Collection preconceptions as much as possible. 
    - [ ] ?? Many collection conformances require an empty initializer, which is not a thing for this type. TBD how to handle this. 
    - [ ] ?? the storage type for this collection should potentially be ~Copyable, consequences? 
    - [  ] ?? & pointing to typed version of storage? (see ?? on Unsafe)
        - [  ] if not, different prefix that returns pointer to storage? see 
    - [ ~ ] subscripts 
        - [x] add bounds checking as subscripts should [match collections](https://github.com/apple/swift-collections/blob/main/Sources/SortedCollections/SortedSet/SortedSet%2BSubscripts.swift) bounds check.
        - [x] subscript check function
            - [ ] what kind of fatal error should that be? 
        - [x] get individual
        - [x] set individual
        - [x] test individual [x] get, [x] set
        - [ ~ ] get bounds (have a version that returns Array copy, not Slice)
        - [x] set bounds
        - [x] test bounds [ x] get [x] set
    - [x] when [unchecked:] becomes a thing, implement it, but in the mean time an unsafe insert that will skip bounds checking. `.gunc(at: )`, `.sunc(at:)`
        - [x] proto gunc
        - [x] proto sunc
        - [x] tests [x] gunc [x] sunc
    - [ ] No `append` for now. Makes no sense for the _Storage type. But yes an insert on FSC with optional Element type that will look for a default value to replace.
        - [x] replace(first: E, with: E), [x] test
        - [x] replace(at: N, with: E), [x] test
        - [x] replace(at: R<N>, with: E), [x] test
        - [x] replace(at: R<N>, with: [E]), [x] test
        - [x] replaceAll(with:E) [x] test
        - [ ] replaceAll(_ E: with:E) / replaceAll(where:with) [ ] test
            - [ ] plug into index / Sequence first? What's available "for free"
    - [x] variadic (array) inits
        - [x] written
        - [x] tests
    - [ ] [Subsequence](https://github.com/apple/swift-collections/blob/427083e64d5c4321fd45654db48f1e7682d2798e/Sources/OrderedCollections/OrderedSet/OrderedSet%2BSubSequence.swift#L24)
        - [ ] needed for RangeReplaceableCollection conformance (see Replace.swift)
    - [~] the withUnsafes*
       [x] all implmented
       [x] all tested
       [] ?? I have them pointing to _storage, right with that spelling? see & Question.
        - [ ] get subsequence range @inlinable
- [ ] mask, flood and clear
    - [x] for .zero and nil defined Elements allow .clear() and .clear(at:)
        - [x] clear for numerics [x] test
        - [x] clear for optionals [x] test
    - [x] ~~.flood(with:)~~ replaceAll [x] test
    - [ ] some kind of [Bool][Element] zip feature, maybe called mask. TBD.
        - [ ] related to replaceAll(where)
- [ ] a safe accessor that will throw instead of fatal error if out of bounds
- [ ] matrix
    - [ ] matrix init
    - [ ] matrix access
    - [ ] matrix update
- [ ] make _Storage a protocol so it can be swapped out. 
    - [ ] identify everything being used that's Data's
    - [ ] include it in the protocol
- [ ] Integration into Swift, Swift Collections, or just a Package with a 1.0 release (Longer Term)
    - [ ] what is going to be the future type of choice for C Arrays? 


## Documentation

### inline
- [ ] all of it
- [ ] make headers look more like official headers, but not official headers

### reference
- [ ] all of it
- [ ] the badges / swift level info
- [ ] make README more like normal readme. Add context in to different doc

### meta
- [ ] Split this TODO into separate files?

## Testing Meta & Misc
-  ~~ [ ] in a package manager how to have a per file target inclusion? (testing functions) ~~
- [x] separate testing code C and Swift Bridge for testing code C into own targets 
    - [ ] is this best approach for using C (C++?) with XCTest
- [ ] the test messages could be better
- [ ] the testing subgroups could be smaller
- [ ] move all the tests out side of the measures
- [ ] ?? how to measure throwing functions. Do I really have to catch them?
- [ ] All the C is currently just for testing, but should add nullability(most modern?)?, but leave a chunk old style with header wrapper [as explained here](https://forums.swift.org/t/inconsistent-treatment-bewtween-swift-pointer-parameters-and-c-ones/69855) and [here](https://discourse.llvm.org/t/rfc-nullability-qualifiers/35672/18) so folks referring to test library for application ideas can have that as a reference.

## Repo Meta
- [x] [swift-format](https://github.com/apple/swift-format/) CLI installed & ran with default rules.
        ```
            #on new branch b/c -i is in-place
            #note flags are NOT -ri, . works for all current directory
            swift-format format -r -i
            swift-format lint -r . 
        ``` 
- [ ] add plugin? it's not in the other Swift repos, which do official Swift projects actually use? 
- [ ] platform info in Package.swift, TBD how far back? 
- [ ] what .clang-format file to use? 

## Misc & General Research Q's 
- [ ] Hmm... this should be [~Copyable](https://github.com/apple/swift-evolution/blob/main/proposals/0390-noncopyable-structs-and-enums.md) shouldn't it? 
    - Loose ability to conform to RandomAccessCollection?

- [ ] Iterators and Stream, what comes with Random Access Collection? 
- [ ] SIL Builtins,  @inline(always), @alwaysEmitIntoClient for making Matrix type (https://forums.swift.org/t/approaches-for-fixed-size-arrays/58894/9)
- [ x ] [faster bounds comparator](https://forums.swift.org/t/why-does-swift-use-signed-integers-for-unsigned-indices/69812/5)`UInt(bitPattern: x &- l) < UInt(bitPattern: h - l)` by TellowKrinkle
- [ ] [Cxx too?]
    - [] [Which Types](https://forums.swift.org/t/approaches-for-fixed-size-arrays/58894/19)?(CXType_ConstantArray, CXType_Vector, CXType_IncompleteArray, CXType_VariableArray, CXType_DependentSizedArray)
    - [] [Matrix<10,100>](https://forums.swift.org/t/approaches-for-fixed-size-arrays/58894/24)
- [ ] "getting a pointer to it promotes the value to the heap AFAIK" [post](https://forums.swift.org/t/approaches-for-fixed-size-arrays/58894/25) how to test?
- [x] tuple inits were improved weren't they? no more limit on SwiftUI Group{}, look that up. 
    - YES! [Variadic Generics](https://forums.swift.org/t/variadic-generics/54511) thing. 

- [ ] seems related:
    - https://forums.swift.org/t/pitch-introduce-for-borrow-and-for-inout-to-provide-non-copying-collection-iteration/62549
    - https://forums.swift.org/t/pitch-borrow-and-inout-declaration-keywords/62366
    - https://forums.swift.org/t/why-does-the-withunsafemutablebufferpointer-closure-take-an-inout-parameter/6794/11
    - https://github.com/apple/swift-evolution/blob/main/proposals/0322-temporary-buffers.md
    - https://github.com/apple/swift-evolution/blob/main/proposals/0324-c-lang-pointer-arg-conversion.md
    - https://forums.swift.org/t/pitch-non-escapable-types-and-lifetime-dependency/69865
    - https://github.com/apple/swift-evolution/blob/main/proposals/0390-noncopyable-structs-and-enums.md
    - https://forums.swift.org/t/roadmap-language-support-for-bufferview/66211
    - https://forums.swift.org/t/a-roadmap-for-improving-swift-performance-predictability-arc-improvements-and-ownership-control/54206
    - https://forums.swift.org/t/short-array-optimisation/68082/3 
    - https://forums.swift.org/t/pitch-synchronous-mutual-exclusion-lock/69889
    

## NonC Interop Targets

> An example use-case is my voxel game which uses an ECS, all components store their data on globals and many of those components want to embed 32768 elements since that's the chunk size. Since the whole point is to have all that laid out in memory for cache-friendly access, having any indirection in a component defeats the purpose. [forum](https://forums.swift.org/t/approaches-for-fixed-size-arrays/58894/79)

> It could also easily replace ManagedBuffer which would be a win in and of itself in my humble opinion.[forum](https://forums.swift.org/t/approaches-for-fixed-size-arrays/58894/79)

> As a vector type backing [forum](https://forums.swift.org/t/approaches-for-fixed-size-arrays/58894/79) Also `Vector<T, size: Int>` [here](https://forums.swift.org/t/checking-in-more-thoughts-on-arrays-and-variadic-generics/4948/16) 



## C interop targets

- see: https://forums.swift.org/t/approaches-for-fixed-size-arrays/58894/59

- [ ] (phantom non working const pointers, ghost in one devs machine?)

- [ ] [working with large C array](https://forums.swift.org/t/approaches-for-fixed-size-arrays/58894/79)

- [ ] [working with global C arrays](https://forums.swift.org/t/accessing-address-of-a-c-global-const-variable-cannot-pass-immutable-value-as-inout-argument/69468/1).

- ~~[ ] ?? importing C array fields twice, once under their own fieldName as the existing homogeneous tuple representation, and again as fieldNameArray or something similar as a fixed size array?~~ Not for now. 

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
