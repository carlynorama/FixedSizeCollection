# Wishlist & TODOs


## Specs
- [ ] Must work well with C tuples 
    - see: https://forums.swift.org/t/approaches-for-fixed-size-arrays/58894/59
    - [ ] coerce it to and from an equivalent tuple form using "as" ?
    - [ ] looking for zeroed memory vs zero value possible?
    - [ ] pass an individual Element or slice to a C function.
    - Misc Options from the post
        - importing C array fields twice, once under their own fieldName as the existing homogeneous tuple representation, and again as fieldNameArray or something similar as a fixed size array,
        - conditionalizing the behavior on language version mode, so that Swift 6 code sees the imported field in its array form.
- [ ] proto get and set subscripts already done, but subscript should [match collections](https://github.com/apple/swift-collections/blob/main/Sources/SortedCollections/SortedSet/SortedSet%2BSubscripts.swift), they need the bounds check.
- [ ] No `append`. Makes no sense. But yes an insert on FSC with optional Element type that will look for a nil value to replace.
- [ ] when [unchecked:] becomes a thing, implement it.
- [ ] an unsafe insert that will skip bounds checking. `.gunc(at: )`
- [ ] a safe accessor that will throw instead of fatal error if out of bounds
- [ ] matrix[0][24] style init of some format
- [ ] matrix access
- [ ] variadic inits



## Repo Meta / General Research Q's 
- [ ] add linter plugin
- [ ] the badges / swift level info
- [ ] platform info in Package.swift
- [ ] in a package manager how to have a per file target inclusion? (testing functions)
- [ ] tuple inits were improved weren't they? no more limit on SwiftUI Group{}, look that up.
- [ ] default is a keyword, is there a better label 
- [ ] Iterators and Stream, what comes with Random Access Collection? 
- [ ] SIL Builtins,  @inline(always), @alwaysEmitIntoClient for making Matrix type (https://forums.swift.org/t/approaches-for-fixed-size-arrays/58894/9)
- [ ] [Cxx too?](
    - [] [Which Types](https://forums.swift.org/t/approaches-for-fixed-size-arrays/58894/19)?(CXType_ConstantArray, CXType_Vector, CXType_IncompleteArray, CXType_VariableArray, CXType_DependentSizedArray)
    - [] [Matrix<10,100>](https://forums.swift.org/t/approaches-for-fixed-size-arrays/58894/24)
- [ ] "getting a pointer to it promotes the value to the heap AFAIK" [post](https://forums.swift.org/t/approaches-for-fixed-size-arrays/58894/25) how to test?



## C interop targets

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
