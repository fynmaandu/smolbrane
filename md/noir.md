---
title: Noir's Circuit backend
subtitle: A practical introduction
author: jtriley2p
lang: en
toc-title: Contents
license: AGPL-3.0
---

## Introduction

The Noir programming language allows a familiar, Rust-like interface for writing custom zk-SNARK programs.

The flexibility of zk-SNARK's enables quasi-turing complete programs to be proven once and verified
with sub-linear time complexity and no interactions between the prover and verifier. Developing
these programs, also known as circuits, are often challenging, as the program must be reducible to a
series of arithmetic constraints. From this problem, two different strategies have emerged, one uses
a zk-SNARK domain specific language (DSL) and relies on a compiler to transform the program to
constraints which can be proven and verified, while the other uses a zk-SNARK virtual machine (zkVM)
circuit that can process instructions then prove and verify its execution trace.

Historically, DSL’s for zk-SNARK’s have been difficult due to their unconventional syntax and programming paradigm, though the circuits generated could be proven much faster than zkVM's. The zkVM model has most successfully relied on machine architectures such as RISC-V due to its reduced instruction set, open specification, and support as a target for LLVM (and languages that use LLVM). While it has historically been much slower to prove zkVM's, proving performance has improved substantially up to the time of writing.

Noir is a recent addition to the former strategy, it compiles source code into an intermediate representation that can be transformed into the appropriate zk-SNARK backend as necessary. At the time of writing, Noir targets UltraHonk for circuits and MegaHonk for private smart contracts on the Aztec network.

## The Noir Compiler

Noir does not directly prove circuits, nor does it fully synthesize the constraint system on its own. Rather, Noir can be used for two purposes, either generating an arithmetic circuit or smart contract bytecode for the Aztec Virtual Machine (AVM). For the scope of this article, we will focus on the former, which is used for zk-SNARK’s that can be proven offchain and verified either offchain or onchain by an auto-generated Solidity verifier deployable to the Ethereum Virtual Machine (EVM).

### Arithmetic Circuits

The output of the Noir compilier is not the circuit itself, rather it is bytecode. This bytecode is interpreted by the Arithmetic Circuit Virtual Machine (ACVM), which generates the circuit in its final constraint system. This is significant as a compilation target, as this allows the Noir output to target arbitrary constraint systems. The bytecode interpreted by the ACVM can be divided into two categories, Arithmetic Circuit Intermediate Representation (ACIR) bytecode and Brillig bytecode. The ACIR opcodes correspond to constraints in the final circuit while the Brillig opcodes correspond to unconstrained computation. ACIR opcodes can call into Brillig functions, but not vice versa.

Some computations are expensive to perform in constrained SNARK's, though checking correctness may be much less expensive. Thus we can define SNARK-unfriendly computations in Brillig functions, call those functions from ACIR, and constrain the Brillig function outputs for correctness afterward.

For example, division in a circuit is performed over field elements, requiring an expensive algorithm (typically the Extended Euclidean Algorithm) to find multiplicative inverses. Instead of finding inverses inside the circuit, we can delegate the search to a Brillig function. The Brillig function should return the multiplicative inverse, but note that being an unconstrained environment means a malicious prover could return incorrect values. As such, we constrain the output of the function as follows.

```noir
fn div(x: Field, y: Field) -> Field {
    let inv_y = unsafe { inverse(y) };

    assert_eq(1, y * inv_y);

    x * inv_y
}

unconstrained inverse(x: Field) -> Field {
    // extended euclidean algorithm

    // -- snip
}
```

Using the multiplicative inverse law of `n * inverse(n) == 1` for every number `n` in a field, we can constrain the output of the Brillig `inverse` function is correct with a multiplication equality check, which is quite cheap for arithmetic circuits.

## A Brief History of PLONK

Permutations over Lagrange-bases for Oecumenical Noninteractive arguments of Knowledge, also known as PLONK, was the first of the PLONKish zk-SNARK's. PLONK was an iteration on Groth16, both in commitment scheme and constraint system. In particular, the constraint system was expanded to enshrine more complex algebraic logic.

