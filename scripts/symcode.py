#!/usr/bin/env python3
"""symcode.py P WMAX NFIX -- instance of models/minweight_sym.mzn and its dominance witnesses.

The extended QR code of length P+1 (P = 7: Hamming [8,4,4], P = 23: Golay) is written by a
model that is SYMMETRIC by construction: the word x is orthogonal to every minimum-weight
codeword w (sum over w of x = 2 y_w, one auxiliary y_w per w). An automorphism pi of the code
sends the constraint of w to the constraint of pi(w), so a dominance witness can map x_i to
x_pi(i) and y_w to y_pi(w), which is a plain list of variables.

The model imposes coordinates c1, c2, c3 in the support of the word, as the clauses
    x_c ∨ ¬x_b        (b not yet fixed)
and each clause is justified by one dominance step whose witness pi satisfies pi(c) = b, fixes
c1 when c = c2, and maps {c1, c2} onto itself when c = c3. PSL(2, P) acts on the P+1
coordinates and is 3-homogeneous when P = 3 mod 4, which makes these witnesses exist.

Writes dom/sym_pP_wWMAX.dzn and .json (the clauses in model order and their witnesses).
Coordinates are 0..P-1 then infinity = P; the model numbers them 1..P+1.
"""
import sys, os, json, itertools
B = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(B, "scripts"))
import gen_instances as gi

p, Wmax, nfix = int(sys.argv[1]), int(sys.argv[2]), int(sys.argv[3])
n = p + 1
G = gi.extended_qr(p, 2)
k = len(G)
# codewords as bit masks (bit j = coordinate j), enumerated in Gray-code order
rows = [sum(r[j] << j for j in range(n)) for r in G]
d, words, c = n, [], 0
for t in range(1, 1 << k):
    c ^= rows[(t & -t).bit_length() - 1]
    w = bin(c).count("1")
    if w < d:
        d, words = w, [c]
    elif w == d:
        words.append(c)
words = sorted(words)
basis = {}                                        # GF(2) echelon basis of the code, by top bit
for r in rows:
    while r:
        h = r.bit_length() - 1
        if h not in basis:
            basis[h] = r; break
        r ^= basis[h]
def in_code(v):
    while v:
        h = v.bit_length() - 1
        if h not in basis:
            return False
        v ^= basis[h]
    return True
def apply(pi, v):                                 # the word whose coordinate j is v's coordinate pi[j]
    return sum(((v >> pi[j]) & 1) << j for j in range(n))

INF = p
def mob(f):            # f on F_p ∪ {inf} -> permutation of 0..n-1
    return tuple(f(x) for x in range(n))
inv = lambda x: pow(x, p - 2, p)
sq = sorted({x * x % p for x in range(1, p)})
cands = [mob(lambda x: INF if x == INF else (x + 1) % p)]
cands += [mob(lambda x, r=r: INF if x == INF else r * x % p) for r in sq]
cands += [mob(lambda x, e=e: 0 if x == INF else INF if x == 0 else e * inv(x) % p) for e in (1, p - 1)]
is_aut = lambda pi: all(in_code(apply(pi, r)) for r in rows)
gens = [g for g in cands if is_aut(g)]
group = {tuple(range(n))}
frontier = list(group)
while frontier:
    new = []
    for a in frontier:
        for g in gens:
            c = tuple(a[g[j]] for j in range(n))
            if c not in group:
                group.add(c); new.append(c)
    frontier = new
assert len(group) == p * (p * p - 1) // 2, len(group)
assert all(is_aut(g) for g in itertools.islice(group, 200))

# witness semantics (VeriPB): x_j -> x_pi(j) means the new value of x_j is the old value of x_pi(j)
fixed = [0, 1, 2][:nfix]
group_sorted = sorted(group)
clauses = []                       # (c, b, pi), 0-based
for t, c in enumerate(fixed):
    for b in range(n):
        if b in fixed[:t + 1]:
            continue
        def ok(g):
            if g[c] != b:
                return False
            if t == 1:                                   # keep c1 where it is
                return g[fixed[0]] == fixed[0]
            if t == 2:                                   # keep {c1, c2} as a set
                return {g[fixed[0]], g[fixed[1]]} == set(fixed[:2])
            return True
        g = next((g for g in group_sorted if ok(g)), None)
        assert g is not None, (c, b)
        clauses.append((c, b, g))

widx = {w: i for i, w in enumerate(words)}
inverse = lambda g: [g.index(j) for j in range(n)]
bits = lambda w: [(w >> j) & 1 for j in range(n)]
out = os.path.join(B, "dom", f"sym_p{p}_w{Wmax}" + ("" if nfix == 3 else f"_f{nfix}"))
with open(out + ".dzn", "w") as f:
    f.write(f"n = {n}; nW = {len(words)}; Wmax = {Wmax}; wd = {d};\n")
    f.write("W = [|" + "|".join(",".join(map(str, bits(w))) for w in words) + "|];\n")
    f.write(f"nF = {len(clauses)};\n")
    f.write(f"FA = {[c + 1 for c, b, g in clauses]};\nFB = {[b + 1 for c, b, g in clauses]};\n")
json.dump({"n": n, "words": [bits(w) for w in words], "fixed": fixed,
           "clauses": [{"c": c, "b": b, "pi": list(g),
                        "wpi": [widx[apply(inverse(g), w)] for w in words]}
                       for c, b, g in clauses]}, open(out + ".json", "w"))
print(f"p={p} n={n} d={d} words={len(words)} |PSL|={len(group)} clauses={len(clauses)} -> {out}.dzn")
