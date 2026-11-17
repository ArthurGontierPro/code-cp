#!/usr/bin/env python3
"""gen_instances.py OUTDIR -- build the fixed codes and lattices of RESULTS.md block B.

Writes, for each object, a .dzn for the matching model and checks on the way that the
object is what we claim (self-duality, doubly-even, unimodularity conditions).

  codes (models/minweight.mzn):  golay24, qr48, qr80   binary extended QR codes [p+1,(p+1)/2]
  lattices (models/shortvec.mzn): leech  = 2B(Golay) U (2B(Golay) + (-3,1^23))      norm w.w/8
                                  p48p   = B3(Pless symmetry code q=23), doubled      norm w.w/12
                                  p48q   = B3(ternary extended QR code p=47), doubled norm w.w/12

Lattice convention (both): w = 2*y + b*T, y = u*G + p*z (so y = a codeword mod p), sum(y) = 0 mod Q,
b in {0,1}. Leech: p=2, Q=4, T=(-3,1^23), D=8 (SPLAG ch.4 §11, Construction B then the translate).
P48: p=3, Q=2, T = (-5u_1, u_2..u_48) for a full-weight codeword u in {+-1}^48, D=12
(SPLAG ch.5 §5.7: Construction B3 then density doubling by (-5/2, 1/2^47)).
Why that T works for any full-weight u: 2T mod 3 = u is a codeword and sum(T) is even, so 2T is in
B3; T.T/12 = (25+47)/12 = 6 is even; and T.y/6 is an integer for every y in B3 (u.c = 0 mod 3 by
self-duality, sum(y) even). So the doubled lattice is even, integral, of determinant 4/4 = 1.
Extremality is NOT implied: it is what the solver checks (no norm 2 or 4).
"""
import sys, os, itertools, random

def qr_sets(p):
    Q = sorted({(i * i) % p for i in range(1, p)})
    N = sorted(set(range(1, p)) - set(Q))
    return Q, N

def rank_mod(rows, p):
    """row echelon over F_p; returns (rank, reduced rows, pivot cols)"""
    M = [r[:] for r in rows]; piv = []; r = 0
    ncol = len(M[0])
    for c in range(ncol):
        s = next((i for i in range(r, len(M)) if M[i][c] % p), None)
        if s is None: continue
        M[r], M[s] = M[s], M[r]
        inv = pow(M[r][c], p - 2, p)
        M[r] = [(x * inv) % p for x in M[r]]
        for i in range(len(M)):
            if i != r and M[i][c] % p:
                f = M[i][c]; M[i] = [(a - f * b) % p for a, b in zip(M[i], M[r])]
        piv.append(c); r += 1
        if r == len(M): break
    return r, M[:r], piv

def polymul_mod(a, b, n, p):
    out = [0] * n
    for i, x in enumerate(a):
        if x:
            for j, y in enumerate(b):
                if y: out[(i + j) % n] = (out[(i + j) % n] + x * y) % p
    return out

def circulant(e, n):
    return [[e[(j - i) % n] for j in range(n)] for i in range(n)]

def extended_qr(p, q):
    """extended QR code over F_q (q = 2 or 3) of length p+1, dimension (p+1)/2, self-dual."""
    Q, N = qr_sets(p)
    sQ = [1 if i in Q else 0 for i in range(p)]; sN = [1 if i in N else 0 for i in range(p)]
    for a, b, c in itertools.product(range(q), repeat=3):
        e = [(a * (i == 0) + b * sQ[i] + c * sN[i]) % q for i in range(p)]
        if not any(e) or polymul_mod(e, e, p, q) != e: continue
        rk, R, _ = rank_mod(circulant(e, p), q)
        if rk != (p + 1) // 2: continue
        for g in range(1, q):  # extension coordinate = g * sum
            G = [r + [(g * sum(r)) % q] for r in R]
            if all(sum(x * y for x, y in zip(r1, r2)) % q == 0 for r1 in G for r2 in G):
                return G
    raise SystemExit(f"no self-dual extended QR found p={p} q={q}")