TurboPLONK extended PLONK by adding arbitrary custom gates, that is to say the constraint system could be extended from PLONK to accommodate custom logic; in particular, TurboPLONK added constraints for elliptic curve point arithmetic. However, TurboPLONK has been since been superseded by UltraPLONK.

UltraPLONK extended TurboPLONK by adding lookup tables, formally known as Plookup. This allows lookup tables to replace more expensive SNARK-unfriendly constraints in an efficiently provable & verifiable way. Over time, UltraPLONK has developed to encapsulate custom gates and lookup tables.

HONK by Aztec and similarly HyperPLONK by EspressoSystems, significantly improve the efficiency of PLONKish proof generation by changing the way the constraint systems are interpolated into polynomials. For application developers this is not directly practical, though its name will be referenced quite often in the wild, so an explanation was fitting.

Noir targets UltraHONK for its circuit backend, that is to say it targets a PLONKish constraint system with custom gates, lookup tables, and it uses a multivariate polynomial commitment scheme that is provable on linear time complexity.

## Constraint Systems

The core of constraint systems is to construct input vector(s), also known as the witness, and circuit matrices which transform the witness such that we can check correctness. Commitment schemes typically involve transforming these matrices into vectors of polynomials such that all of the same rules of arithmetic still hold, and the polynomials can be checked at a single evaluation point rather than every element of a matrix. Polynomial interpolation is beyond the scope of this document, but we will start with the Groth16 constraint system as a foundation for the PLONK constraint system.

## Rank 1 Constraint System

A Rank 1 Constraint System, also known as R1CS, is the constraint system of Groth16, a notable predecessor to PLONK. R1CS requires a circuit to be a series of `n` equality constraints `a * b = c`.

<pre>

a<sub>0</sub> · b<sub>0</sub> = c<sub>0</sub>
a<sub>1</sub> · b<sub>1</sub> = c<sub>1</sub>
    ...
a<sub>n</sub> · b<sub>n</sub> = c<sub>n</sub>

</pre>
 
Given this $a_1$ series of constraints, we derive a collection of inputs ‘i’, outputs ‘o’, intermediate values ‘m’, and a constant value 1, known as the witness vector ‘w’.

> Note: The constant term 1 can be used when multiplying by constants in the circuit, it is not always necessary and it is not always 1, but is included nonetheless.

<pre>

→
w = [ 1 i<sub>0</sub> ... o<sub>0</sub> ... m<sub>0</sub> ... ]

</pre>

Additionally, we transform the series of constraints into ‘A’, ‘B’, and ‘C’ matrices with of ‘m*n’ dimensions corresponding to the number of constraints and the witness vector length, respectively.

<pre>

→
w = [ 1 i<sub>0</sub> ... o<sub>0</sub> ... m<sub>0</sub> ... ]

     ┌                 ┐
     │ a<sub>01</sub>  a<sub>02</sub>  ...  a<sub>0n</sub> │
A =  │ a<sub>11</sub>  a<sub>12</sub>  ...  a<sub>1n</sub> │
     │ ... ... ... ... │
     │ a<sub>m1</sub>  a<sub>m2</sub>  ...  a<sub>mn</sub> │
     └                 ┘

     ┌                 ┐
     │ b<sub>01</sub>  b<sub>02</sub>  ...  b<sub>0n</sub> │
B =  │ b<sub>11</sub>  b<sub>12</sub>  ...  b<sub>1n</sub> │
     │ ... ... ... ... │
     │ b<sub>m1</sub>  b<sub>m2</sub>  ...  b<sub>mn</sub> │
     └                 ┘

     ┌                 ┐
     │ c<sub>01</sub>  c<sub>02</sub>  ...  c<sub>0n</sub> │
C =  │ c<sub>11</sub>  c<sub>12</sub>  ...  c<sub>1n</sub> │
     │ ... ... ... ... │
     │ c<sub>m1</sub>  c<sub>m2</sub>  ...  c<sub>mn</sub> │
     └                 ┘

