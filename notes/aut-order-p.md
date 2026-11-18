# [72,36,16] with an automorphism of prime order p (models/aut.mzn)

Written 2026-11-17. Sources: Feulner and Nebe, arXiv 1110.6012 (IEEE Trans. IT 2012),
sections II, IV (order 7) and V (order 5, D10). Local copies in `papers/` (gitignored).

## What Feulner and Nebe compute for order 7 (Theorem 4.2)

- Cycle type. By Conway and Pless (1982, Theorem 6), an automorphism σ of order 7 of an
  extremal [72,36,16] code has 10 seven-cycles and 2 fixed points (c = 10, f = 2).
- Ring. F2[x]/(x^7 - 1) = F2 ⊕ F8 ⊕ F8, with idempotents e0 = Σ x^i,
  e1 = 1 + x + x^2 + x^4, e2 = 1 + x^3 + x^5 + x^6. The involution x ↦ x^-1 swaps e1 and e2.
- Decomposition. C = φ0(C0) ⊥ (φ1(C1) ⊕ φ2(C1^⊥)), where C0 = C0^⊥ ≤ F2^12 is the fixed
  code projected to one bit per cycle plus the 2 fixed points, C1 ≤ F8^10 is any linear
  code, and its partner is its dual. The weight of a lifted fixed word is 7·wt(a) + wt(x).
  Every nonzero element of the F8 component has binary weight 4 on its cycle.
- D0 (the part of C0 that vanishes on the 2 fixed points) is doubly-even of dimension 4.
  Lemma 4.1 forces it to be the doubly-even subcode of F2^5 ⊗ (1,1), which gives 945 copies
  in F2^10.
- Enumeration. They list every C1 ≤ F8^10 with d(C1) ≥ 4 and d(C1^⊥) ≥ 4, up to semilinear
  isometry. By Singleton 3 ≤ k = dim C1 ≤ 7, and k ↔ 10-k is a symmetry, so they only need
  k ≤ 5. That gives 70 672 556 codes (their Table I). 177 850 of them pass
  d(φ1(C1) ⊕ φ2(C1^⊥)) ≥ 16. They glue each one with the 945 D0 and check the length-70,
  dimension-34 code D = φ0(D0) ⊕ C̃1, which is the kernel of the projection onto the fixed
  points. No D reaches d ≥ 16.

## Order 5 (not excluded)

- Cycle type 5^14 1^2 (same Conway–Pless theorem). F2[x]/(x^5 - 1) = F2 ⊕ F16, and the F16
  component is self-conjugate. So C = φ0(C0) ⊥ φ1(C1) with C0 = C0^⊥ ≤ F2^16 and
  C1 ≤ F16^14 Hermitian self-dual (dimension 7). The binary weight of x ∈ F16 on its cycle
  is 4 on the 5th roots of unity and 2 elsewhere (their "5-weight").
- D0 is the doubly-even subcode of the unique self-dual [14,7,4] code (Lemma 5.1).
- Feulner and Nebe only exclude D10 (order 5 together with an involution). They do this
  through F4-linear trace-Hermitian self-dual codes X ≤ F16^7. Z5 alone is open, and
  Aut(C) = Z5 is one of the remaining cases (with 1, 2, 3, 4 and Z2×Z2).

## The model

`models/aut.mzn` is generic in p (prime, with T = 1 field component, or T = 2 conjugate
components and p ≡ 7 mod 8), c and f. See its French header for the full derivation.

- F part: h = (c+f)/2 free rows A0 for C0. Self-orthogonality, weight p·wt + wt ≡ 0 mod 4,
  and weight ≥ d on all 2^h - 1 combinations.
