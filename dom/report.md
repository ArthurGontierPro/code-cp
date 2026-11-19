# Same code, same search, two ways to write a parity check: pseudo-Boolean learning against clause learning

*codes-cp, interim version of 2026-11-19 (the first version, of the same morning, was reviewed and
is superseded; section 8 lists what changed). Some cells are still running and are marked so.*

## Summary

We ask four solvers to prove that the extended quadratic residue code QR48, the binary
[48, 24, 12] code, has no nonzero word of weight at most 8. We vary two things independently in the
model: which parity checks define the code (a basis of 24, or all 17,296 minimum-weight words), and
how each parity check is written (as a chain of XORs, or as an integer equation Σ x = 2y). The three
constraint solvers follow the same fixed branching order.

1. **For the solvers that learn clauses or nothing, the model does not matter for the search.**
   Chuffed (lazy clause generation) visits exactly the same number of nodes in all four variants:
   14,890 with three coordinates fixed, 54,350 with two, about 560,000 with none. GCS, which does
   not learn, visits exactly twice as many, also identical across variants.
2. **For the solvers that learn pseudo-Boolean constraints, writing parity as an integer equation
   changes the search.** With the same 24 parity checks, baguette goes from 29,779 nodes (XOR
   clauses) to 2,099 (sums). RoundingSat, with its own search, goes from 9,960 conflicts to 3,200,
   and without symmetry from 319,736 to 119,591.
3. **Redundancy is not what helps.** Adding all 17,296 checks makes every solver slower per node.
   It reduces the search of the PB learners somewhat more in some cases (baguette 1,273 nodes
   against 2,099) and increases it in others (11,491 against 1,219 at weight ≤ 4).
4. **In wall-clock time, Chuffed on the plain model remains as fast as anything here**, RoundingSat is
   level with it or close, and baguette (an older binary) loses by its cost per node.
   Dedicated minimum-distance algorithms (Brouwer–Zimmermann, as implemented in Magma) settle
   QR48 faster still, but produce no certificate. Our interest is in proofs a checker can verify,
   and in what these instances reveal about solvers.
5. **SAT solvers put points 1 and 2 in perspective.** Kissat on the plain XOR clauses, with its own
   search and restarts, needs as few conflicts as RoundingSat on the sums (117,716 against 119,591
   without symmetry) and is eight times faster. CryptoMiniSat, given the parity checks as native
   XORs, does Gaussian elimination on them: the 17,296 checks then cost nothing (the same conflict
   counts as with 24), and it is the fastest solver in every series. So the advantage of PB learning
   over clause learning seen in points 1 and 2 holds against lazy clause generation under a fixed
   search, not against a modern CDCL solver.

## 1. The question and what is certified

A binary linear code C of length n is a subspace of GF(2)^n, and its minimum distance d is the
smallest number of ones in a nonzero codeword. For a prime p ≡ −1 mod 8, the extended quadratic
residue code of length p + 1 is self-dual (C⊥ = C) and doubly even (every weight is a multiple of 4).
QR48 (p = 47) has d = 12, and it is the only self-dual doubly even [48, 24, 12] code (Houghten, Lam,
Thiel and Parker, 2003). Since weights 9 to 11 cannot occur, **d = 12 follows from: no nonzero
codeword of weight ≤ 8.** That is the UNSAT question of every run below. One series asks for
weight ≤ 4 instead, an easier question about the same code.

The solvers' proofs certify the unsatisfiability of the pseudo-Boolean (PB) model they were given,
and VeriPB checks them. What the proofs do not cover, and what we check by separate computation, is
that the model describes QR48: the generator matrix, self-duality, double evenness, the list of
17,296 words of weight 12 and the rank (24) of that list. The symmetry breaking of section 2.3 is
covered by the proof.

## 2. The models

### 2.1 The 2×2 design (`models/minweight_chk.mzn`)

Because the code is self-dual, x ∈ GF(2)^48 is a codeword if and only if x·w is even for every w in
a set of codewords that spans the code. We use two such sets:

- **basis**: 24 linearly independent words of weight 12, chosen greedily;
- **orbit**: all 17,296 words of weight 12 (rank 24, checked).

and two ways to write "x·w is even":

```minizinc
% ENC = 1, XOR: a chain acc_1 = x_{w1}, acc_t = acc_{t-1} xor x_{wt}, and acc_12 = false
% ENC = 2, sum: an integer y_w with
constraint sum(i in w)(x[i]) = 2 * y[w];          % y_w in 0..4, since the weight is at most 8
```

