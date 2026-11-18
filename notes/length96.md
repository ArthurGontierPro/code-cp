# Length 96: what is known about an extremal [96,48,20] code (2026-11-18)

Sources read (local copies in `papers/d96/`, not tracked):
- Bouyuklieva, Willems, Yankov, "On the automorphisms of order 15 for a binary self-dual
  [96,48,20] code", Des. Codes Cryptogr. (2015), arXiv 1403.4735.
- Their table (1), quoting de la Cruz and Willems, "On extremal self-dual codes of length 96",
  IEEE Trans. IT 57 (2011) 6820-6823 (not read, paywalled; preprint 11-02 at math.ovgu.de).

## Facts

- Existence is OPEN (as at 72). Only Golay (24) and QR48 (48) are known among lengths 24m.
- Only the primes 2, 3, 5 can divide |Aut(C)|. Cycle types of prime-order automorphisms:

  | p | p-cycles | fixed points | h = (c+f)/2 | fits aut.mzn (h ≤ 12)? |
  |---|---|---|---|---|
  | 2 | 48 | 0 | | no (p must be odd) |
  | 3 | 30 | 6 | 18 | no |
  | 3 | 32 | 0 | 16 | no |
  | 5 | 18 | 6 | 12 | yes: `p=5;c=18;f=6;d=20;k=9;` |

- Type 3-(28,12) is excluded (their Proposition 1, by MacWilliams identities).
- Order 15 is excluded (their Theorem 1, a GAP/Q-Extension enumeration, no certificate).
- de la Cruz–Willems (abstract): if elements of order 3 act fixed-point-freely, Aut(C) is
  solvable of order at most 160, or is A5.
- An order-7, 11 or 23 automorphism is excluded (Dontcheva et al., attribution unverified).

## What we can run

`aut.mzn` with `p=5;c=18;f=6;d=20;k=9;K=1;KS=0;LEX=true;` flattens in 39 s (43 MB FlatZinc,
0.6 GB). It is the length-96 analogue of our open order-5 case at 72 (`c=14, f=2, h=8, k=7`),
and larger. An UNSAT would be new; a code found by the lazy loop must pass `autcheck.py` and
`mindist 48 20`. Order 3 needs h = 16 or 18, i.e. 2^16 to 2^18 C0 combinations in the model's
distance constraint; the assertion `h ≤ 12` would have to be lifted, with those combinations
made lazy.

The lattice of dimension 96 and minimum 10 is a different problem: no binary construction
reaches minimum 10 (A gives 2, B and the Leech-style doubling give 4). See RESULTS.md and the
discussion of 2026-11-18 (codes over Z_{2k} with k ≥ 5, ideal lattices in Q(ζ97), tensor
products).