def pless(qq=23):
    """Pless symmetry code over F3 of length 2qq+2: [I | C], C the bordered Paley matrix."""
    Q, _ = qr_sets(qq)
    chi = lambda x: 0 if x % qq == 0 else (1 if x % qq in Q else -1)
    n = qq + 1
    C = [[0] * n for _ in range(n)]
    for j in range(1, n): C[0][j] = 1
    for i in range(1, n):
        C[i][0] = chi(-1)
        for j in range(1, n): C[i][j] = chi((j - 1) - (i - 1))
    G = [[int(i == j) for j in range(n)] + [x % 3 for x in C[i]] for i in range(n)]
    assert all(sum(x * y for x, y in zip(r1, r2)) % 3 == 0 for r1 in G for r2 in G), "Pless not self-dual"
    return G

def systematic(G, p):
    """[I|A] after a column permutation; returns (A, perm)"""
    k = len(G); rk, R, piv = rank_mod(G, p); assert rk == k
    rest = [c for c in range(len(G[0])) if c not in piv]
    perm = piv + rest
    R2 = [[r[c] for c in perm] for r in R]
    assert all(R2[i][j] == int(i == j) for i in range(k) for j in range(k))
    return [r[k:] for r in R2], perm

def span_contains(G, v, p):
    return rank_mod(G + [v], p)[0] == rank_mod(G, p)[0]

def full_weight_word(G, p, rng):
    n = len(G[0])
    for x in range(1, p):          # all-ones, or all-ones with a different extension symbol
        v = [1] * (n - 1) + [x]
        if span_contains(G, v, p): return v
    for _ in range(200000):
        u = [rng.randrange(p) for _ in G]
        w = [sum(u[i] * G[i][j] for i in range(len(G))) % p for j in range(len(G[0]))]
        if all(w): return w
    raise SystemExit("no full-weight word")

def dzn_array2(name, M):
    return f"{name} = [|" + "|".join(", ".join(map(str, r)) for r in M) + "|];\n"

def main(out):
    os.makedirs(out, exist_ok=True)
    rng = random.Random(1)
    # --- binary codes
    codes = {}
    for name, p in [("golay24", 23), ("qr48", 47), ("qr72", 71), ("qr80", 79), ("qr104", 103)]:
        G = extended_qr(p, 2)
        assert all(sum(r) % 4 == 0 for r in G), f"{name} not doubly-even"
        A, _ = systematic(G, 2); codes[name] = G
        k = len(A)
        with open(f"{out}/{name}.dzn", "w") as f:
            f.write(f"k = {k};\nm = {len(A[0])};\n" + dzn_array2("A", A))
        with open(f"{out}/{name}.bits", "w") as f:   # for scripts/mindist.c
            f.write("".join(str(x) for r in A for x in r) + "\n")
        print(f"{name}: [{2*k},{k}] doubly-even self-dual, systematic form written")
    # --- lattices
    def lat(name, G, p, Q, T, D):
        k, N = len(G), len(G[0])
        with open(f"{out}/{name}.dzn", "w") as f:
            f.write(f"N = {N};\nk = {k};\np = {p};\nQ = {Q};\nD = {D};\n"
                    f"T = {T};\n" + dzn_array2("G", G))
        print(f"{name}: N={N} p={p} T.T/D={sum(t*t for t in T)/D}")
    lat("leech", codes["golay24"], 2, 4, [-3] + [1] * 23, 8)
    assert span_contains(codes["golay24"], [1] * 24, 2)
    for name, G in [("p48p", pless(23)), ("p48q", extended_qr(47, 3))]:
        u = full_weight_word(G, 3, rng)
        s = [1 if x == 1 else -1 for x in u]
        T = [-5 * s[0]] + s[1:]
        assert span_contains(G, [t % 3 for t in T], 3) and sum(T) % 2 == 0
        lat(name, G, 3, 2, T, 12)

if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else "instances")
