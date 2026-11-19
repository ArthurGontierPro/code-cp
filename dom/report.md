# One model of a binary code, three solvers: where a pseudo-Boolean learner beats lazy clause generation

*codes-cp, 2026-11-19. Measurements from 2026-11-18 on one shared compute node. Everything needed to
rerun them is listed at the end.*

## Summary

We ask a constraint solver to show that the extended quadratic residue code QR48, a binary
[48, 24, 12] code, has no nonzero word of weight at most 8. We write the code in two equivalent ways:

- the **systematic model**, the usual one, with 24 free bits and XOR chains for the other 24;
- a **symmetric model**, with one parity equation for each of the 17,296 minimum-weight words of the
  code.

On the systematic model, Chuffed (lazy clause generation) proves the result in 7.6 s. Our solver
baguette, which learns pseudo-Boolean (PB) constraints, does not finish in an hour.

On the symmetric model the roles swap. Chuffed and GCS do not finish in an hour. Baguette finishes in
33 minutes, after visiting 26 times fewer nodes than Chuffed, and its proof is checked by VeriPB. With
its PB conflict analysis switched off, it does not finish either.

The constraints that baguette learns explain the difference. Most of them add or subtract two
parity equations, and the variables the two words share cancel out. This is one step of Gaussian
elimination over GF(2). It can be written with cutting planes, but not with clauses. The symmetric
model gives the solver integer sums to combine. The systematic model, flattened to clauses, gives it
nothing to combine.

## 1. The question

A binary linear code C of length n is a subspace of GF(2)^n. Its minimum distance d is the smallest
number of ones in a nonzero codeword. Extended quadratic residue codes of length p + 1, for a prime
p ≡ −1 mod 8, are self-dual, so C⊥ = C, and doubly even, so every weight is a multiple of 4. QR48
(p = 47) has d = 12, and it is the unique [48, 24, 12] self-dual doubly even code.

To prove d = 12, it is enough to show that **no nonzero codeword has weight ≤ 8**, because weights 9
to 11 cannot occur in a doubly even code. That is the UNSAT question in every run below. Golay, the
[24, 12, 8] code (p = 23), is used as a smaller check with weight ≤ 4.

These codes are a step on the way to dense lattice sphere packings in dimensions 24k (Leech in
dimension 24, the extremal lattices P48p and P48q in dimension 48). The wider project wants these
proofs certified, which is why proof logging matters here.

## 2. Two models of the same code

### 2.1 Systematic model (`models/minweight.mzn`)

Write the generator matrix as G = [I | A]. A codeword is u·G = (u, u·A) for some u ∈ GF(2)^24.

```minizinc
array[1..k] of var bool: u;          % which rows are added
array[1..m] of var bool: c;          % c = u·A, one XOR chain per column of A
constraint forall(j in 1..m)( c[j] = xor of u[i] for A[i,j] = 1 );   % written as a chain of binary xors
constraint sum(u) >= 1;
constraint sum(u) + sum(c) <= Wmax;  % Wmax = 8
```

The 24 bits of u decide everything, and the XOR chains fix c as soon as u is fixed. MiniZinc
flattens each binary XOR into a `bool_xor`. Baguette's library turns each of these into **four
clauses**, so baguette only ever sees clauses and two cardinality sums.

### 2.2 Symmetric model (`models/minweight_sym.mzn`)

Because the code is self-dual, a vector x ∈ GF(2)^48 is a codeword if and only if it is orthogonal
to every codeword. The minimum-weight words span the code (their rank is 24 for QR48 and 12 for
Golay, checked), so it is enough to test those. We write
each test as an integer equation:

```minizinc
array[1..n] of var bool: x;                       % the word itself, n = 48
array[1..nW] of var 0..min(wd, Wmax) div 2: y;    % one integer per minimum-weight word w
constraint forall(w in 1..nW)( sum(i in w)(x[i]) = 2 * y[w] );   % x·w is even
constraint sum(x) >= 1;
constraint sum(x) <= Wmax;
```

QR48 has nW = 17,296 words of weight 12. Each equation has 12 Boolean variables and one integer
y_w ∈ 0..4 (4 = Wmax/2, because the sum cannot exceed the weight of x). In the PB encoding, y_w is
written with order literals [y_w ≥ 1], …, [y_w ≥ 4], so each equation becomes two linear
inequalities over 16 literals. With channelling and ladder clauses, baguette's .opb file has about
86,700 constraints. The systematic model has 985.

The equations are **720 times redundant**, since 24 parity checks would define the code. We did not
write the model this way for speed. We wrote it because it is **invariant under the automorphism
group** of the code, PSL(2, 47). An automorphism maps every equation to another equation of the
model, and every variable to another variable. That lets the proof checker accept symmetry breaking
as a proof step, using VeriPB's dominance rule with the automorphisms as witnesses (see
`dom/README.md`). For that, the full orbit of equations is needed: the 17,296 words form a single
orbit of PSL(2, 47), so no smaller invariant set exists.

