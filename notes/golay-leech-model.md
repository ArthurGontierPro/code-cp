# Idea: Golay code / Leech lattice as a baguette benchmark

Status: idea, nothing implemented. Written 2026-11-16 at Arthur's request, after a
conversation about the Monster group, the Leech lattice and extremal lattices.

## Why

Highly symmetric, rigid combinatorial objects. Uniqueness proofs (UNSAT after symmetry
breaking) are exactly what a proof-logging solver is good for. The extended binary Golay
code [24,12,8] is unique up to equivalence, and the Leech lattice is built from it
deterministically. Harder cousins exist as stretch goals (the open [72,36,16] code).

## Model A: the Golay code (start here)

Find a binary code of length 24, dimension 12, self-dual, doubly-even, min distance 8.

Variables
- Generator in systematic form `[I_12 | A]`, `A : array[1..12,1..12] of var bool`
  (144 Booleans). Systematic form loses no generality up to column permutation.

Constraints
- Self-orthogonality. For each pair of rows i<j (66 pairs):
  `sum_k A[i,k]*A[j,k]` even. For i=j (12 rows): row weight `1 + sum_k A[i,k]` ≡ 0 mod 4,
  i.e. `sum_k A[i,k] ∈ {3,7,11}`.
  - baguette has no `bool_xor` or parity global. Encode parity as
    `int_lin_eq` on products: `p_ijk = A[i,k] ∧ A[j,k]` (`array_bool_and`, or clauses),
    then `sum_k p_ijk - 2*t_ij = 0` with `t_ij ∈ 0..6`. Weight mod 4 the same way with
    `sum - 4*u_i = 3`.
  - Self-orthogonal + dimension 12 = self-dual. Doubly-even rows + self-orthogonal =
    whole code doubly-even.
- Min distance 8. A codeword is `x·[I|A]`, weight = `|x| + wt(xA)`. Doubly-even means
  forbidding weight 4 suffices.
  - Eager part: combinations of 1 row (`wt(A_i) ≥ 7`, NOT implied by the mod-4
    constraint, which still allows `sum_k A[i,k] = 3`; it must be posted, and it is
    the constraint that decides whether the model solves, see Results) and of 2 rows
    (`wt(A_i ⊕ A_j) ≥ 6`, encode xor as `bool` aux + clauses, then `bool_lin`
    via `int_lin_le` on `bool2int`). 3 rows: `wt ≥ 5`, 4 rows: `wt ≥ 4`.
    In general k rows need `wt(xA) ≥ 8-k`, so combinations of ≥ 8 rows are free
    (`|x| ≥ 8`), and k = 5, 6, 7 still need `wt(xA) ≥ 3, 2, 1`. So either
  - Lazy part: a checker over all 4095 nonzero combinations on full assignment, i.e.
    a custom propagator (would need a new global, not FlatZinc). For a first FlatZinc
    version, post all 4095 combination constraints eagerly with xor aux vars: big but
    finite (4095 × 12 xors). Measure.

Symmetries (what to break)
- Row permutations of A combined with the matching column permutation of I (keeps
  systematic form): sort rows of A lexicographically (`lex_lesseq` chain, decomposed by
  MiniZinc into clauses since baguette has no lex global).
- Column permutations of A: lex on columns too (double-lex, Flener et al.). Sound to
  combine row-lex and column-lex for a 0/1 matrix.
- Complementing / information set choice: not covered by double-lex. The full group
  acting on systematic forms is large (M24 has order 244823040, plus choice of the 12
  information positions), so double-lex will leave many solutions.

Expected results to check
- SAT search: find one solution quickly.
- Enumeration with double-lex: count solutions, compare to the orbit count predicted by
  |S_24| / |M24| and the number of information sets. Good sanity test.
- Uniqueness: the hard and interesting proof. Needs stronger breaking (e.g. fix the
  first row to the known weight-8 pattern, justified because every such code has a
  weight-8 word and S_24 is transitive on 8-sets) and then a verified UNSAT for "any
  other structure". Each fixing step must be a justified symmetry-breaking step in
  the VeriPB proof (dominance / `red` rules), which is itself a research question for
  baguette.

## Model B: Leech directly via the Gram matrix (harder, mostly for curiosity)

- Basis of 24 minimal vectors (Leech has one). Gram matrix `G` with diagonal 4,
  off-diagonals in {-2,-1,0,1,2} (|u·v| ≥ 3 would give |u-v|² ≤ 2). 276 vars, domain 5.
