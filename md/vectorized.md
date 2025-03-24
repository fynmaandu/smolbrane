---
title: Vectorized Rust
subtitle: A introduction to SIMD
author: jtriley2p
lang: en
toc-title: Contents
license: AGPL-3.0
---

SIMD, or single-instruction, multiple-data, is a parallel processing strategy taking advantage of vector processors and vector extensions in many modern CPU architectures.

## Introduction

In the 1970’s, supercomputers were so powerful that the heat produced by accelerating computation began melting processors. From this era, two strategies to distribute the workload emerged; multi-core processing and vector processing.

The multi-core strategy places multiple CPU cores on the same chip, distributing workloads between them. This strategy remains popular to this day and is also referred to as multi-threading, where each software process can spawn an arbitrary number of threads to distribute its work load from a unified memory with a kernel managing how computation is distributed. Such distribution can be performed either in parallel across CPU cores or concurrently within a single CPU core, interleaving the threads’ actions for each CPU clock cycle.

The SIMD strategy allows the CPU to process vectors in parallel, instead of on individual elements in series. This parallel processing is enabled by CPU instructions that process groups of bits, or “lanes”, side-by-side without moving the workload to another processor. This strategy entails designing algorithms that can take advantage of these instructions, also known as “vectorization”. While auto-vectorization, the transformation of our algorithms into vectorized algorithms automatically by a compiler, has improved significantly over the years, it is still an open area of research and development and there remains plenty of opportunity for hand-optimized vector instructions. While this strategy has been widely used for accelerating signals and image processing, modern applications such as machine learning and more powerful cryptographic primitives demand increasingly parallelized solutions.

## Modern Processors

CPU architectures have various extensions to accommodate SIMD. Intel’s x86 extensions include MMX introduced in 1997, the Streaming SIMD Extensions (SSE, SSE2, SSE3, SSSE3, and SSE4) with the first being introduced in 1999 and the most recent being introduced in 2006, and finally the Advanced Vector Extensions including AVX, AVX2, the fragmented AVX512, and the newly announced as of 2023 AVX10 extension. Arm Holdings’ ARM extensions include a variety of floating point vector extensions and most recently the NEON extension. Also the open-source RISC-V architecture’s “V” extension adds vector instructions and was frozen for public review in 2021.

Each extension features a variety of lane counts and sizes, some offering only floating point vectors while others include signed and unsigned integers. Historically, these subtle differences made vectorization especially difficult.

## Rust’s Portable SIMD

In Rust, the core and standard libraries contain portable, multi-architecture SIMD modules, defining data types, traits, functionality, and macros that largely abstract the intricacies of vectorization such as alignment or architecture-dependent algorithms.

However, as the library may change in time and given the complexity of designing robust vector abstractions, the feature is only available under the nightly release of Rust and the following crate attribute must be added at the crate’s root, either in the ‘main’ or ‘lib’ file.

```rust
// src/main.rs
#![feature(portable_simd)]
```

## Construction
SIMD vectors can be constructed in a variety of ways for flexibility. Note that we can use either the core ‘Simd’ type or other aliases assigned to it

```rust
use std::simd::Simd;
use std::simd::u32x4;

fn main() {
    let a: Simd<u32, 4> = Simd::from_array([1, 2, 3, 4]);
    let b: u32x4 = u32x4::from_array([5, 6, 7, 8]);
    let c: u32x4 = u32x4::splat(9);
}
```

> Note how that ‘u32x4’ is a type alias to ‘Simd<u32, 4>’, as such they are treated by the compiler as the same type.

The ‘from_array’ function constructs a vector buffer from the elements of an array or slice, while ‘splat’ copies a single element across the entire vector.

The ‘from_array’ operation copies the slice of data directly into the SIMD buffer, as the Rust slice and the SIMD buffer align. There are other ways, generally through Rust’s ‘unsafe’ blocks, to directly load data into SIMD buffers, but doing so incorrectly creates undefined behavior.

## Operators

The commonly used operators and associated trait implementations in Rust are supported by the SIMD data types. This includes the arithmetic operations addition, subtraction, multiplication, division, modulus, and negation, as well as the bitwise operations AND, OR, XOR, and NOT.

```rust
use std::simd::u32x4;

fn main() {
    let a = u32x4::from_array([1, 2, 3, 4]);
    let b = u32x4::splat(1);

    let c = a + b;

    assert_eq!(c, u32x4::from_array([2, 3, 4, 5]));
}
```

