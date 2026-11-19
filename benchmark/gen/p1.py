#!/usr/bin/env python3
"""p1.py CODE WMAX NFIX OUT.json [--count W] -- canonical instance of family P1 (minimum distance).

CODE: qrP for the extended binary QR code of length P+1 (P = 7, 23, 31, 47, 71, 79, 103; qr23 is
Golay), built by scripts/gen_instances.py; or randNsS for a random [N, N/2] code, G = [I | A] with A
drawn from seed S until it is invertible (so the coordinates off I are an information set too, which
verify/verify_p1.py needs). A random code has no known distance: its JSON has no "expected", and
gen/phase1.py fills it in from verify/mindist2. The code is put in systematic form G = [I | A] (after a
column permutation) and the parity checks are H = [A^T | I], so x is a codeword iff H x = 0; this
holds for any code, self-dual or not. NFIX coordinates (0, 1, 2) are imposed in the support, which
PSL(2, P) allows (3-homogeneous for P = 3 mod 4). The expected answer comes from the known distance.
--count W: instead, count the codewords of weight exactly W (expected value from enumeration for
small codes)."""
import sys, os, json, itertools, random
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "scripts"))
import gen_instances as gi

DIST = {7: 4, 23: 8, 31: 8, 47: 12, 71: 12, 79: 16, 103: 20}
code, wmax, nfix, out = sys.argv[1], int(sys.argv[2]), int(sys.argv[3]), sys.argv[4]
count = int(sys.argv[6]) if len(sys.argv) > 6 and sys.argv[5] == "--count" else None
if code.startswith("rand"):
    nn, seed = map(int, code[4:].split("s")); k = nn // 2
    rng = random.Random(seed)
    while True:
        A = [[rng.randint(0, 1) for _ in range(k)] for _ in range(k)]
        if gi.rank_mod([r[:] for r in A], 2)[0] == k:
            break
    d, src = None, f"random [{nn},{k}] code, seed {seed}, distance from verify/mindist2"
else:
    p = int(code[2:])
    G = gi.extended_qr(p, 2)
    A, perm = gi.systematic(G, 2)
    d, src = DIST[p], f"extended binary QR code, p = {p}, d = {DIST[p]}"
k = len(A); m = len(A[0]); n = k + m
H = [[A[i][j] for i in range(k)] + [int(t == j) for t in range(m)] for j in range(m)]
inst = {"family": "P1", "name": os.path.basename(out)[:-5], "field": 2, "n": n, "k": k, "checks": H,
        "wmax": wmax, "fixed": list(range(nfix)), "source": src}
if count is None and d is not None:
    inst["expected"] = "SAT" if wmax >= d else "UNSAT"
    inst["expected_opt"] = d
else:
    inst["count_weight"] = count
    rows = [sum(b << j for j, b in enumerate([int(i == r) for i in range(k)] + A[r])) for r in range(k)]
    c, cnt = 0, 0
    if k <= 26:
        for t in range(1, 1 << k):
            c ^= rows[(t & -t).bit_length() - 1]
            cnt += bin(c).count("1") == count and all((c >> f) & 1 for f in range(nfix))
        inst["expected_count"] = cnt
json.dump(inst, open(out, "w"))
print(f"{out}: n={n} k={k} checks={m} wmax={wmax} fixed={nfix} " + (f"expected={inst.get('expected')}" if count is None else f"count(w={count})={inst.get('expected_count')}"))