- Constraints: `det G = 1`, `G` positive definite, no `x ∈ Z^24` with `xᵀGx = 2`.
- The last one is the problem: infinite family, nonlinear. Needs a custom propagator
  run on each completed leading k×k block:
  - Cholesky incremental (positive definiteness),
  - Fincke–Pohst enumeration for vectors of norm 2 in the sublattice,
  - determinant lower bound `det(G_k) ≥ (4/γ_k)^k` (Hermite constant),
  - on failure, explain with the short vector x found (involves only G entries on its
    support): nogood for conflict learning, and a clean VeriPB justification would be
    the `x` itself (the certificate is checkable arithmetic).
- Symmetries: row/col permutation (lex on rows), sign flips (first nonzero of each
  row positive), and the huge choice of basis among 196560 minimal vectors that no
  cheap breaking addresses. Probably intractable without fixing a known substructure.
- Not FlatZinc-expressible as is. Would be a demo of a "custom certifying propagator".

## Questions for later

- Is a parity/xor global worth adding (Model A needs ~10^4 of them)? Gaussian
  elimination propagator with VeriPB justification is known territory.
- Lex global vs MiniZinc decomposition: compare node counts and proof size.
- Can baguette log symmetry breaking (`red` with witness) so the uniqueness proof is
  fully verified?
- Stretch: [48,24,12] uniqueness (known), [72,36,16] existence (open, attacked via
  automorphism case analysis).

## Results (2026-11-16)

Model: `golay/golay.mzn` (flags `K`, `LEX`, `COLS`), checker `golay/check.py`
(weight distribution of the code found, Golay iff 759/2576/759 at 8/12/16), runners
`golay/run.sh` (baguette + veripb) and `golay/sweep.sh` (Chuffed, parallel variants).
MiniZinc 2.10.1, Chuffed from the bundle, baguette at 2c97b16, all on fataepyc-07.

First model (row-combination distance only for 2 to K rows, the 1-row bound missing):
- K=0 (self-dual, doubly-even only): baguette 0.3 s, 311 nodes, proof VERIFIED. The
  code has 42 words of weight 4, as expected.
- K=4: baguette UNKNOWN after 1800 s, 48 928 nodes (27 nodes/s, 3 560 propagator runs
  and ~600 `rup` lines per node), 6.2 GB RSS, 2.9 GB proof that veripb could not load
  under an 8 GB cap. Chuffed UNKNOWN after 600 s, 2.27 M nodes.
- K=12: baguette hit the 8 GB cap at 1800 s (5.5 GB proof). Chuffed UNKNOWN at 600 s.

Cause: the missing `wt(A_i) ≥ 7`. Adding those 12 rows alone takes Chuffed on K=4
from 435 851 nodes / UNKNOWN at 120 s to 2 714 nodes / 0.6 s. It was a modelling bug,
not weak propagation.

Corrected model, Chuffed (deterministic: 5 seeds give identical node counts):

| variant | nodes | wall | Golay |
|---|---|---|---|
| K=2 LEX COLS | 235 | 0.9 s | yes |
| K=4 | 589 | 1.4 s | yes |
| K=4 LEX | 2 673 | 1.9 s | yes |
| K=4 COLS | 180 | 2.7 s | yes |
| K=4 LEX COLS | 439 | 3.0 s | yes |
| K=12 LEX COLS | 307 | 13 s | yes |

Every solution found is the Golay code, even at K=2, where only 1- and 2-row
combinations are constrained. Wall time is mostly flattening and posting at large K.
Baguette's per-node cost (~140x Chuffed's node rate on the first model) and proof
volume are the open questions for the next step.

### Sweep over K (2026-11-16, corrected model, no LEX, no COLS)

K = largest subset S of generator rows whose combination is constrained,
`|S| + wt(xor_S A) >= 8`. K = 7 is the full condition (|S| >= 8 is free); the model now
caps at 7. Baguette's "noproof" runs were not a measurement: without `--proof` the
binary still logs to a temp file (bin/main.ml:577), a no-log mode is on the roadmap.

