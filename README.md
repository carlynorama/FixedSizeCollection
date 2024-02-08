# FixedSizeCollection

See  https://forums.swift.org/t/approaches-for-fixed-size-arrays/

Previously working with C Arrays in Swift was frequently best solved by writing custom code for custom situations due to the nature of Tuples. With the [large amount of work being done](#related-pitches-and-proposals) to make the compiler ready for better C Array interaction it begins to become more reasonable to think about what a general API could be.  

This FixedSizedCollection is intended to be a possible version as API on a bag of bytes service that will be able make a solid commitment to compiler that those bytes all exist and have a value of type Element and the size of that memory will not change for the lifetime of that FixedSizedCollection. That BytesService could be owned and managed by the FixedSizedCollection, or by something reliable a client offers up on initialization (a StorageView, e.g,).

The FixedSizedCollection itself can then vend Views or Copies as needed. Those views or copies could be to its full collection or SubSequences.

This could end up being a Protocol once StorageView exists, but in the mean time... bytes that someone else can dealloc can't make promises so currently this collection has to have a copy. 

## Major Use Cases

- Interfacing with C
- Speed.
    - "guaranteed stack" 
    - Scratch Buffers Audio
    - Scratch Buffers Graphics
    - Games, ECS backing (RealityKit, too)
- ??? 

## Desired Specs to Support Use Cases

Specs are in [TODO.md](TODO.md)

## Inits this Implementation

### Currently Implemented

All inits create copies into the types personal _Storage (currently Data). Potentially could be a _BufferView instead. 

```swift
    init(_ count:Int, default d:Element, initializer:() -> [Element] = { [] }) 
    init(_ count: Int, fillValue d: Element, _ values:Element...)
    internal init(_ count:Int, storage: _Storage, fillValue d: Element?, as: Element.Type) //which is Data for now
```

Theses all have a duplicate overload where count can be inferred from the values submitted that also doesn't require a default set. 

Two inits only have inferred counts, but that could be changed. 
```swift 
//named because this init is an erased type, but will only work for a tuple.
//TODO: replace with parameter pack? 
 public init<T>(asCopyOfTuple source:T, ofType:Element.Type, fillValue d: Element? = nil)

 //name because asCopy, because ideally one day the _Storage could be the 
 //buffer pointer or something like that once that's safe (see work on 
 //StorageView).
 public init(asCopy pointer:UnsafeBufferPointer<Element>, fillValue d: Element? = nil)
 ```

## Sugar and Spellings

This implementation does not take a strong opinion as to what the final sugar should be. It merely provides init methods with parameters. 

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
Ruby       [0] + (1..9).map { |n| n**n } //is it the only kind? 
rust:      [i32; 10]
```

Scheme:
```
  ((list->vector
    (cons
      0
      (let loop ((i 1))
        (if (> i 10)
          '()
          (cons (expt i i)
                (loop (+ i 1))))))))
```

### For view-only type

```
@FixedSizeArray(count: 512) var buffer: BufferView<UInt8> 
@FixedSizeArray<Int>(count: 512) var buffer

```
Also closure? 

```
myExistingArrayOrArraySlice.withFixedMemory { fixedCollection in
    //Do my thing in
}
```

### Storage Backed

Others suggested, presumably with the idea of allocated memory behind them. [But maybe not](https://forums.swift.org/t/approaches-for-fixed-size-arrays/58894/30)(Joe_Groff)

Additional ideas are in the discussion of [Defaults](#default-values). 

```
//Orig, number first improved composability
(5 x Int) //*
var (3 * Int)  // 
var myArray:[Int, 10]
var myArray:[Int * 10], var myArray:[Int x 10], var Array<String>[3]
Array<String>[3]
var myArray(Int * 10) //has tuple implications
struct FixedArray<T, N: Int> {...}.
Int[3], Int[2][3]
var myArray:Int[_] = [1,2,3] for derived fixed size.
var myArray:Int[ ] = [1,2,3] //†
(Int, 6) or (6, Int)//**
```


> `*` We want multi-dimensional indexing to read in the same order as array shape.
>
>If we had it like var array: ((Int * 3) * 4) then confusingly the last element of the last triple would be found at array[3][2]!
>
>So it's better to place the multiplicity on the left-hand side like var array: (4 * (3 * Int)). Read it like "four triples of Int".
>
>And next, it would be convenient if we could omit the inner parentheses as var array: (4 * 3 * Int). But that would require the type-level * operator to be right associative, which is again confusing because the value-level * is left-associative.
>
>So that gets us to consider another operator. The × symbol would be cool, but it'd be the first standard non-ASCII character in Swift syntax, so…
> [recap by pyrtsa](https://forums.swift.org/t/approaches-for-fixed-size-arrays/58894/104)


> † Two options about the "Int[]" syntax notation:
>  - the type is inferred as Int[3] based on the subsequent initializing expression.
>  - (this is how "int x[] = [1, 2, 3];" is inferred to be "int x[3]" in C).
>  - this notation could be used as a synonym for the "normal" [Int] array.
> -- [tera](https://forums.swift.org/t/approaches-for-fixed-size-arrays/58894/86)

> `**` higlighted because from [previous post](https://forums.swift.org/t/pitch-improved-compiler-support-for-large-homogenous-tuples/49023/9) 

## Backing Memory: `Data`? Really?

No, not really really for the final implementation, but it's easy for prototyping and will limit the temptation to make a novel C or C++ backing type (prematurely?). By storing it as Data the implementation can practice accessing raw data which maximizes flexibility for future implementation decisions. 

There are pros and cons to every underlying memory choice. One main thrust of the motivating forum post is that a Fixed Array could be a property wrapper instantiating a view on an exiting type. There seem to be similarities to JavaScript's [Object.freeze][js_obj_fr]/[Object.seal][js_obj_sl] while the fixed sized array is in use.  

[js_obj_fr]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/freeze
[js_obj_sl]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/seal

This is a harder task to get correct and a lot of API considerations can be worked out using the "easier" storage backed path. One concern was that a view only type would it lead indirect holding of a struct inside itself. 

Also, it may make sense to have differing memory backings available like some other collections offer (contiguous or not, etc) 

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

This repo's implementation needs for count to be a let and all underlying values to be allocated to a "_storage" value with at least a default value. Append can't happen, the memory, whoever owns it, must exist by then end of the init. This is to maximize compatibility with C structures, which may not be the community's ultimate highest goal. TBD. While append might not make sense in this context, a flexible collection `replace` method would be beneficial, includeing a replace(firstOf:with:)

Previous underlying storage concern: 

> Lastly, I think that at the same time fixed-size arrays with inline storage are introduced, there should also be a fixed-size array type with out-of-line storage which should be slightly easier to reach for. Without an out-of-line-storage alternative, I predict that we'll see a lot of people have gigantic fixed-size arrays of gigantic types in their structs without realizing how much overhead they incur. - [fclout](https://forums.swift.org/t/approaches-for-fixed-size-arrays/58894/46)

Tuples as the backing memory have been floated and rejected.  The feel on the street appears to be that this would come with too much baggage and the only reason it's been suggested is because that's what the C currently gets mapped to. 

## Default Values

A fixed size array needs to know what value to use if it's stuck with a location that it's been told to create or clear without instruction as to a new value. Should that value simply be a required parameter on any function that could result in the ambiguity or a stored value for the instance? Or should the default value be a product of the associated type instead (zero for things that have one, nil for optionals...)

Examples possibilities: 

```
//Comes with type
[Int](7) //  => a FSC of 7 .zero
var myFSC:[Int](7) = [3,2,1]. //=>  [3,2,1,0,0,0,0]
[Int?](7) // => to a FSC of 7 nil
[MyType](7) //=> leads to 7 what? Is there a protocol Elements need to conform to? 

//set at init
var myFSC:[Int](7, default: 5) = [3,2,1] // =>  [3,2,1,5,5,5,5]
myFSC.insert(12) => [3,2,1,12,5,5,5]
myFSC.clear() => [5,5,5,5,5,5,5]
//1st: param preceding ellipsis are the defaults. 
//2nd: last param before ellipsis is default *
var x: Int[7] = [0 ...]
var x: Int[7] = [3, 2, 1, 0 ...]*
var x: Int[7] = [3, 2, 1, rest: 0]**

//require per function
var myFSC:[Int](7, default: 5) = [3,2,1] // =>  [3,2,1,5,5,5,5]
myFSC.insert(12, atFirstLocationOf: 5) //=> [3,2,1,12,5,5,5]
myFSC.setAll(to:5) //=> [5,5,5,5,5,5,5]
```

*[tera](https://forums.swift.org/t/approaches-for-fixed-size-arrays/58894/86)

**[wadetregaskis](https://forums.swift.org/t/approaches-for-fixed-size-arrays/58894/90) in response to the fact that the 2nd might imply "complete the pattern"  a [vinculum](https://en.wikipedia.org/wiki/Vinculum_%28symbol%29) might be an alternative.


This package has chosen the route that if an action will need a default value it will ask for it in the parameters of the method at this time. An exception is made for types that have .zero or .none implemented, which will be able to take advantage of certain shortcuts that other Element types cannot. 

## References

- Motivating Forum Post: https://forums.swift.org/t/approaches-for-fixed-size-arrays/
- Previous Pitch: https://forums.swift.org/t/pitch-improved-compiler-support-for-large-homogenous-tuples/49023
- But they certainly weren't the first: https://forums.swift.org/t/checking-in-more-thoughts-on-arrays-and-variadic-generics/4948/3 (no fixed sized types called Array comes from here.)

### Related Pitches and Proposals

Many of these are _subsequent_ to the the summarized post. 

- https://github.com/apple/swift-evolution/blob/main/proposals/0322-temporary-buffers.md
- https://github.com/apple/swift-evolution/blob/main/proposals/0324-c-lang-pointer-arg-conversion.md
- https://forums.swift.org/t/pitch-non-escapable-types-and-lifetime-dependency/69865
- https://github.com/apple/swift-evolution/blob/main/proposals/0390-noncopyable-structs-and-enums.md
- https://forums.swift.org/t/roadmap-language-support-for-bufferview/66211
- https://forums.swift.org/t/pitch-safe-access-to-contiguous-storage/69888
- https://forums.swift.org/t/pitch-synchronous-mutual-exclusion-lock/69889
- https://forums.swift.org/t/a-roadmap-for-improving-swift-performance-predictability-arc-improvements-and-ownership-control/54206

#### Before
- 2021: https://forums.swift.org/t/pitch-improved-compiler-support-for-large-homogenous-tuples/49023/
- 2016: https://lists.swift.org/pipermail/swift-evolution/Week-of-Mon-20160208/009682.html

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
