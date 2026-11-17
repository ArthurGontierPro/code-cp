# R1 — Extremal even unimodular lattices: literature (2026-11-17)

Extremal = even unimodular, dim n ≡ 0 mod 8, minimum norm 2⌊n/24⌋+2. Jump dimensions 24k.

## State of the art

| dim | min | known | status |
|---|---|---|---|
| 24 | 4 | Leech, unique | uniqueness Conway 1969; densest lattice Cohn–Kumar (Annals 2009, computer-assisted) |
| 48 | 6 | 4: P48p, P48q, P48n, P48m | full classification open ("seems impossible", Nebe). Partial: all with an automorphism of order m, φ(m) > 24, are P48p/q/n (Nebe 2013). P48m found 2013 via an order-5 automorphism |
| 72 | 8 | 1: Γ72 (Nebe 2010, Barnes ⊗ Leech) | unique among those with a large automorphism (order 91 or 168). Existence open for 50 years before 2010 |
| 80 | 8 | 4 (Bachoc–Nebe ×2 1998, Stehlé–Watkins, Watkins 2012) | not a jump dimension |
| 96, 104, 120 | 10 | none | OPEN. Kominers 2026: at most one degree-2 Siegel theta series in rank 96 |
| > 163264 | | | do not exist |

An unrefereed GitHub repo (roiban1344) claims a 112-dim candidate with minimum 10. Unverified.

## How extremality is proven

It is a computation, i.e. an UNSAT claim: "no nonzero integer x with xᵀGx < min".
- Γ72: two proofs. One reduces to the Leech minimal vectors (Z[α] structure). The other uses
  Watkins' orbit listing of norm-8 vectors: 6 218 175 600 vectors.
- Stehlé–Watkins criterion: an even unimodular 72-dim lattice with min ≥ 3 is extremal iff it
  has ≥ 6 218 175 600 vectors of norm 8. Counting replaces enumeration below the minimum.
- dim 80 (Stehlé–Watkins, ANTS-IX): enumeration with rigorous floating point (Pujol–Stehlé).
No source found of a proof-logged / independently checkable certificate for any of these.

## Searches for new lattices