| K | Chuffed nodes / wall | baguette nodes / wall | .pbp | veripb |
|---|---|---|---|---|
| 1 | 21 278 / 1.1 s, NOT Golay (d=4) | timeout 1800 s | 655 MB, truncated | rejected (partial) |
| 2 | 836 / 0.5 s, Golay | 60 567 / timeout 1800 s, 3.7 GB | 851 MB | NO CONCLUSION |
| 3 | 1 023 / 0.8 s | 1 959 / 5.7 s | 27 MB | SAT 1.4 s |
| 4 | 589 / 1.5 s | 1 959 / 11.6 s | 46 MB | SAT 2.7 s |
| 5 | 667 / 2.6 s | 1 959 / 21.8 s | 77 MB | SAT 4.4 s |
| 6 | 807 / 5.0 s | 1 959 / 34.9 s | 112 MB | SAT 6.4 s |
| 7 | 719 / 5.5 s | 1 959 / 46.4 s | 143 MB | SAT 8.9 s |

All found codes from K >= 2 are Golay. Baguette's tree is identical for K >= 3 (the
extra rows never change a decision), its time grows with the model size (~1 500
propagator runs per node), and K = 2 is a search failure specific to baguette.

### Which K forces Golay? (2026-11-16, Chuffed, `golay/code.mzn` + `subsets.py`)

Question: with the distance constraint posted only for combinations of <= K rows, can
the code still contain a weight-4 word? Witness formulation: some combination s of
m <= 4 rows has `wt(X_s) = 4 - m` (X shared with the model). A first witness through a
separate parity chain over a free vector x never connected to X and stayed UNKNOWN
even at K = 4, where the answer is immediate.

| K | plain | COLS | LEX + COLS |
|---|---|---|---|
| 1 | SAT 50 s (6 words of weight 4) | | |
| 2 | UNKNOWN 600 s | UNKNOWN 600 s | **UNSAT 1.7 s**, 1 133 nodes |
| 3 | UNKNOWN 600 s | UNKNOWN 600 s | UNSAT 1.9 s, 592 nodes |
| 4 | UNKNOWN 600 s | | |

So the 1- and 2-row combinations already force distance 8, hence Golay. Without
double-lex Chuffed cannot close even K = 4: "sum = 4 - m" and "sum >= 8 - m" on the same
terms are two separate linear rows, and nothing combines them. Double-lex is sound with
the witness (row/column permutations of A give an equivalent code, same weights).

### Length 48: [48,24,12] (q48), Chuffed, 1200 s each (2026-11-16)

| K | plain | COLS | LEX + COLS |
|---|---|---|---|
| 1 | SAT 132 s, d=4 | SAT 43 s, d=4 | SAT 212 s, d=4 |
| 2 | UNKNOWN (9.0 M nodes) | UNKNOWN (7.6 M) | UNKNOWN (5.5 M) |
| 3 | UNKNOWN | UNKNOWN | UNKNOWN |
| 4 | UNKNOWN | UNKNOWN | UNKNOWN (634 k bools, 2.4 GB) |

Flattening is not the issue (3 s at K=3, 34 s at K=4 COLS). Even K=1 (every row of
weight >= 12) takes minutes, against under a second at n=12, and K=1 still lets weight-4
words through. Where the 24 case stands: the search does not reach a d=12 code in 20 min.

### All leads in parallel (2026-11-16 afternoon)

Model `golay/code.mzn` (now commented in French for teaching), launcher
`launch_all.sh` on the node.

1. baguette, Golay, "does K force d=8?" (WEIGHT=4, LEX, COLS), proof checked by veripb:
   K=2 UNSAT 21 s, 2 119 nodes, 83 MB, VERIFIED UNSATISFIABLE in 8.5 s. K=3 13 s,
   K=4 19 s, both verified. The first certified UNSAT on this problem. Caveat: double-lex
   is a model constraint, so the proof covers "no lex-sorted code", and the soundness of
   the symmetry breaking is outside the proof (a `red`-logged lex is the open question).
2. Bordered double circulant (BDC), Chuffed: Golay at every K in < 2.5 s; q48 at K=1
   (1.7 s, lucky), K=3 (7.8 s, 168 nodes), K=4 (124 s). K=2 took 1 135 s and gave a
   d=8 code; COLS runs gave d=8 codes (K too small, valid answers to the relaxation).
   baguette with proof: Golay BDC 267 nodes, 6 s / 13 s, verified. q48 BDC K=2 and K=3:
   hit the 8 GB cap after 1 096-1 433 s with 7.7-9.9 GB of proof written, where Chuffed
   needs 168 nodes. A concrete performance target for baguette.