### 2.3 Symmetry breaking

PSL(2, p) is 3-homogeneous on the p + 1 coordinates when p ≡ 3 mod 4. Any three coordinates of a
minimum-weight word can therefore be moved to coordinates 1, 2, 3, and the model may require them to
be in the support. In the symmetric model these requirements are clauses x_c ∨ ¬x_b. VeriPB checks
them as dominance steps, so the proof contains no symmetry axiom. Results are given with and without
this symmetry breaking.

## 3. Results

Node fataepyc-07 (AMD EPYC, 192 cores, shared, load around 55 during the runs). MiniZinc 2.10.1
with the Chuffed it ships, GCS at commit 5882c294, baguette at commit 2c97b16, VeriPB 3.0.2. Times
are wall-clock for solving, without flattening (3 s for the symmetric model). "Nodes" is each
solver's own counter.

### 3.1 Without symmetry breaking (QR48, weight ≤ 8, UNSAT)

| | Chuffed | GCS | baguette |
|---|---|---|---|
| systematic | **7.6 s**, 409,892 nodes | 27.5 s | > 1 h (113,315 nodes) |
| symmetric | > 1 h (407,269 nodes) | > 1 h | **1,951 s**, 15,823 nodes, 7,868 PB rows learned, proof 4.2 GB, verified |

### 3.2 With three coordinates fixed (QR48, weight ≤ 8, UNSAT)

| | nodes | time | time per node |
|---|---|---|---|
| Chuffed, systematic | 11,306 | 0.13 s | 11 µs |
| Chuffed, symmetric, default search | 28,666 (depth 17,301) | 104 s | 3.6 ms |
| Chuffed, symmetric, search on x, 1 first | 14,891 (depth 8) | 170 s | 11 ms |
| GCS, symmetric, default search | 21,385 | 117 s | 5.5 ms |
| baguette, systematic | 27,178 | 128 s | 4.7 ms |
| baguette, symmetric, default search | 1,205 | 96 s | 80 ms |
| baguette, symmetric, search on x, 1 first | 723 | 65 s | 90 ms |
| baguette, symmetric, **PB conflict analysis off** | ? | > 1800 s, 4.8 GB | |

