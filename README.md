# FixedSizeCollection


https://forums.swift.org/t/approaches-for-fixed-size-arrays/
https://github.com/apple/swift-evolution/blob/main/proposals/0322-temporary-buffers.md

- Must work well with C tuples
    - coerce it to and from an equivalent tuple form using "as" ?
    - looking for zeroed memory vs zero value possible?


- get and set subscripts already done
- No `append`. Makes no sense. But yes an insert on FSC with optional Element type that will look for a nil value to replace.



## Really, Data?

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

Lastly, I think that at the same time fixed-size arrays with inline storage are introduced, there should also be a fixed-size array type with out-of-line storage which should be slightly easier to reach for. Without an out-of-line-storage alternative, I predict that we'll see a lot of people have gigantic fixed-size arrays of gigantic types in their structs without realizing how much overhead they incur. - fclout

https://forums.swift.org/t/approaches-for-fixed-size-arrays/58894/46


Another could be to just use a tuple as the backing memory.