3. Chuffed free search (-f) on q48 without structure: UNKNOWN for K=1..3 in 1200 s
   (up to 50 M nodes). No help.
4. Lazy distance (cegar.py: solve, list the code's light words, forbid their row sets,
   repeat): Golay from K=1 in 6 rounds, 36 combinations, 50 s. q48 BDC in 1 round.
   q48 unrestricted: rounds 1-2 add 288 then 105 sets, round 3 times out at 1800 s.

## Bibliography (web search 2026-11-16, abstracts and indexes read, not full papers)

Objects and their status
- N. J. A. Sloane, "Is there a (72,36) d=16 self-dual code?", IEEE Trans. Inf. Theory
  19(2):251, 1973, doi:10.1109/tit.1973.1054975. The open problem, still open.
- Houghten, Lam, Thiel, Parker, "The extended quadratic residue code is the only
  (48,24,12) self-dual doubly-even code", IEEE Trans. Inf. Theory 49:53, 2003.
  Computer search in three cases. https://www2.cosc.brocku.ca/archive/node/182
- Error Correction Zoo, q48: https://errorcorrectionzoo.org/c/self_dual_48_24_12
- Borello, Dalla Volta, "The automorphism group of a self-dual [72,36,16] code does not
  contain S3, A4 or D8", https://arxiv.org/pdf/1303.4899 ; Borello, "... is not an
  elementary abelian group of order 8", https://arxiv.org/abs/1304.7162v2 . Together:
  |Aut| <= 5. Magma computations, not certified. Rules out our BDC form at 72 (it needs
  an automorphism of order 35).
- Bouyuklieva, O'Brien, Willems, on Aut of a [72,36,16] code:
  https://www.math.auckland.ac.nz/~obrien/research/code.pdf
