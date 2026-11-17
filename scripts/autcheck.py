#!/usr/bin/env python3
"""autcheck.py p c f [d] < solver_output -- independent check of a models/aut.mzn solution.

Reads the "G 0101..." lines (the n/2 binary generators), and checks, without trusting the
model: rank n/2, self-orthogonality, doubly-even generators, invariance under
sigma = (1..p)(p+1..2p)...(c cycles), f fixed points. Then the weight distribution by full
enumeration when n/2 <= 26 (meet in the middle over two halves of the generators);
otherwise only the structural checks. Prints one line per check and exits 1 on a failure.
"""
import sys, collections
import numpy as np

p, c, f = map(int, sys.argv[1:4])
d = int(sys.argv[4]) if len(sys.argv) > 4 else None
n = p * c + f
rows = [l.split()[1] for l in sys.stdin if l.startswith("G ")]
if not rows:
    sys.exit("no G lines in the input (UNSAT, timeout, or not an aut.mzn output)")
assert all(len(r) == n for r in rows), f"rows must have length {n}"
G = [int(r[::-1], 2) for r in rows]          # bit q of G[g] = position q+1
ok = True

def rank(vs):
    basis = []
    for v in vs:
        for b in basis:
            v = min(v, v ^ b)
        if v:
            basis.append(v)
    return basis

def report(name, cond):
    global ok
    ok &= cond
    print(f"{name}: {'ok' if cond else 'FAIL'}")

basis = rank(G)
report(f"rank = {len(basis)} (want {n // 2})", len(basis) == n // 2)
report("self-orthogonal", all(bin(a & b).count("1") % 2 == 0 for a in G for b in G))
report("generators doubly-even", all(bin(a).count("1") % 4 == 0 for a in G))

def sigma(v):
    w = v >> (p * c) << (p * c)                # fixed points unchanged
    for l in range(c):
        for i in range(p):
            if v >> (l * p + i) & 1:
                w |= 1 << (l * p + (i + 1) % p)
    return w

def in_span(v):
    for b in basis:
        v = min(v, v ^ b)
    return v == 0

report("sigma-invariant", all(in_span(sigma(g)) for g in G))

if n // 2 <= 26 and n <= 64:
    def table(gs):
        t = np.zeros(1, dtype=np.uint64)
        for g in gs:
            t = np.concatenate([t, t ^ np.uint64(g)])
        return t
    def popcount(x):
        x = x - ((x >> np.uint64(1)) & np.uint64(0x5555555555555555))
        x = (x & np.uint64(0x3333333333333333)) + ((x >> np.uint64(2)) & np.uint64(0x3333333333333333))
        x = (x + (x >> np.uint64(4))) & np.uint64(0x0F0F0F0F0F0F0F0F)
        return (x * np.uint64(0x0101010101010101)) >> np.uint64(56)
    half = len(basis) // 2
    lo, hi = table(basis[:half]), table(basis[half:])
    dist = collections.Counter()
    for w in hi:
        dist.update(collections.Counter(popcount(lo ^ w).tolist()))
    dist[0] -= 1
    dist = {w: m for w, m in sorted(dist.items()) if m}
    dmin = min(dist)
    print(f"weights: {dist}")
    print(f"min distance: {dmin}")
    if d is not None:
        report(f"min distance >= {d}", dmin >= d)
else:
    print(f"n = {n}: weight enumeration skipped (2^{n // 2} words)")
sys.exit(0 if ok else 1)