plus, in every variant,

```minizinc
constraint sum(x) >= 1;  constraint sum(x) <= 8;
solve :: bool_search(x, input_order, indomain_max) satisfy;   % the same search for every CP solver
```

The usual systematic model (generator matrix G = [I | A], the word is (u, u·A), XOR chains for
u·A, `models/minweight.mzn`) is the "basis, XOR" case up to the choice of the 24 checks. Its numbers
are close to that cell's and are not repeated here.

### 2.2 What each solver receives

MiniZinc translates the model into FlatZinc using each solver's own library. On QR48 without
symmetry breaking:

| model | Chuffed and GCS receive | baguette receives | baguette's PB file (.opb) |
|---|---|---|---|
| basis, XOR | 249 `bool_xor` | 996 clauses (4 per XOR) | 1,094 constraints, 321 variables |
| basis, sum | 24 `int_lin_eq` | 24 `int_lin_eq` | 218 constraints, 192 variables |
| orbit, XOR | 143,174 `bool_xor`, 125,974 variables | 572,696 clauses | 572,794 constraints, 125,974 variables |
| orbit, sum | 17,296 `int_lin_eq` | 17,296 `int_lin_eq` | 86,578 constraints, 69,280 variables |

All variants also have 48 `bool2int` and two `int_lin_le` (the weight bounds). In baguette's
encoding an integer y_w ∈ 0..4 becomes four *order literals* [y_w ≥ 1], …, [y_w ≥ 4], linked by
*ladder* clauses [y_w ≥ k+1] → [y_w ≥ k], and each equation becomes two linear inequalities.
RoundingSat reads the same .opb file as baguette, with constraint labels removed and variables
renamed (`scripts/opb2plain.py`), so the two PB solvers see an identical encoding.

### 2.3 Symmetry breaking

The automorphism group of QR48 contains PSL(2, 47), acting on the 48 coordinates, and this action is
3-homogeneous: any 3-set of coordinates can be mapped to any other. If a codeword of weight ≤ 8
existed, some automorphism would map three coordinates of its support to {1, 2, 3}, so we may
require coordinates 1, 2 and 3 to be in the support. This is written as clauses: x_1 ∨ ¬x_b for every
b ≠ 1 (if anything is in the support, 1 is), then x_2 ∨ ¬x_b for b ∉ {1, 2}, then x_3 ∨ ¬x_b for
b ∉ {1, 2, 3}. We run three versions: three coordinates fixed (138 clauses), two (93), and none.

In the orbit model these clauses need not be trusted. Each one is derived in the proof by a
*dominance* step of VeriPB, whose witness is an automorphism written as a permutation of the model's
variables. That requires every constraint to be mapped to another constraint of the model, which
holds for the orbit of the 17,296 words (`dom/README.md`). It does not hold for the basis models, so
there the clauses are axioms. This is why the redundant orbit model exists at all. (Whether some
smaller invariant set of codewords, of another weight, would also span the code is a question we
have not checked.)

## 3. Solvers and setup

| solver | what it is | search |
|---|---|---|
| Chuffed (with MiniZinc 2.10.1) | CP with lazy clause generation (LCG): every propagation is explained by a clause, and conflict analysis learns clauses | the model's annotation, strictly |
| GCS, commit 5882c294 | Glasgow Constraint Solver, CP with VeriPB proof logging; no nogood learning | the model's annotation |
| baguette, commit 2c97b16 | our CP solver, VeriPB proof logging; conflict analysis combines PB constraints (cutting planes: linear combination, division, saturation), with clause learning as fallback | the model's annotation |
| RoundingSat, commit d4edbf7 | PB solver, conflict analysis by cutting planes | its own (activity-based, restarts) |

Machine: one shared node (AMD EPYC, 192 cores, other jobs running, load 16 to 55). Each cell is a
single run. Node counts are deterministic for the three CP solvers (fixed search), wall-clock times
are not. Timeouts: 1 hour, 2 hours for the two-coordinate series, 3,600 s of baguette's own time limit
for the ablation. Chuffed, GCS and baguette count search-tree nodes. RoundingSat reports decisions
and conflicts, which are not the same counter. The baguette binary predates ongoing work on its cost
per node and its search, so its times are an upper bound on what it does now.

## 4. Results (QR48, weight ≤ 8, UNSAT)