- [96,48,20]: existence open, best known d=16 (Feit). Primes 23, 11, 7 excluded from
  |Aut| (Dontcheva), order 15 excluded (Bouyuklieva, Willems,
  https://www.arxiv.org/pdf/1403.4735 , https://web.math.ovgu.de/willems/papers/Aut15n96_new_part.pdf).

Double circulant classifications (references for our BDC runs)
- Gulliver, Harada, "On double circulant doubly even self-dual [72,36,12] codes and
  their neighbors", Australas. J. Combin. 40:137, 2008,
  https://ajc-new.maths.uq.edu.au/pdf/40/ajc_v40_p137.pdf . 134 inequivalent bordered DC
  and 576 pure DC [72,36,12] codes; none has an extremal [72,36,16] neighbour. Target
  count if we enumerate BDC d=12 at 72.
- Gulliver, Harada, "On extremal double circulant self-dual codes of lengths 90-96",
  AAECC 2019, doi:10.1007/s00200-019-00381-3, https://arxiv.org/pdf/1601.07343 .
  Classifies DC self-dual [96,48,16] codes: reference for our BDC d=16 runs at 96.
  Earlier: classification of extremal DC codes of lengths 74-88 (same authors).

Computer methods
- Brouwer, Polak, "Uniqueness of codes using semidefinite programming",
  https://arxiv.org/pdf/1709.02195 . Uniqueness of shortened Golay codes via SDP.
- "Using Constraint Solvers to Construct Binary Codes with Good Error Correction",
  AAAI, https://ojs.aaai.org/index.php/AAAI/article/download/38442/42404 . The closest
  prior work to ours: (n,k,d) codes as XOR constraints, SAT / MaxSAT / CP-SAT
  encodings, symmetry breaking on the generator. READ FIRST.
- Bright, Kotsireas, Ganesh, "SAT solvers and computer algebra systems: a powerful
  combination for mathematics", https://arxiv.org/pdf/1907.04408 . Survey.
- Bogaerts, Gocht, McCreesh, Nordström, "Certified dominance and symmetry breaking for
  combinatorial optimisation", JAIR 77:1539-1589, 2023 (AAAI 2022 version:
  https://eprints.gla.ac.uk/268237/3/268237.pdf , https://arxiv.org/pdf/2203.12275v3).
  How to log static symmetry breaking (lex) in VeriPB: what our uniqueness proof lacks.
- "The strength of the dominance rule", https://arxiv.org/html/2406.13657v1 .

Not found: any SAT/CP uniqueness proof of the Golay code or q48 checked by an
independent proof checker (DRAT or VeriPB). That is the gap baguette could fill.

## Comparison with Kochemazov, Zaikin, Trofimiuk, Antonov, Semenov, AAAI-26
`docs/23958-AAAI26.KochemazovS-CS.pdf`, code https://github.com/veinamond/AAAI-2026-Codes

What they do: general binary linear (n,k,d) codes (not self-dual), n 34-50, k 8/10/12,
d at the best known value from codetables.de (51 triples). Goal: minimise the error
coefficient T (number of weight-d words), the dominant term of the union bound on
decoding error. Solvers: Kissat, CP-SAT, SPB-MaxSAT-c-Band, then Painless and
Cube-and-Conquer on 128 cores. Results: codes for 44/51 triples (SAT alone 38/51), better
T than Magma's database in 26; (40,8,16) with T=1 (optimal) in 11 h of Kissat;
(35,10,12) T=7; (47,12,16) T=36. They claim the first use of constraint solvers to
construct linear codes.

Same as ours
- Systematic generator [I_k | A], unknowns = A, all 2^k - 1 combinations, the
  coordinates of each combination as XORs reusing the smaller combination (one 2-input
  XOR per bit, exactly our X[s] = X[parent] xor row), and the cardinality constraint
  "sum >= d - r" where r = |gamma| = our |S|, combinations with r >= d dropped.
- Symmetry breaking matters (Sym beats noSym for SAT/MaxSAT).

Different
- No self-duality / doubly-even structure, so no 2t / 4u rows, no COLS (for them
  [A^T|I] is the parity-check matrix of the DUAL code, not the same code).
- Always all combinations: no K-relaxation, no lazy distance. They name 2^k as THE
  limitation ("mainly applicable for relatively small codes"); k <= 12 is our Golay
  scale, q48 (k = 24) is out of their reach as stated.
- Symmetry breaking: first row FIXED to weight d with its ones grouped at the end, and
  columns of G in decreasing lex order. Ours: double-lex on rows and columns of A.
  Their first-row fixing assumes a minimum-weight word can be the first systematic row
  and that it stays compatible with the column order; not argued in the paper.
- Optimisation (T) via relaxation literals l_gamma ("sum + l >= d - r + 1") and a
  cardinality bound on sum l; "blocks" R restrict which |gamma| may reach weight d.
- No proof logging, no certified UNSAT. Existence questions (open codes,
  Cube-and-Conquer) and PB / native-XOR solvers are listed as future work.

What it suggests for baguette
1. Their 51 instances are a ready benchmark in our exact formulation (k <= 12).
   Run baguette / GCS / Chuffed on the satisfiable ones as they are.
2. The known NON-existence results they cite are certified-UNSAT targets of Golay size:
   (40,8,17) and (35,10,13) do not exist (Tjhai, Tomlinson, Grassl 2011, by
   computer). A VeriPB-checked refutation would be new. Same for "T <= u" lower
   bounds, e.g. that (35,10,12) needs T >= something, which they could not prove.
3. Our lazy distance (cegar.py + mindist.c) attacks their stated 2^k limitation; for
   non-self-dual codes the exact check needs the Brouwer-Zimmermann multiple
   information sets instead of our two-halves trick.

### Lengths 72 and 96 under BDC (2026-11-16, 1800 s per run, launch_big.sh)

| target | Chuffed (K=2,3) | GCS (K=2,3) | lazy (Chuffed, from K=1) |
|---|---|---|---|
| 72, d=12 | UNKNOWN | **K=2: SAT 179 s, exact d=12** | **round 1, 147 s, exact d=12** |
| 72, d=16 | UNKNOWN | K=2: SAT 654 s but d=12 (relaxation) | round 1 d=12, 499 sets added, then stuck |
| 96, d=16 | UNKNOWN | UNKNOWN | round 1 d=12, 47 sets added, then stuck |
| 96, d=20 | UNKNOWN | UNKNOWN | round 1 d=12, 331 sets added, then stuck |

K=4 at n=36 and GCS K=3 at n=48 died at the 8 GB cap during flattening/posting. A BDC
[72,36,12] doubly-even self-dual code is found (one of Gulliver-Harada's 134). No UNSAT
for d=16 at 72 (the expected, known answer): the eager model is too big, the lazy loop
restarts from scratch each round. GCS beat Chuffed on this family.