</pre>

Finally, a linear transformation of the witness vector by each matrix allows for the constraint system to be fully representable with vector equality checks.

<pre>

 →    →    →
Aw ◦ Bw = Cw

</pre>

While the Groth16 SNARK requires additional transformations from a R1CS to become a fully fledged SNARK, namely transforming the vectors to polynomials for the polynomial commitment scheme, this is beyond the scope of this document, as the focus is on the practical targets to be aware of as developers.

## Example

For a concrete example, we transform the following program into an R1CS.

<pre>

z = x<sup>2</sup> * y

</pre>

```noir
fn main(
    x: pub Field,
    y: pub Field
) -> pub Field {
    let z = Field::pow_32(x, 2) * y;

    z
}
```

> Note: the `**` operator is not valid Noir syntax, so we use the `pow_32` built-in function in the `Field` namespace.

First we break the expression down into simple multiplication equality checks.

```noir
fn mul_only_main(
    x: pub Field,
    y: pub Field
) -> pub Field {
    let x_sq = x * x;

    let z = x_sq * y;

    z
}
```

Next we derive our witness vector, which must contain all inputs, outputs, intermediate values, and 1.

<pre>

→
w = [ 1 x y x<sub>sq</sub> z ]

</pre>
 
Then we derive our ‘A’, ‘B’, and ‘C’ matrices. Treating the above function `mul_only_main` as a series of ‘a*b=c’ constraints, we have the following.

<pre>

x  · x = x<sub>sq</sub>
x<sub>sq</sub> · y = z

</pre>

| a   | b   | c   |
| :---: | :---: | :---: |
| x   | x   | x<sub>sq</sub> |
| x<sub>sq</sub>   | y   | z |
 
We define ‘A’ as follows such that the result of matrix vector multiplication of ‘A’ and ‘w’ corresponds to the ‘a’ column:

<pre>

      ┌           ┐
 →    │ 0 1 0 0 0 │
Aw =  │ 0 0 0 1 0 │ · [1 x y x<sub>sq</sub> z]
      └           ┘
     ┌    ┐
 →   │ x  │
Aw = │ x<sub>sq</sub> │
     └    ┘

</pre>

Respectively we define ‘B’ and ‘C’:

<pre>

      ┌           ┐
 →    │ 0 1 0 0 0 │
Bw =  │ 0 0 1 0 0 │ · [1 x y x<sub>sq</sub> z]
      └           ┘

     ┌   ┐
 →   │ x │
Bw = │ y │
     └   ┘

      ┌           ┐
 →    │ 0 0 0 1 0 │
Cw =  │ 0 0 0 0 1 │ · [1 x y x<sub>sq</sub> z]
      └           ┘

     ┌    ┐
 →   │ x<sub>sq</sub> │
Cw = │ z  │
     └    ┘

</pre>
 
Finally, we may constrain that:

<pre>

 →    →    →
Aw ◦ Bw = Cw

</pre>

A useful way to reason about the ‘A’, ‘B’, and ‘C’ matrices is to consider them selectors that define which witness vector elements are constrained on a given row.

## PLONKish Constraint System

The PLONKish constraint system also requires a circuit to be a series of constraints, though there are more elements in each constraint.

> Note: We call it PLONKish due to the variants of PLONK using the same base constraint system but with various extensions.

<pre>

q<sub>L</sub>·a + q<sub>R</sub>·b + q<sub>O</sub>·c + q<sub>M</sub>·ab + q<sub>C</sub> = 0

</pre>

We consider the ‘q’ values selector vectors and ‘a’, ‘b’, and ‘c’ values as assignment vectors. By using different combinations of selectors, we can constrain several different properties without modifying the constraint system.

Multiplication (a * b = c):

<pre>

q<sub>L</sub> =  0
q<sub>R</sub> =  0
q<sub>O</sub> = -1
q<sub>M</sub> =  1
q<sub>C</sub> =  0

0 = (0·a) + (0·b) + (-1·c) + (1·a·b) + 0
  ↓