Each cell: nodes (RoundingSat: decisions / conflicts), then time.

### 4.1 Three coordinates fixed

| | basis, XOR | basis, sum | orbit, XOR | orbit, sum |
|---|---|---|---|---|
| Chuffed | 14,890 · 0.3 s | 14,890 · 0.4 s | 14,890 · 60 s | 14,891 · 122 s |
| GCS | 29,779 · 0.7 s | 29,779 · 0.5 s | 29,779 · 346 s | 29,779 · 136 s |
| baguette | 29,779 · 102 s | **2,099 · 12 s** | no answer in 2,907 s | **1,273 · 89 s** |
| RoundingSat | 19,044 / 9,960 · 2.5 s | **5,872 / 3,200 · 0.3 s** | 4,549 / 3,501 · 200 s | 2,414 / 930 · 8.2 s |

### 4.2 Two coordinates fixed

| | basis, XOR | basis, sum | orbit, XOR | orbit, sum |
|---|---|---|---|---|
| Chuffed | 54,350 · 0.7 s | 54,350 · 0.9 s | 54,350 · 246 s | 54,332 · 451 s |
| GCS | 108,699 · 1.9 s | 108,699 · 1.3 s | 108,699 · 1,178 s | 108,699 · 535 s |
| baguette | running | **8,253 · 245 s** | running | **2,603 · 174 s** |
| RoundingSat | 96,057 / 50,906 · 13 s | **17,072 / 9,179 · 0.9 s** | 9,348 / 7,761 · 405 s | 6,353 / 2,946 · 38 s |

### 4.3 No symmetry breaking

| | basis, XOR | basis, sum | orbit, XOR | orbit, sum |
|---|---|---|---|---|
| Chuffed | 559,649 · 7.8 s | 563,957 · 9.6 s | 559,623 · 1,734 s | running (earlier run with default search: no answer in 1 h) |
| GCS | 1,127,913 · 17 s | 1,127,913 · 12 s | running | running |
| baguette | running | running | no answer in 3,093 s | **15,945 nodes, about 30 min** |
| RoundingSat | 499,121 / 319,736 · 111 s | **172,385 / 119,591 · 24 s** | 45,710 / 41,149 · 744 s | 126,703 / 86,403 · 841 s |

### 4.4 The easier question, weight ≤ 4, no symmetry breaking

| | basis, XOR | basis, sum | orbit, XOR | orbit, sum |
|---|---|---|---|---|
| Chuffed | 8,066 · 0.3 s | 8,208 · 0.3 s | 8,065 · 26 s | 7,884 · 47 s |
| GCS | 16,451 · 0.5 s | 16,451 · 0.3 s | 16,451 · 221 s | 16,451 · 52 s |
| baguette | 16,451 · 32 s | **1,219 · 3.7 s** | running | 11,491 · 450 s |
| RoundingSat | 9,662 / 4,839 · 0.8 s | **2,529 / 1,127 · 0.1 s** | 2,143 / 1,592 · 62 s | 4,509 / 2,125 · 36 s |

### 4.5 Ablation: baguette without PB conflict analysis

Orbit, sum, three coordinates fixed, with `BAGUETTE_PB_ANALYSIS=off` (clause learning only):
**29,771 nodes in 1,788 s, no answer**, against 1,273 nodes and 89 s with it. GCS, which learns
nothing, needs 29,779 nodes on the same search.

### 4.6 SAT solvers

The same instances as DIMACS (`scripts/gencnf.py`): the 48 bits, each parity check either as a native
XOR of CryptoMiniSat (5.18.0) or as the same XOR clauses that baguette receives, Σ x ≥ 1 as one clause,
Σ x ≤ Wmax as a totalizer (pysat), and the same fixed-coordinate clauses. CryptoMiniSat runs with
Gaussian elimination (its default) and without it (`--maxnummatrices 0`). Kissat 4.0.2 runs on the
clauses. All use their own search. Each cell: conflicts · time.

