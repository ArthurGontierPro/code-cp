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
