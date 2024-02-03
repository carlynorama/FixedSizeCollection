# Wishlist & TODOs


## Specs
- [ ] Must work well with C tuples 
    - see: https://forums.swift.org/t/approaches-for-fixed-size-arrays/58894/59
    - [ ] coerce it to and from an equivalent tuple form using "as" ?
    - [ ] looking for zeroed memory vs zero value possible?
- [ ] proto get and set subscripts already done
- [ ] No `append`. Makes no sense. But yes an insert on FSC with optional Element type that will look for a nil value to replace.
- [ ] a safe insert that will do bounds checking
- [ ] a safe accessor that will throw instead of fatal error if out of bounds


## Repo Meta
- [ ] add linter plugin
- [ ] the badges / swift level info
- [ ] platform info in Package.swift




## C interop targets

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