0 = -c + a·b
  ↓
c = a·b

</pre>

Addition (a + b = c):

<pre>

q<sub>L</sub> =  1
q<sub>R</sub> =  1
q<sub>O</sub> = -1
q<sub>M</sub> =  1
q<sub>C</sub> =  0

0 = (1·a) + (1·b) + (-1·c) + (0·a·b) + 0
  ↓
0 = a + b - c
  ↓
c = a + b

</pre>

Booleanity (a = 0 || a = 1):

<pre>

q<sub>L</sub> = -1
q<sub>R</sub> =  0
q<sub>O</sub> =  0
q<sub>M</sub> =  1
q<sub>C</sub> =  0

0 = (-1·a) + (0·b) + (-1·c) + (1·a·a) + 0
  ↓
0 = -a + a<sup>2</sup>
  ↓
a = a<sup>2</sup> ⟹ a=0 ∨ a=1

</pre>

Constant (a = 5):

<pre>

q<sub>L</sub> = -1
q<sub>R</sub> =  0
q<sub>O</sub> =  0
q<sub>M</sub> =  0
q<sub>C</sub> =  5

0 = (-1·a) + (0·b) + (0·c) + (0·a·b) + 5
  ↓
0 = -a + 5
  ↓
5 = a

</pre>

Once again, we define assignment vectors ‘a’, ‘b’, and ‘c’ and selector vectors ‘qL’, ‘qR’, ‘qO’, 'qM’, and ‘qC’ such that the following holds.

<pre>

   →      →      →      →         →
q<sub>L</sub>·a + q<sub>R</sub>·b + q<sub>O</sub>·c + q<sub>M</sub>·ab + q<sub>C</sub> = 0

</pre>

### Example

For a concrete example, we transform the following program into a PLONK constraint system.

<pre>

z = x<sup>2</sup> * y + 5

</pre>

First we break the expression down into lines that can be proven by a row in PLONK.

```noir
fn main(
    x: pub Field,
    y: pub Field
) -> pub Field {
    let z = Field::pow_32(x, 2) * y + 5;

    z
}

fn plonk_main(
    x: pub Field,
    y: pub Field
) -> pub Field {
    let x_sq = x * x;

    let z = x_sq * y + 5;

    z
}
```

> Note: the `**` operator is not valid Noir syntax, so we use the `pow_32` built-in function in the `Field` namespace.

Treating the above function `plonk_main` as a series of PLONK constraints, we transform each expression into a PLONKish constraint.

```noir
let x_sq = x * x;
```

<pre>

q<sub>L</sub> =  0
q<sub>R</sub> =  0
q<sub>O</sub> = -1
q<sub>M</sub> =  1
q<sub>C</sub> =  0

a = x
b = x
c = x<sub>sq</sub>

0  = (0·x) + (0·x) + (-1·x<sub>sq</sub> ) + (1·x·x) + 0
   ↓
0  = -x<sub>sq</sub> + x·x
   ↓
x<sub>sq</sub> = x·x

</pre>

```noir
let z = x_sq * y + 5;
```

<pre>

q<sub>L</sub> =  0
q<sub>R</sub> =  0
q<sub>O</sub> =  1
q<sub>M</sub> = -1
q<sub>C</sub> = -5

a = y
b = x<sub>sq</sub>
c = z

0 = (0·y) + (0· x<sub>sq</sub> ) + (1·z) + (-1·y· x<sub>sq</sub> ) + (-5)
  ↓
0 = z - y·x<sub>sq</sub> - 5
  ↓
0 = -z + y·x<sub>sq</sub> + 5
  ↓
z = y·x<sub>sq</sub> + 5

</pre>

Then combining them together into vectors:

<pre>

   →      →      →      →         →
q<sub>L</sub>·a + q<sub>R</sub>·b + q<sub>O</sub>·c + q<sub>M</sub>·ab + q<sub>C</sub> = 0


