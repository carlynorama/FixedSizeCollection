# FixedSizeCollection


## References
- https://forums.swift.org/t/approaches-for-fixed-size-arrays/
- https://github.com/apple/swift-evolution/blob/main/proposals/0322-temporary-buffers.md

## Inits

### Currently Implemented

```swift
    init(_ count:Int, default d:Element, initializer:() -> [Element] = { [] }) 
    init(initializer:() -> [Element])
    init(dataBlob: Data, as: Element.Type)
```


### Inits of types from other languages

[Benchmark repo](https://github.com/jabbalaci/SpeedTests) 
```text
C:         int cache[10];
C++:       int cache[10];
fortran:   integer, dimension(10) :: cache
Go:        [10]int
Java.      new int[10];
Julia:     ntuple(i -> i^i, 9)...  # Tuple{Vararg{T,N}}
Kotlin:    Array(10) { }
nim:       array[10, int]
Ruby:      [i32; 10]
```

Scheme:
```
  (list->vector
    (cons
      0
      (let loop ((i 1))
        (if (> i 10)
          '()
          (cons (expt i i)
                (loop (+ i 1))))))))
```

### Ideas from Thread

What to do about default value. There has to be one. Even if its nil. Could be 0 for numerics. 

```swift
//What I'm working on.
var myArray:[Int](10)
var myArray:[Int](10, default:Int) //and longer, "size:" is a ? 

var myArray:[Int, 10]
var myArray:[Int * 10], var myArray:[Int x 10]
@const myArray[Int] = //wasn't clear
@const existingArray //would work like Object.freeze?
```

## Really, `Data`?

No, not really, but it's easy for prototyping and will keep me from dropping into C.

Previous underlying storage idea by Joe_Groff

//https://forums.swift.org/t/approaches-for-fixed-size-arrays/58894/33

```swift
@moveonly
struct SmallArray<capacity: Int, T> {
  private(set) var count: Int

  @UninitializedBuffer(count: capacity)
  private var storage: BufferView<T>

  init() { count = 0 }
  mutating func append(value: T) {
    assert(count < capacity)
    storage.baseAddress[count].initialize(with: value)
    count += 1
  }

  deinit {
    for i in 0..<count {
      (storage.baseAddress + i).destroy()
    }
}
```

Previous underlying storage concern: 

> Lastly, I think that at the same time fixed-size arrays with inline storage are introduced, there should also be a fixed-size array type with out-of-line storage which should be slightly easier to reach for. Without an out-of-line-storage alternative, I predict that we'll see a lot of people have gigantic fixed-size arrays of gigantic types in their structs without realizing how much overhead they incur. - fclout

https://forums.swift.org/t/approaches-for-fixed-size-arrays/58894/46


Another could be to just use a tuple as the backing memory.