Since these are vector operations, all lanes of the vector are processed in parallel, within a single CPU clock cycle.

<pre>

┌───┬───┬───┬───┐    ┌───┬───┬───┬───┐
│ 1 │ 2 │ 3 │ 4 │ a  │ 1 │ 2 │ 3 │ 4 │ b
└─╥─┴─╥─┴─╥─┴─╥─┘    └─╥─┴─╥─┴─╥─┴─╥─┘
  ║   ║   ║   ║        ║   ║   ║   ║
  ╠═══║═══║═══║════════╝   ║   ║   ║
  ║   ╠═══║═══║════════════╝   ║   ║
  ║   ║   ╠═══║════════════════╝   ║
  ║   ║   ║   ╠════════════════════╝
  ║   ║   ║   ║
┌─╨─┬─╨─┬─╨─┬─╨─┐
│ 1 │ 2 │ 3 │ 4 │ c
└───┴───┴───┴───┘

</pre>

> Note: Arithmetic overflow and underflow will not cause an error in SIMD operations. In rust, the default behavior of vector arithmetic is wrapping arithmetic, that is, the bits that move out of bounds will wrap around the other side. However, division by zero will still panic.

## Swizzling

Dimensions and element orderings in vectors are performed by “swizzle” operations. Most transformations built into Rust’s SIMD type such as ‘reverse’, ‘rotate_elements_right’, or ‘splat’ use swizzle internally.

The swizzle operation takes both an input vector and an index vector. Each index vector element loads its corresponding input vector element and writes it to the output vector. If the input and index vectors are different lengths, the output vector will always be the length of the index vector.

```rust
use std::simd::u32x4;
use std::simd::Swizzle;

fn main() {
    let a: u32x4 = u32x4::from_array([1, 2, 3, 4]);

    struct RotateRight;
    impl Swizzle<4> for RotateRight {
        const INDEX: [usize; 4] = [3, 0, 1, 2];

        // 'swizzle' fn is implemented with `INDEX`
        // implicitly
    }

    let rotr_a = RotateRight::swizzle(a);

    assert_eq!(
        a.rotate_elements_right::<1>(),
        rotr_a
    );
}
```

Note that ‘Swizzle’ is a trait, so to implement our element-wise right-rotation, we define a ‘RotateRight’ placeholder type and implement the ‘Swizzle’ trait with a length of 4. The only required item to implement in ‘Swizzle’ is ‘INDEX’, representing the indices to switch. The ‘swizzle’ function is defined automatically based on the associated index vector constant.

However this is clunky, so we can also use a simpler swizzle macro that handles this internally.

```rust
use std::simd::u32x4;
use std::simd::simd_swizzle;

fn main() {
    let a: u32x4 = u32x4::from_array([1, 2, 3, 4]);

    const INDEX: [usize; 4] = [3, 0, 1, 2];

    let rotr_a = simd_swizzle!(a, INDEX);

    assert_eq!(
        a.rotate_elements_right::<1>(),
        rotr_a
    );
}
```

The given our index vector, the operation rotates each element to the right by 1 lane, then the right-most element is wrapped around to the left-most lane.

<pre>

┌───┬───┬───┬───┐
│ 1 │ 2 │ 3 │ 4 │ a
└─╥─┴─╥─┴─╥─┴─╥─┘
  ╚═╗ ╚═╗ ╚═╗ ║
  ╔═║═══║═══║═╝
  ║ ╚═╗ ╚═╗ ╚═╗
┌─╨─┬─╨─┬─╨─┬─╨─┐
│ 3 │ 0 │ 1 │ 2 │ index
└─╥─┴─╥─┴─╥─┴─╥─┘
  ║   ║   ║   ║
┌─╨─┬─╨─┬─╨─┬─╨─┐
│ 4 │ 1 │ 2 │ 3 │ rotr_a
└───┴───┴───┴───┘

</pre>

Compare this to the iterative form of the same operation.

```rust
fn main() {
    let a = [1u32, 2, 3, 4];
    let mut b = [0; 4];

    for i in 0..a.len() {
        b[i] = a[(i + 3) % 4];
    }
}
```

### Splat Revisited

The splat operation referenced in the construction section can be defined as a swizzle as follows.