The merged proof (dominance steps for the symmetry, followed by baguette's proof) is 834 MB, and
VeriPB checks it in about 4.5 minutes.

### 3.3 Golay, symmetric model, no symmetry breaking (weight ≤ 4, UNSAT)

| | default search | search on x |
|---|---|---|
| Chuffed | 10,403 nodes, 2.1 s | 430 nodes, 0.4 s |
| GCS | > 30 min, 27.8 million nodes | 855 nodes, 0.4 s |
| baguette | 130 nodes, 0.4 s | 130 nodes, 0.4 s |

## 4. Why

### 4.1 Chuffed: the same search, at a thousand times the cost per node

On QR48, Chuffed visits about as many nodes on both models (409,892 against 407,269 without symmetry,
and 11,306 against 14,891 with it). The redundant equations do not make its search any smaller. Each
node, however, costs a thousand times more. Every coordinate belongs to 4,324 of the 17,296 words,
so every decision wakes thousands of linear propagators. Chuffed performs 263 million propagations
in 28,666 nodes, about 9,000 per node, against 3 per node on the systematic model.

The reason the redundancy brings nothing is the form of what lazy clause generation learns. A
linear propagator explains each inference with a clause, and conflict analysis resolves clauses into
a new clause. Learning by resolution never adds two equations, so the 17,296 parity checks remain
17,296 separate facts. Resolution is also known to be exponentially weak at parity reasoning (Tseitin
formulas, Urquhart 1987), so no amount of clause learning recovers the linear algebra that is
missing.

### 4.2 Baguette: its learned constraints are sums of parity equations

Baguette's conflict analysis works on PB constraints. It combines the reason constraints linearly,
eliminates the pivot literal, and applies division or rounding when needed. Clause learning is used
only as a fallback. On the symmetric model the reasons are parity equations, so the learned
constraints are combinations of parity equations.

With symmetry, baguette learns 588 PB constraints on QR48, and 511 of them contain at least two of
the auxiliary integers y_w. Here is one of the shortest, as it appears in the proof, rewritten with
the model's names:

```
x6 + x7 + x11 + x12 + x21 + x23 + ¬x14 + ¬x15 + ¬x16 + ¬x18 + ¬x29 + ¬x34
  + 2·¬[y_a ≥ 1] + … + 2·¬[y_a ≥ 4] + 2·[y_b ≥ 1] + … + 2·[y_b ≥ 4]  ≥  14
```

where y_a and y_b belong to the words

```
w_a = {1, 4, 6, 7, 11, 12, 19, 20, 21, 22, 23, 43}
w_b = {1, 4, 14, 15, 16, 18, 19, 20, 22, 29, 34, 43}
```

which share the six coordinates {1, 4, 19, 20, 22, 43}. Replacing ¬ℓ by 1 − ℓ, the constraint reads

```
Σ_{i ∈ w_a \ w_b} x_i − 2·y_a  ≥  Σ_{i ∈ w_b \ w_a} x_i − 2·y_b
```

This is equation b subtracted from equation a, one direction of it. The six shared coordinates have
cancelled. Only the symmetric difference w_a ⊕ w_b is left, which is itself a word of weight 12,
together with the integer y_a − y_b. In other words, the solver has added two rows of the parity-check
system, one step of Gaussian elimination over GF(2), carried out with integer arithmetic. The other two
short learned constraints we examined have exactly the same structure.

Cutting planes can make such combinations and clauses cannot. Without symmetry, baguette learns
7,868 such rows and needs 26 times fewer nodes than Chuffed. With symmetry, it needs about 20 times
fewer nodes than Chuffed or GCS (18 to 24 times). Switching PB analysis off (`BAGUETTE_PB_ANALYSIS=off`, which leaves
clause learning only) loses everything: no answer in 30 minutes, and 4.8 GB of memory.

### 4.3 Why the systematic model gives baguette nothing

Baguette's MiniZinc library turns each XOR into four clauses. The XOR information is still present,
but only as clauses, so there are no linear sums for PB conflict analysis to combine. On the
systematic model, switching PB analysis off changes nothing at all (27,178 nodes either way).
Baguette then does plain clause learning at a high cost per node, and it loses to Chuffed. The cost
per node of this old binary is being worked on in baguette, so this gap will move, but the node
counts above do not depend on it.

### 4.4 A separate trap: branching on auxiliaries

Without a search annotation, Chuffed and GCS branch over every variable declared in the model,
including the 17,296 integers y_w. Chuffed's search depth goes up to 17,301. On QR48 this costs
little, because the y_w are almost always fixed by propagation. On Golay without symmetry, GCS is
lost in 27.8 million nodes when branching on the y_w, and needs 855 nodes when told to branch on x
only. Baguette's default search, first-fail with the smallest value first, picks the Booleans x before
the integers y and avoids this trap.

## 5. What this does and does not show

It shows that, on one structured family, PB conflict analysis turns redundant parity equations into
Gaussian-elimination-like reasoning that clause learning cannot reproduce, and that this can beat a
much faster solver by an order of magnitude or more in nodes. It also shows that the choice of
encoding decides whether this happens: the same code written with XOR clauses gives the PB learner
nothing.

It does not show a general ranking of solvers. There is one code family, one shared machine, timeouts
of one hour, and an old baguette binary. The solvers count nodes in different ways, and Chuffed's
default search is not tuned for this model. Natural next comparisons are CryptoMiniSat with Gaussian
elimination on the XOR form, RoundingSat (cutting planes) on the same .opb, and baguette's current
version.

## 6. Reproducing

All files are in the codes-cp repository. The node paths are in `bench/run1.sh`.

```sh
# instances: code, minimum-weight words, automorphisms used as witnesses
python3 scripts/symcode.py 47 8 3          # writes dom/sym_p47_w8.dzn (+ .json)
# the comparison (Chuffed, GCS, baguette x 4 model variants x Golay and QR48)
bash bench/sym.sh                          # results/runs/SYM_*
bash bench/symheur.sh                      # search annotations, results/runs/SH_*
# PB analysis on/off
BAGUETTE_PB_ANALYSIS=off main.exe dom/sym_p47_w8.fzn --stats
# baguette's proof with the symmetry breaking derived by dominance, checked by VeriPB
bash dom/run.sh sym_p47_w8
```

## References

- G. S. Tseitin, On the complexity of derivation in propositional calculus, 1968.
- A. Urquhart, Hard examples for resolution, J. ACM 34(1), 1987.
- W. Cook, C. R. Coullard, Gy. Turán, On the complexity of cutting-plane proofs, Discrete Applied
  Math. 18, 1987.
- O. Ohrimenko, P. J. Stuckey, M. Codish, Propagation via lazy clause generation, Constraints 14(3),
  2009 (Chuffed's approach).
- J. Elffers, J. Nordström, Divide and conquer: towards faster pseudo-Boolean solving, IJCAI 2018
  (RoundingSat).
- M. Soos, K. Nohl, C. Castelluccia, Extending SAT solvers to cryptographic problems, SAT 2009
  (Gaussian elimination in CryptoMiniSat).
- S. Gocht, J. Nordström, Certifying parity reasoning efficiently using pseudo-Boolean proofs, AAAI
  2021.
- B. Bogaerts, S. Gocht, C. McCreesh, J. Nordström, Certified dominance and symmetry breaking for
  combinatorial optimisation, JAIR 77, 2023.