They go through prescribed automorphism groups (Nebe's method): fix a group, enumerate the
invariant lattices, check the minimum. This is our BDC/circulant hypothesis in another form.
Codes route: Type II Z4 codes of length 48 give extremal lattices through Construction A4
(Harada, 4-negacirculant searches at 56 and 64). Length 72: extremal Type II Z_{4k} codes
exist for k ≥ 2 (Harada–Miezaki, built from Γ72). Z4 at length 72 is open.

## What this means for us

1. Certified extremality (new, small, publishable): a VeriPB proof that Leech has no norm-2
   vector, then the P48 lattices (no norm ≤ 4). Model: Gram matrix G fixed, x bounded by
   |x_i| ≤ sqrt(m (G⁻¹)_ii), constraint xᵀGx ≤ m−2. Pure UNSAT, GCS + baguette.
   72 is likely out of reach by direct enumeration (that is why counting proofs exist).
2. Search under symmetry (R2): find P48 lattices again from a prescribed automorphism, with
   the Gram model and lazy short-vector cuts. The open target is a fifth 48-dim lattice, or
   any 96.
3. Codes (R3): extremal Type II Z4 code of length 72 is open and fits our code models
   (Z4 instead of F2), with Construction A4 giving the lattice.

## To download (paywalled or not yet read)
- Stehlé, Watkins, "On the extremality of an 80-dimensional lattice", ANTS-IX, LNCS 6197 (2010).
  https://perso.ens-lyon.fr/damien.stehle/DIM80.html (may have the preprint)
- Bachoc, Nebe, "Extremal lattices of minimum 8 related to the Mathieu group M22",
  J. reine angew. Math. 494 (1998). https://www.math.u-bordeaux.fr/~cbachocb/articles/extrem.pdf
- Conway, Sloane, SPLAG, ch. 7 (theta series, extremal bound) and ch. 16 (Construction A4).

## Open access, read next
- Nebe, Γ72: https://arxiv.org/abs/1008.2862 ; automorphisms dim 72: http://www.math.rwth-aachen.de/~Gabriele.Nebe/papers/dim72ideal.pdf
- Nebe, dim 48: https://arxiv.org/abs/1212.0865 , https://arxiv.org/abs/1312.3780
- Kominers 2026: https://arxiv.org/abs/2606.08733
- Cohn–Kumar: https://arxiv.org/abs/math/0403263
- Harada–Miezaki Z_{2k}: https://arxiv.org/abs/1205.6947 , Harada: https://arxiv.org/abs/2201.01439
- Watkins dim 80: https://www.numdam.org/articles/10.5802/jtnb.795/
- Nebe's lattice catalogue (Gram matrices!): https://www.math.rwth-aachen.de/~Gabriele.Nebe/LATTICES/

## Reading notes (2026-11-17, from the downloaded PDFs, kept local and untracked)

### Stehlé–Watkins, extremality of N80 (ANTS-IX 2010)
- Shape of an extremality proof. Θ lies in a space of modular forms of dimension 4, with a
  triangular basis f0..f3, so Θ = f0 + a1 f1 + a2 f2 + a3 f3. "No norm 2 or 4" gives a1 = a2 = 0.
  Then a3 ≥ 0 by positivity, and EXHIBITING 7.5·10^12 norm-10 vectors (15.3 M orbits under
  SL2(79)) forces a3 = 0. The hard UNSAT part (norm 6) is replaced by a SAT part (a witness
  set that is cheap to check). The checker runs in 10 h, against 4 days × 14 cores to find it.
- Norm 2 directly takes under 30 min. Norm 4 directly would take "a few months". They bypass it
  through a doubly-even self-dual BINARY code C2 (it is the extended QR code of length 80, d=16)
  and lift its weight-16 words by hand. Proving that code has d > 20 directly is estimated at
  58 days. This is exactly our code models' problem.
- Enumeration is Kannan–Fincke–Pohst with Schnorr–Euchner zig-zag, pruning, and basis
  re-randomisation. Orbit canonical forms use lex order after moving the two largest coordinates.

### Bachoc–Nebe, minimum 8 and M22 (Crelle 1998)
- In 1998, "algorithms to compute the minimum are limited to dimensions around 60".
- L80 and M80 have minimum 8 proved through a construction from a (10,5,4) binary code over
  the lattices Z[α], A2⊗A2, E8. The lattice minimum becomes a WEIGHT on the code (Def. 4.2,
  Lemma 4.3), i.e. lattice minimum = code distance for a nonstandard weight. Codes again
  replace enumeration.

### SPLAG (Conway–Sloane, 3rd ed.)
- Ch. 7 §7: extremal Type II bounds d ≤ 4⌊n/24⌋+4 for codes and μ ≤ 2⌊n/24⌋+2 for lattices.
  Extremal theta series: 48 → 1 + 52 416 000 q^6, 72 → 1 + 6 218 175 600 q^8.
  The binary [72,36,16] Type II code is "the first open case". It is STILL open (Nebe and others
  have reduced the possible automorphism groups to very small ones).
- Ch. 5 §5.4–5.7: P48p and P48q come from TERNARY [48,24,15] codes (Pless double circulant
  and extended QR) by Construction B3, then density doubling with the translate
  (−5/2, 1/2^47) (scaled). Table 5.3 gives the 52 416 000 minimal vectors by shape.
- Construction A4 from Z4 codes also gives Leech (ch. 4 notes).

## Consequences for the roadmap
- R3 is more central than I thought. In every known proof, extremality at 48 and 80 goes
  through a CODE (binary or ternary), because direct enumeration does not scale. So our code
  models are the right tool. The natural targets are:
  (a) the binary Type II [72,36,16] code, open for 50 years (our model at q72, which we ran
      under BDC; the literature already excludes most automorphism groups);
  (b) CORRECTED 2026-11-17: ternary extremal [72,36,21] does NOT exist (negative coefficient in
      the extremal weight enumerator, Rains–Sloane survey). Not a target.
- R0/R2 certificate: reproduce Leech "no norm 2" and P48 "no norm ≤ 4" as VeriPB proofs.
  The Stehlé–Watkins shape (a cheap witness set + a modular-form identity) is a template for
  checkable proofs that do not need full UNSAT enumeration.

## [72,36,16] state of the art (checked 2026-11-17)
- Still open. Aut(C) is cyclic of order 1, 2, 3, 4 or 5, or elementary abelian of order 4
  (Borello–Dalla Volta–Nebe, arXiv 1303.4899). Later papers exclude Z2×Z2×Z2 (1304.7162) and Z4
  (1310.2570). Order 6 (1203.3321), Z7, Z3×Z3 and D10 (1110.6012) are excluded too.
- CONSEQUENCE: our BDC runs at q72 were hopeless by construction, because a bordered double
  circulant has an automorphism of order 35, which is excluded. Any symmetry hypothesis at 72
  must be of order ≤ 5.
- These exclusions are computer classifications (fix σ, enumerate the fixed and the σ-invariant
  subcodes, glue). Each one is a finite UNSAT with no independent certificate: a certification
  target that fits CP + VeriPB.