```rust
use std::simd::u32x1;
use std::simd::u32x4;
use std::simd::simd_swizzle;

fn main() {
    let a: u32x1 = u32x1::from_array([1]);

    let splatted = simd_swizzle!(a, [0, 0, 0, 0]);

    assert_eq!(u32x4::splat(1), splatted);
}
```

This treats the single element, ‘1’, as a vector containing a single element at index zero, then the index vector transfers the zero’th element to each index of the output vector.

<pre>

┌───┐
│ 1 │ scalar
└─╥─┘
  ╠═══════════╗
  ╠═══════╗   ║
  ╠═══╗   ║   ║
  ║   ║   ║   ║
┌─╨─┬─╨─┬─╨─┬─╨─┐
│ 0 │ 0 │ 0 │ 0 │ indices
└─╥─┴─╥─┴─╥─┴─╥─┘
  ║   ║   ║   ║
┌─╨─┬─╨─┬─╨─┬─╨─┐
│ 1 │ 2 │ 3 │ 4 │ splatted
└───┴───┴───┴───┘

</pre>

## Reductions

Vectors can also be reduced to their underlying element. That is, the elements can be added or multiplied together, or the largest or smallest value can be found in each.

```rust
use std::simd::u32x4;
use std::simd::num::SimdUint;

fn main() {
    let a = u32x4::from_array([1, 2, 3, 4]);

    let prod_a = a.reduce_product();

    let sum_a = a.reduce_sum();

    let max_in_a = a.reduce_max();

    let min_in_a = a.reduce_min();
}
```

Note that the ‘SimdUint’ trait is brought into scope, as it is where the reduction functions are defined.

## Vectorized Algorithms

Many algorithms benefit significantly from vectorization including searching, sorting, cryptography, signals processing, and machine learning. The following are a few simplified forms of some algorithms that benefit from vectorization.

### Check That Vector Contains X

Vectorized search algorithms enable constant-time searches on sufficiently small vectors, improving divide-and-conquer strategies.

```rust
use std::simd::u32x4;
use std::simd::cmp::SimdPartialEq;

fn main() {
    let a = u32x4::from_array([1, 2, 3, 4]);

    let search_vector = u32x4::splat(2);

    let search_result = a.simd_eq(search_vector);

    assert!(search_result.any());
}
```

An iterative form of this algorithm requires sequentially checking for the existence of ‘2’, the vectorized form is always constant time, allowing the entire vector to be searched by checking element-wise equality, then reducing the result into a single value where the ‘any’ function returns true if even a single element is nonzero.

<pre>
┌───┬───┬───┬───┐
│ 1 │ 2 │ 3 │ 4 │ a
└─╥─┴─╥─┴─╥─┴─╥─┘
  ║   ║   ║   ║
┌─╨─┬─╨─┬─╨─┬─╨─┐
│ 2 │ 2 │ 2 │ 2 │ search_vector
└─╥─┴─╥─┴─╥─┴─╥─┘
  ║   ║   ║   ║
┌─╨─┬─╨─┬─╨─┬─╨─┐
│ 0 │ 1 │ 0 │ 0 │ search_result
└─╥─┴─╥─┴─╥─┴─╥─┘
  ╠═══╝   ║   ║
  ╠═══════╝   ║
  ╠═══════════╝
  ║
┌─╨────┐
│ true │ any
└──────┘

</pre>

### Sum All Elements

Summing all elements between all vectors can be performed by adding vectors then reducing the final vector to one sum.

```rust
use std::simd::u32x4;

fn main() {
    let a = u32x4::from_array([1, 2, 3, 4]);
    let b = u32x4::from_array([1, 2, 3, 4]);

    let sum = (a + b).reduce_sum();
}
```

<pre>

┌───┬───┬───┬───┐    ┌───┬───┬───┬───┐
│ 1 │ 2 │ 3 │ 4 │ a  │ 1 │ 2 │ 3 │ 4 │ b
└─╥─┴─╥─┴─╥─┴─╥─┘    └─╥─┴─╥─┴─╥─┴─╥─┘
  ║   ║   ║   ║        ║   ║   ║   ║
  ╠═══║═══║═══║════════╝   ║   ║   ║
  ║   ╠═══║═══║════════════╝   ║   ║
  ║   ║   ╠═══║════════════════╝   ║
  ║   ║   ║   ╠════════════════════╝
  ║   ║   ║   ║