- E part: a systematic form over the field after permuting cycles. For T = 2 this is
  E1 = [ε1 I_k | M] and E2 = [conj(M)^T | ε2 I_(c-k)] (the dual is explicit, so there is
  nothing to constrain). For T = 1 it is [ε1 I_(c/2) | M] with H(ρ,ρ') = 0. The blocks of M
  lie in K1, and each row has weight ≡ 0 mod 4.
- Distance: weight ≥ d on every sum of at most K "units" from distinct rows. A unit is a
  C0 row or a field multiple β·ρ of an E row. When KS = 0 all 2^deg - 1 scalars are used.
  For E1 alone, K = 3 already gives the full condition d(C1) ≥ 4 of the paper. The words
  that mix E1, E2 and F are the ones the relaxation misses.
- Lazy distance: `scripts/autcegar.py` solves, finds every word of weight < d with
  `mindist`, adds the generator sets that produce them (nE, E), and solves again.
  `scripts/autcheck.py` checks a solution independently (rank, self-orthogonality,
  doubly-even, σ-invariance, and the full weight distribution when n ≤ 52).

Assumptions that are not certified: H1, the cycle type comes from the literature. H2, the
systematic form after permuting cycles. H3, k ≤ c/2 (reversing every cycle swaps E1 and
E2). H4, the C0 rows are in strict lex order. The model does not use Lemma 4.1 or 5.1 (the
D0 structure), so it re-derives them.

## Instances (all on the node; `-D` strings)

Order 7 (expected: UNSAT for every k):

```
p=7;c=10;f=2;d=16;k=0;K=2;KS=0;LEX=true;nE=0;E=[];     UNSAT 0.9 s (measured)
p=7;c=10;f=2;d=16;k=1;K=2;KS=0;LEX=true;nE=0;E=[];     UNSAT 3.2 s (measured)
p=7;c=10;f=2;d=16;k=2;K=2;KS=0;LEX=true;nE=0;E=[];     UNSAT 4.3 s (measured)
p=7;c=10;f=2;d=16;k=3;K=3;KS=0;LEX=true;nE=0;E=[];     open: K=2 is SAT (relaxation) in 6 s
p=7;c=10;f=2;d=16;k=4;K=3;KS=0;LEX=true;nE=0;E=[];     same
p=7;c=10;f=2;d=16;k=5;K=3;KS=0;LEX=true;nE=0;E=[];     same; K=3 flattening > 60 s, > 2.4 GB
```

For k = 3, 4, 5, also run the lazy loop from K = 2:
`TL=3600 python3 scripts/autcegar.py results/aut/o7k3 "p=7;c=10;f=2;d=16;k=3;K=2;KS=0;LEX=true;"`
(and the same for k = 4, 5). PIDs go to `results/aut/o7k3.pid`.

Order 5 (the open search; there is a single case because T = 1 forces k = c/2 = 7):

```
p=5;c=14;f=2;d=16;k=7;K=1;KS=0;LEX=true;nE=0;E=[];     flattens in 2 s, UNKNOWN at 60 s
p=5;c=14;f=2;d=16;k=7;K=2;KS=0;LEX=true;nE=0;E=[];     flattens in 13 s, 0.5 GB, UNKNOWN at 60 s
p=5;c=14;f=2;d=16;k=7;K=3;KS=0;LEX=true;nE=0;E=[];     not tried (expect a few GB)
```

and the lazy loop: `python3 scripts/autcegar.py results/aut/o5 "p=5;c=14;f=2;d=16;k=7;K=1;KS=0;LEX=true;"`.

Optional, also open: order 3, with cycle type 3^24 (Bouyuklieva: no fixed points),
`p=3;c=24;f=0;d=16;k=12;...`. Here h = 12, the maximum the model accepts. Orders 2 and 4
are outside the model because p must be odd.

## What each outcome means

- Order 7, UNSAT for every k ≤ 5: reproduces Theorem 4.2 of Feulner–Nebe by an independent
  method, modulo H1 to H4. FOUND (autcegar finds no light word, autcheck passes) would
  contradict a published theorem, so suspect the model first. A relaxation SAT (plain run
  whose autcheck gives d < 16) means nothing: raise K or use the lazy loop.
- Order 5, UNSAT: no extremal [72,36,16] code has an automorphism of order 5. This would
  be new, and would leave |Aut(C)| ∈ {1, 2, 3, 4}. It needs independent confirmation
  (H1 to H4, ideally with a proof log). FOUND: an extremal [72,36,16] code. Check it with
  autcheck plus `mindist 36 16` on its systematic form, then by an outside tool, before
  believing it.
- UNKNOWN or timeout: no information.

## Sanity tests (node, ≤ 60 s each, 2026-11-17, Chuffed)

Every SAT below was re-checked by autcheck.py. The structure checks passed on all of them,
and the "min distance" column is the exact weight enumeration.

| instance | expected | got |
|---|---|---|
| Golay, p=23, c=1, f=1, k=0 and k=1 | SAT | SAT, d=8, 7 s |
| Golay, p=7, c=3, f=3, k=1 | SAT | SAT, d=8 (Golay distribution), 0.3 s |
| Golay, p=7, c=3, f=3, k=0 | UNSAT (E2 = K2^3 has weight 4) | UNSAT, 0.2 s |
| Golay, p=5, c=4, f=4 | SAT | SAT, d=8, 0.5 s |
| Golay, p=3, c=6, f=6 | SAT | SAT, d=8, 0.4 s |
| Golay, p=11, c=2, f=2 | SAT | SAT, d=8, 4.4 s |
| Golay, p=3, c=8, f=0, K=2 and 3 | SAT | relaxation SAT with d=4; lazy loop finds Golay in 2 rounds |
| Golay, wrong types 7^2 1^10, 5^2 1^14, 3^4 1^12 | UNSAT | UNSAT, < 1 s |
| q48, p=47, c=1, f=1, KS=2 | SAT | SAT, d=12, 0.7 s |
| q48, p=23, c=2, f=2, k=1 | SAT | UNKNOWN at 60 s with K=2, KS=0 (4M pairs); relaxation SAT with d=8 when KS ≤ 3; lazy loop still at d=8 after 8 rounds |
| length 48, d=12, p=7, c=6, f=6 (no such code) | UNSAT | k=0,1 UNSAT; k=2,3 relaxation SAT with d=8 even at K=3; lazy loop still at d=8 after 10 rounds |

Takeaway: the model is right on every case it can decide in 60 s. The K relaxation is too
weak at d ≥ 12 for the words that mix components, and the lazy loop is the way to close
them. That is a run for you to launch.

## Side finding: mindist.c and cegar.py

`mindist.c` prints, for a light word found on the [A^T | I] side, the row set of [A^T | I]
rather than of [I | A] (`s = side == 0 ? l : r`). `cegar.py` reads every light line as rows
of [I | A], so on that side it constrains a different (and possibly not light) word. That is
sound but wasteful. `autcegar.py` rebuilds both candidates and keeps the light one.

## 2026-11-18: heuristics, length-48 tests, faster lazy loops

- **The value order decides.** Order 7, k = 2 at length 72: with the annotation
  `bool_search(A0 ++ M, input_order, indomain_max)` (generator bits, 1 first; file
  `models/heur/aut_max.mzn`, made by `bench/heur.sh`) Chuffed needs 140 nodes and baguette 158
  nodes, 5 s, a 1 MB proof, VERIFIED. With `indomain_min`, Chuffed runs 16 M nodes without
  finishing in 30 min, and baguette's default (first-fail, 0 first) does not finish either.
  `autcegar.py` takes `MODEL=models/heur/aut_max.mzn`, and the length-72 loops (`bench/aut3.sh`)
  now run rounds of minutes instead of 8 h.
- **Length-48 ground truth** (`bench/equiv.sh`). The [48,24,12] code is unique (QR48, Houghten,
  Lam, Thiel, Parker 2003) and Aut = PSL(2,47), of order 2^4·3·23·47. Its elements of order 3 have
  no fixed point (3^16), those of order 23 have type 23^2 1^2. So the model must give a code for
  p = 23 and for p = 3 with type 3^16, and none for p = 5, 7, 11 or for p = 3 with fixed points.
  Result so far: p = 23, k = 0 UNSAT (10 s), k = 1 FOUND after 50 lazy rounds, and autcheck gives
  exactly the weight enumerator of QR48. The other cases are still running: their first
  rounds hit the 1 h limit, or the relaxed codes are still at d = 8.
- **IMG.** `IMG=1` adds, for every light set, its images under the transpositions of E1 rows
  (with their info cycles) and of E2 rows. These images exclude the symmetric copies of the
  current solution in advance. Rounds then add about 300 sets instead of 42. Whether this
  converges faster is being measured on the length-48 cases (`results/equiv/*_img.log`).

**Stopped 2026-11-18 evening.** None of the lazy loops (length 48 tests, orders 7, 5 and 3 at 72,
order 5 at 96) got past d = 8, except order 7, k = 5 at 72 (d = 12). IMG made no visible
difference. The monolithic lazy loop does not scale; next step is the Feulner–Nebe decomposition.