| | basis, XOR clauses | basis, native XOR | orbit, XOR clauses | orbit, native XOR |
|---|---|---|---|---|
| **3 coordinates fixed** | | | | |
| Kissat | 3,140 · 0.1 s | | 1,187 · 3.2 s | |
| CryptoMiniSat, Gauss | 1,521 · 0.2 s | 2,661 · 0.1 s | 1,996 · 49 s | 2,661 · 0.2 s |
| CryptoMiniSat, no Gauss | | 4,971 · 0.2 s | | 1,491 · 0.5 s |
| **2 coordinates fixed** | | | | |
| Kissat | 12,428 · 0.3 s | | 5,199 · 6.0 s | |
| CryptoMiniSat, Gauss | 5,791 · 0.3 s | 6,042 · 0.2 s | 5,934 · 60 s | 6,042 · 0.2 s |
| CryptoMiniSat, no Gauss | | 19,906 · 0.4 s | | 5,692 · 1.4 s |
| **no symmetry breaking** | | | | |
| Kissat | 117,716 · 3.0 s | | 38,025 · 48 s | |
| CryptoMiniSat, Gauss | 69,393 · 1.8 s | 81,276 · 1.8 s | 53,839 · 336 s | 69,880 · 1.6 s |
| CryptoMiniSat, no Gauss | | 216,570 · 4.3 s | | 82,977 · 21 s |
| **weight ≤ 4** | | | | |
| Kissat | 2,630 · 0.1 s | | 551 · 3.3 s | |
| CryptoMiniSat, Gauss | 1,303 · 0.2 s | 1,235 · 0.1 s | 1,221 · 61 s | 1,173 · 0.2 s |
| CryptoMiniSat, no Gauss | | 2,061 · 0.2 s | | 1,092 · 0.4 s |

With native XORs and Gaussian elimination, CryptoMiniSat builds one 24 × 47 matrix whatever the
number of checks (its log says so), and the orbit gives exactly the conflict counts of the basis
(2,661 and 6,042). One difference with the PB solvers is not controlled: they receive the weight
bound as one linear inequality, the SAT solvers as a totalizer.

## 5. What the numbers say

### 5.1 Clause learning sees the same problem in every variant

With a fixed branching order, a solver that does not learn visits a tree determined by when
propagation detects failure. GCS's counts are identical in all four variants, so all four encodings
detect failure at the same nodes. Chuffed's are also identical, and half of GCS's: its learned
clauses prune the same half of the tree whatever the encoding. Neither the integer form nor the
16,000 extra checks give a clause learner anything to work with. They only cost propagation: on the
orbit, Chuffed's node costs 300 to 1,000 times more than on the basis.

### 5.2 PB learning uses the integer form

The two PB learners, written independently, behave alike. With XOR clauses, they learn only clauses
(baguette's clause-only search, 29,779 nodes, is exactly GCS's tree: under this fixed search its
clause learning prunes nothing). With the integer form, their conflict analysis adds and scales the
parity equations, and the search shrinks: by 14 times for baguette and 3 times for RoundingSat
(conflicts) with three coordinates fixed, and by 2.7 times for RoundingSat without symmetry. The
ablation confirms it for baguette: without PB analysis, it is back to GCS's tree.

Linear combinations of parity equations are how parity reasoning is done over the integers, which is
the idea behind the PB parity proofs of Gocht and Nordström (2021). We do not claim more than that.
It is not known that cutting planes do Gaussian elimination efficiently in general, and no lower bound
for clause learning on these particular formulas is shown here.

### 5.3 What baguette learns (interim)

On the orbit model with three coordinates fixed, baguette learns 588 PB constraints. A linear
program tests each one (`scripts/learnedlp.py`):

- 85 are implied, over the reals, by the parity equations of the words they mention alone. They are
  nonnegative combinations of axioms and add no information from the search. The example shown in the
  first version of this report is of this kind: one half of one equation minus one half of another,
  the six shared coordinates cancelling.
- 203 more are implied once the weight bounds and the fixed coordinates are added.
- 300 are not implied by any of these. Whether they follow linearly from all 17,296 equations, or
  needed rounding (division), is being computed.

### 5.4 Against SAT solvers

Conflicts and nodes are different counters, but the orders of magnitude are clear. Without
symmetry breaking, on the basis: Kissat 117,716 conflicts (clauses), RoundingSat 119,591 (sums) and
319,736 (clauses), CryptoMiniSat 69,393 to 81,276, Chuffed 559,649 failures under the fixed
search. A CDCL solver with its own branching, restarts and clause management learns from the XOR
clauses about as well as RoundingSat learns from the sums. RoundingSat's own clause learning is the
weaker one here. What made the PB learners look strong in sections 5.1 and 5.2 is partly the
comparison: Chuffed and baguette's clause path under a fixed search. With the sums, baguette's
fixed-search node counts (2,099 with three coordinates, 8,253 with two) are still the smallest of all
solvers, but its cost per node makes it the slowest.