┌─╨─┬─╨─┬─╨─┬─╨─┐
│ 2 │ 4 │ 6 │ 8 │ search_result
└─╥─┴─╥─┴─╥─┴─╥─┘
  ╠═══╝   ║   ║
  ╠═══════╝   ║
  ╠═══════════╝
  ║
┌─╨──┐
│ 20 │ sum
└────┘

</pre>

### ChaCha20 Quarter Round

The ChaCha20 stream cipher was designed with vectorization in mind, thus its “quarter round” algorithm, a sub-component of the key stream generation, can be elegantly vectorized.

```rust
use std::simd::u32x4;

fn quarter_round(
    a: u32x4,
    b: u32x4,
    c: u32x4,
    d: u32x4,
) -> [u32x4; 4] {
    a += b;
    d ^= a;
    d = rotl(d, 16);

    c += d;
    b ^= c;
    b = rotl(b, 12);

    a += b;
    d ^= a;
    d = rotl(d, 8);

    c += d;
    b ^= c;
    b = rotl(b, 7);

    [a, b, c, d]
}

fn rotl(v: u32x4, n: usize) -> u32x4 {
    (v >> (32 - n)) | (v << n)
}
```

In an iterative implementation of the ChaCha20 cipher, the quarter round operates on each column of a 4x4 state matrix individually, while the vectorized implementation can perform the quarter round on all four columns simultaneously by treating each vector as a row in the matrix.

<pre>

       ╔═══╗   ╔═══╗   ╔═══╗      iterative
┌─────┐║┌──╨──┐║┌──╨──┐║┌──╨──┐
│  00 │║│  01 │║│  02 │║│  03 │
└──╥──┘║└──╥──┘║└──╥──┘║└──╥──┘
   ║   ║   ║   ║   ║   ║   ║   
┌──╨──┐║┌──╨──┐║┌──╨──┐║┌──╨──┐
│  04 │║│  05 │║│  06 │║│  07 │
└──╥──┘║└──╥──┘║└──╥──┘║└──╥──┘
   ║   ║   ║   ║   ║   ║   ║   
┌──╨──┐║┌──╨──┐║┌──╨──┐║┌──╨──┐
│  08 │║│  09 │║│  10 │║│  11 │
└──╥──┘║└──╥──┘║└──╥──┘║└──╥──┘
   ║   ║   ║   ║   ║   ║   ║   
┌──╨──┐║┌──╨──┐║┌──╨──┐║┌──╨──┐
│  12 │║│  13 │║│  14 │║│  15 │
└──╥──┘║└──╥──┘║└──╥──┘║└─────┘
   ╚═══╝   ╚═══╝   ╚═══╝

┌─────┬─────┬─────┬─────┐               vectorized
│  00 │  01 │  02 │  03 │ a
└──╥──┴──╥──┴──╥──┴──╥──┘
   ║     ║     ║     ║
┌──╨──┬──╨──┬──╨──┬──╨──┐
│  04 │  05 │  06 │  07 │ b
└──╥──┴──╥──┴──╥──┴──╥──┘
   ║     ║     ║     ║
┌──╨──┬──╨──┬──╨──┬──╨──┐
│  08 │  09 │  10 │  11 │ b
└──╥──┴──╥──┴──╥──┴──╥──┘
   ║     ║     ║     ║
┌──╨──┬──╨──┬──╨──┬──╨──┐
│  12 │  13 │  14 │  15 │ b
└─────┴─────┴─────┴─────┘

</pre>

As a result of this strong vectorization, optimized implementations of ChaCha20 perform multiple times faster than AES-256-GCM without AES-specific hardware accelerators.

## Conclusion

Vectorization is a powerful tool to enable parallel processing without external hardware or the complexities of multi-threading, with roots in many decades of scientific computing. There is much nuance to manual vectorization, as compiler-defined auto-vectorization has been a rapidly improving field of study. As such, vectorization demands thorough benchmarking and profiling of implementations to ensure optimal performance. While most modern processors support vector instructions, not all have the same sizes and implementation details. Rust’s SIMD module in the standard and core libraries largely abstract the finer processor implementation details, but still deserve care in ensuring optimal performance without compromising on safety.

I hope you found this article interesting. Parallel processing is a unique joy in software optimization, so expect more resources akin to this in the future.

Until next time.


