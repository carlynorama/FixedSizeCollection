# FixedSizeCollection


## Major Use Cases

- Interfacing with C
- Speed.
    - "guaranteed stack" 
    - Scratch Buffers Audio
    - Scratch Buffers Graphics
- ??? 

## Desired Specs to Support Use Cases

Specs are in [TODO.md](TODO.md)

## Inits

### Currently Implemented

```swift
    init(_ count:Int, default d:Element, initializer:() -> [Element] = { [] }) 
    init(initializer:() -> [Element])
    init(dataBlob: Data, as: Element.Type)
```

## Sugar and Spellings

This implementation does not take a stron opinion as to what the final sugar should be. 

### Examples from other languages

[Benchmark repo](https://github.com/jabbalaci/SpeedTests) 
```text
C:         int cache[10];
C++:       int cache[10]; const long v [] = {}; 
fortran:   integer, dimension(10) :: cache
Go:        [10]int
Java:      new int[10];
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

### This Implementation

No init sugar implemented but this implementation would support easily

```swift
var myArray:[Int](10)
var myArray:[Int](10, default:Int) //and longer, "size:" is a ? 
var myArray:[Int]([10,10], default) // for matrix inits. 
```

### For view-only type

```
@FixedSizeArray(count: 512) var buffer: BufferView<UInt8> 
@FixedSizeArray<Int>(count: 512) var buffer

```

Would also like to consider 

```
myExistingArray.withFixedMemoryAlloc { fixedCollection in
    //Do my thing in
}
```




Others suggested, presumably with the idea of allocated memory behind them. [But maybe not](https://forums.swift.org/t/approaches-for-fixed-size-arrays/58894/30)

```
var myArray:[Int, 10]
var myArray:[Int * 10], var myArray:[Int x 10], var Array<String>[3]
Array<String>[3]
var myArray(Int * 10) //has tuple implications
struct FixedArray<T, N: Int> {...}.
Int[3], Int[2][3],  Int[]
var myArray:Int[_] = [1,2,3] for derived fixed size.
```

## Backing Memory: `Data`? Really?

No, not really really for the final implementation, but it's easy for prototyping and will limit the temptation to make a novel C or C++ backing type (prematurely?).

There are pros and cons to every underlying memory choice. One main thrust of the motivating forum post is that a Fixed Array could be a property wrapper instantiating a view on an exiting type. There seem to be similarities to JavaScript's Object.freeze/Object.seal while the fixed sized array is in use.  

[js_obj_fr]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/freeze
[js_obj_sl]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/seal

This is a harder task to get correct and a lot of API considerations can be worked out using the easier path. Open to pull requests that do better. One concern was that a view only type would it lead indirect holding of a struct inside itself. 

Also, it may make sense to have differing memory backings available like some other collections offer (contigous or not, etc) 

[Example view based suggestion by Joe_Groff](https://forums.swift.org/t/approaches-for-fixed-size-arrays/58894/33):

```swift
@moveonly
struct SmallArray<capacity: Int, T> {
  private(set) var count: Int

  @UninitializedBuffer(count: capacity)
  private var storage: BufferView<T>  //NOTE: Future Type

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

This repo's implementation needs for count to be a let and all underlying values to be allocated (to someone! in this case, a "_storage" with at least a default value. Append can't happen, the memory, whoever owns it, must exist. This is to maximize compatibility with C structures, which may not be the community's ultimate highest goal. TBD. While append might not make sense in this context, this will allow for inserts that have a similar API to Set, perhaps, (especially if the Element type is an Optional) where the insert can find its way to the first available nil or perhaps default value. 

Previous underlying storage concern: 

> Lastly, I think that at the same time fixed-size arrays with inline storage are introduced, there should also be a fixed-size array type with out-of-line storage which should be slightly easier to reach for. Without an out-of-line-storage alternative, I predict that we'll see a lot of people have gigantic fixed-size arrays of gigantic types in their structs without realizing how much overhead they incur. - fclout

https://forums.swift.org/t/approaches-for-fixed-size-arrays/58894/46


Another could be to just use a tuple as the backing memory. The feel on the street apears to be that this would come with too much baggage.


## References
- Motivating Forum Post: https://forums.swift.org/t/approaches-for-fixed-size-arrays/
- Previous Pitch: https://forums.swift.org/t/pitch-improved-compiler-support-for-large-homogenous-tuples/49023

### Related Proposals
- https://github.com/apple/swift-evolution/blob/main/proposals/0322-temporary-buffers.md
- https://github.com/apple/swift-evolution/blob/main/proposals/0324-c-lang-pointer-arg-conversion.md

### Code that does similar or related things

- [Array](https://github.com/apple/swift/blob/2fa1022a912a1c07db2a3596d494adb35a28b5f3/stdlib/public/core/Array.swift)
- [Collection](https://github.com/apple/swift/blob/2fa1022a912a1c07db2a3596d494adb35a28b5f3/stdlib/public/core/Collection.swift)

- https://github.com/search?q=org%3AApple%20Data&type=code
- https://github.com/search?q=org%3AApple+withCString&type=code
- https://github.com/apple/swift/blob/main/stdlib/public/core/StaticString.swift#L72
- https://github.com/apple/swift-corelibs-libdispatch/blob/bb1cb6afb589e911cd808cb98e03d54603b14e16/src/swift/Data.swift#L16
- https://github.com/apple/swift-collections
- https://github.com/apple/swift-algorithms
- https://github.com/karwa/swift-url/blob/f4a66a7645ab40a814fae838f33cf346bb726a3d/Sources/WebURL/Util/Pointers.swift#L324
- https://forums.swift.org/t/a-large-fixed-width-integer-swift-package/62743
- 25:52 of WWDC 2020 [Safely Manage Pointers in Swift](https://developer.apple.com/wwdc20/10167)
- https://github.com/carlynorama/UnsafeWrapCSampler
- https://github.com/carlynorama/UnsafeExplorer