Gaussian elimination is what a parity problem calls for: CryptoMiniSat with it is the fastest
everywhere, and it is the only solver for which the redundant orbit costs nothing.

### 5.5 Redundancy

The orbit is 720 times redundant. Every solver pays for it per node. For the PB learners it sometimes
reduces the search further (baguette 1,273 nodes against 2,099, RoundingSat 930 conflicts against
3,200) and sometimes not (baguette at weight ≤ 4: 11,491 against 1,219). In wall-clock time the basis
with sums is the best variant for both PB solvers in every series. We keep the orbit only because it
lets the proof certify the symmetry breaking (section 2.3).

## 6. Is this the right model?

A fair objection is that the redundant orbit model is a strange way to state the problem. Two
answers. First, the comparison does not depend on it: the decisive factor, integer sums against XOR
clauses, appears just as clearly on the 24-check basis, which carries exactly the information of the
usual systematic model. Second, each solver's best variant is in the tables. Chuffed's best is the
basis with XOR (or sums, the same), and it is as fast as anything here. RoundingSat's best is the
basis with sums. Baguette's best is the basis with sums too. Nobody is compared on a model chosen to
handicap them. The orbit model is there for a different reason (certified symmetry breaking) and is
reported as such.

For computing d(QR48) itself, constraint solving is not the right tool: dedicated minimum-distance
algorithms are much faster. What a solver with proof logging adds is a certificate.

## 7. Limits

One code, one machine shared with other jobs, single runs, timeouts of one or two hours, an old
baguette binary. RoundingSat, Kissat and CryptoMiniSat use their own search, the CP solvers a common
fixed one. The SAT solvers get the weight bound as a totalizer. Section 5.3 is interim. Natural next
steps: the same design on QR72 and QR80, where the searches are much larger, and baguette's current
version.

## 8. Changes from the first version

The first version compared only "systematic with XOR" against "orbit with sums", which mixed two
factors. It explained baguette's advantage by redundancy and called a learned constraint a Gaussian
elimination step, although that constraint was a plain sum of two axioms. It cited Tseitin formulas
without a lower bound for this problem, compared node counts taken at timeouts, and used different
searches for different solvers. The 2×2 design, the common search, RoundingSat, the ablation with
node counts, the two-coordinate instance (where Chuffed finishes) and the classification of learned
constraints answer these points.

## 9. Reproducing

All files are in the codes-cp repository. Solver paths are at the top of `bench/run1.sh` and
`bench/rs1.sh`.

```sh
python3 scripts/symcode.py 47 8 3      # dom/sym_p47_w8.dzn: the 17,296 words, 3 fixed coordinates
python3 scripts/symcode.py 47 8 2      # dom/sym_p47_w8_f2.dzn: 2 fixed coordinates
python3 scripts/basisdzn.py dom/sym_p47_w8.dzn dom/sym_p47_w8_basis.dzn   # a basis of 24
bash bench/x2.sh; bash bench/x2f2.sh; bash bench/x2rs.sh                 # results/runs/X2_*
python3 scripts/learnedlp.py dom/sym_p47_w8.fzn dom/sym_p47_w8.pbp       # section 5.3
```

## References

- W. C. Huffman, V. Pless, *Fundamentals of Error-Correcting Codes*, Cambridge, 2003 (QR codes, PSL(2, p)).
- S. K. Houghten, C. W. H. Lam, L. H. Thiel, J. A. Parker, The extended quadratic residue code is the
  only (48, 24, 12) self-dual doubly-even code, IEEE Trans. Inf. Theory 49(1), 2003.
- O. Ohrimenko, P. J. Stuckey, M. Codish, Propagation via lazy clause generation, Constraints 14(3), 2009.
- J. Elffers, J. Nordström, Divide and conquer: towards faster pseudo-Boolean solving, IJCAI 2018.
- W. Cook, C. R. Coullard, Gy. Turán, On the complexity of cutting-plane proofs, Discrete Appl. Math. 18, 1987.
- S. Gocht, J. Nordström, Certifying parity reasoning efficiently using pseudo-Boolean proofs, AAAI 2021.
- B. Bogaerts, S. Gocht, C. McCreesh, J. Nordström, Certified dominance and symmetry breaking for
  combinatorial optimisation, JAIR 77, 2023.
- M. Soos, K. Nohl, C. Castelluccia, Extending SAT solvers to cryptographic problems, SAT 2009.