q<sub>L</sub> = [ 0  0 ]
q<sub>R</sub> = [ 0  0 ]
q<sub>O</sub> = [-1  1 ]
q<sub>M</sub> = [ 1 -1 ]
q<sub>C</sub> = [ 0 -5 ]

    ┌    ┐
→   │ x  │
a = │ x<sub>sq</sub> │
    └    ┘

    ┌   ┐
→   │ x │
b = │ y │
    └   ┘

    ┌    ┐
→   │ x<sub>sq</sub> │
c = │ z  │
    └    ┘

0 = [0 0][x x<sub>sq</sub>] + [0 0][x y] + [-1 1][x<sub>sq</sub> z] + [1 -1][x x<sub>sq</sub>][x y] + [0 -5]
  ↓
0 = [-x<sub>sq</sub> z] + [x·x -y·x<sub>sq</sub>] + [0 -5]
  ↓
0 = [x·x·-x<sub>sq</sub> y·x-z+5]
  ↓
0 = [0 0]

</pre>

However, the right side only reduces to the zero vector if and only if all constraints are satisfied.

## Noir Output

Given the PLONK constraint example, we'll examine the stages of compilation of the following Noir program to ensure it matches what we demonstrated in the example section.

```noir
fn main(
    x: pub Field,
    y: pub Field
) -> pub Field {
    let z = Field::pow_32(x, 2) * y + 5;

    z
}
```

We’ll compile the code with the option to print the ACIR.

```bash
nargo compile --print-acir
```

This prints the following.

```txt
Compiled ACIR for main (unoptimized):
func 0
current witness index : 3
private parameters indices : []
public parameters indices : [0, 1]
return value indices : [2]
EXPR [ (1, _0, _0) (-1, _3) 0 ]
EXPR [ (-1, _1, _3) (1, _2) -5 ]
The main function has ID `0`.
```

The current witness index of `3` indicates there are four values in the witness (this will be transformed into the ‘a’, ‘b’, and ‘c’ assignment vectors when interpreted by the ACVM).

There are no private parameters, though there are two public parameters whose witness indices are `0` and `1` repsectively; these correspond to our inputs `x` and `y`.

There is one return value index, `2`, which corresponds to `z`.

Although we don't have explicit confirmation of the existence of `x_sq` in the metadata, can infer that the witness vector is:

<pre>

→
w = [ x y z x<sub>sq</sub> ]

</pre>

Then we have two `EXPR` expressions. Examining the ACIR opcodes in the ACIR repository, we find only one instance of `Expression` in `Opcode::AssertZero(Expression)`, which appears to be defined in its own module in the repository.

```rust
pub struct Expression<F> {
    pub mul_terms: Vec<(F, Witness, Witness)>,
    pub linear_combinations: Vec<(F, Witness)>,
    pub q_c: F,
}
```

The `mul_terms` field contains a series of triples, each containing a selector and two witness values (‘a’ and ‘b’), while the `linear_combinations` field contains a series of tuples, each containing a selector and a witness value (‘c’), and finally the `q_c` field contains the constant value (‘qC’).

Using this information, we can reconstruct the expressions as follows.

```noir
let witness = [x, y, z, x_sq];

// 0*x + 0*x + 1*x*x - x_sq + 0 = 0
//
let expr_0 = Expression {
    mul_terms: vec![(1, witness[0], witness[0]),],
    linear_combinations: vec![(-1, witness[3])],
    q_c: 0
};

// 0*x + 0*x - 1*y*x_sq + 1*z + 5 = 0
//
let expr_1 = Expression {
    mul_terms: vec![(-1, witness[1], witness[3])],
    linear_combinations: vec![(1, witness[2])],
    q_c: -5
};
```

Which corresponds to our PLONK constraints!

## Conclusion

For the sake of brevity, the custom gates and lookup tables will remain handwavy for now. However, the foundations of a PLONKish constraint system as a Noir circuit backend should help build intuition in both how the compiler behaves as well as how to optimize circuits by delegating expensive computational tasks to the Brillig unconstrained environment.

Expect more content similar to this in the future, as there is plenty more to cover.

Until next time.
