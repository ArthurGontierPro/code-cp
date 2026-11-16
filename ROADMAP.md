# Roadmap

Goal: dense sphere packings in dimensions 24k, i.e. extremal even unimodular lattices
(24: Leech; 48: several known; 72: one known, Nebe; 96: open). The code experiments
of 2026-11-16 (Golay, q48, [72,36,*], AAAI-26 benchmark, see STATUS.md) were the
warm-up. Solvers: GCS with proof logging for scale; Chuffed for quick probing; Kissat
when the problem is pure SAT; baguette kept in every comparison because its failures
have found real bugs (see R0).

## R0. Housekeeping
- R0.1 baguette `--time-limit` overshoot: on 1 h runs baguette never reached its own
  limit check, the outer timeout cut 36 proofs mid-write. Measurement running in
  `/scratch/arthur/codes-cp/dbg` (limits 600/1200/2400/3600 s). Report to the baguette
  sessions (WORKLOG cross-session request) with the numbers.
- R0.2 Move the node layout from `/scratch/arthur/golay` to `/scratch/arthur/codes-cp`
  in the scripts.

## R1. Literature: extremal lattices in dimensions 48, 72, 96
What is known, what is open, which computations were done and how (enumeration,
automorphism-based constructions, codes over rings), and where a certified constraint
approach could add something. Output: a section in notes/ with references.

## R2. Leech lattice from scratch (dimension 24)
Gram-matrix model (notes, Model B): basis of minimal vectors, diagonal 4,
off-diagonal in {-2..2}. Short vectors forbidden LAZILY: for a fixed integer x,
x^T G x is linear in G, so "no vector of norm 2" is one linear cut per x found by
Fincke-Pohst, exactly the cegar.py loop with mindist.c replaced. Open part: positive
definiteness and det G = 1 (nonlinear). First with Chuffed/GCS outside the solver,
then as a GCS propagator whose justification is the vector x.

## R3. From codes to lattices
Build Leech from the Golay code by an explicit construction (Construction A gives
norm-2 vectors, a twisted construction is needed), then use the codes we can find
(q48, [72,36,12] BDC) as starting points for dimension 48 and 72 constructions.
