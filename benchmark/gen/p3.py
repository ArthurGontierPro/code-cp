#!/usr/bin/env python3
"""p3.py N K D OUT.json -- canonical instance of family P3: does a binary linear [N, K, >= D] code exist?

Ground truth without tables:
  - UNSAT is proved when (N, K, D) violates the Griesmer bound N >= sum_{i<K} ceil(D / 2^i);
  - SAT is established by any solution, checked independently (scripts/lincheck.py: the generator
    matrix found has rank K and every nonzero codeword has weight >= D);
  - otherwise expected = "unknown" until a solver answers (and its answer is then checked or
    compared with the tables of codetables.de).
The writers delegate to the two existing encodings: the AAAI-26 CNF (their construct_SAT.py) and
models/linear.mzn / linear_dom.mzn for MiniZinc."""
import sys, json, math
n, k, d, out = int(sys.argv[1]), int(sys.argv[2]), int(sys.argv[3]), sys.argv[4]
gries = sum(math.ceil(d / 2 ** i) for i in range(k))
inst = {"family": "P3", "name": out.rsplit("/", 1)[-1][:-5], "n": n, "k": k, "d": d,
        "griesmer": gries, "expected": "UNSAT" if n < gries else "unknown",
        "source": f"Griesmer bound {gries}" + (" > n, so no such code" if n < gries else " <= n")}
json.dump(inst, open(out, "w"))
print(f"{out}: [{n},{k},{d}] Griesmer {gries} expected={inst['expected']}")
