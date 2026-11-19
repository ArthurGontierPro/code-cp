#!/usr/bin/env python3
"""verify_p1.py CANON.json... -- recompute the answer of each P1 instance from its parity checks alone.

It does not trust the generator: it takes the "checks" rows H as given (systematic form, or any
spanning set such as the orbit of minimum-weight words), computes a generator of the code as the
null space of H, and finds two disjoint information sets S and its complement (this needs n = 2k,
true for every P1 code here). mindist2 then enumerates every combination of <= t rows of the two
systematic generators, which reaches every codeword of weight <= 2t + 1 (a word that light has <= t
ones on S or off S).
  - decision (wmax): t = wmax // 2. SAT iff some word of weight <= wmax contains every fixed
    coordinate;
  - minimum distance (expected_opt): t grows until the lightest word found has weight <= 2t + 1.
Prints one line per file: "ok", or "MISMATCH" (exit status 1), or "filled" when the file had no
expected answer (a random code) and --fill was given, in which case the answer is written back.
Needs mindist2, compiled on /scratch: gcc -O3 -march=native -fopenmp -o /scratch/arthur/codes-cp-work/bin/mindist2
benchmark/verify/mindist2.c (MINDIST2 env overrides the path)."""
import sys, os, json, random, subprocess

HERE = os.path.dirname(os.path.abspath(__file__))
BIN = os.environ.get("MINDIST2", "/scratch/arthur/codes-cp-work/bin/mindist2")   # compiled on /scratch


def rref(rows, order):
    rows = list(rows); piv = []; r = 0
    for c in order:
        b = 1 << c
        j = next((i for i in range(r, len(rows)) if rows[i] & b), None)
        if j is None:
            continue
        rows[r], rows[j] = rows[j], rows[r]
        for i in range(len(rows)):
            if i != r and rows[i] & b:
                rows[i] ^= rows[r]
        piv.append(c); r += 1
    return rows[:r], piv


def nullspace(H, n):
    R, piv = rref(H, range(n))
    free = [c for c in range(n) if c not in piv]
    G = []
    for f in free:
        v = 1 << f
        for row, c in zip(R, piv):
            if row >> f & 1:
                v |= 1 << c
        G.append(v)
    assert all(bin(h & g).count("1") % 2 == 0 for h in H for g in G)
    return G


def two_generators(G, n):
    """G1 identity on an information set S, G2 identity on its complement (same code)"""
    k = len(G)
    orders = [list(range(n)), list(range(n))[::-1]]
    rng = random.Random(0)
    for _ in range(500):
        o = list(range(n)); rng.shuffle(o); orders.append(o)
    for o in orders:
        G1, S = rref(G, o)
        T = [c for c in range(n) if c not in S]
        G2, S2 = rref(G, T)
        if len(S) == k and len(S2) == k:
            for g, P in ((G1, S), (G2, S2)):
                for i, row in enumerate(g):          # identity on its own information set
                    assert all((row >> c & 1) == (i == j) for j, c in enumerate(P))
            return G1, G2
    raise SystemExit("no pair of disjoint information sets found")


def low(J, t, printw=-1):
    n, H = J["n"], [sum(b << i for i, b in enumerate(r)) for r in J["checks"]]
    assert n <= 128
    G = nullspace(H, n)
    assert 2 * len(G) == n, f"n = {n} but dim = {len(G)}: verify_p1 needs a rate-1/2 code"
    G1, G2 = two_generators(G, n)
    fix = sum(1 << c for c in J["fixed"])
    inp = "".join(f"{r & (2**64 - 1):x} {r >> 64:x}\n" for r in G1 + G2)
    out = subprocess.run([BIN, str(n), str(len(G)), str(t), f"{fix & (2**64 - 1):x}", f"{fix >> 64:x}", str(printw)],
                         input=inp, capture_output=True, text=True, check=True).stdout
    mw = mf = None; words = set()
    for line in out.splitlines():
        a = line.split()
        if a[0] == "minw": mw = int(a[1])
        elif a[0] == "minw_fixed": mf = int(a[1])
        elif a[0] == "word": words.add((int(a[1], 16) << 64) | int(a[2], 16))
    return mw, mf, words


def decide(J):
    w = J["wmax"]
    if w <= 0:
        return "UNSAT"
    _, mf, _ = low(J, w // 2)
    return "SAT" if mf <= w else "UNSAT"


def distance(J, fixed=False):
    t = 1
    while True:
        mw, mf, _ = low(J, t)
        v = mf if fixed else mw
        if v <= 2 * t + 1:
            return v
        t += 1


if __name__ == "__main__":
    fill = "--fill" in sys.argv
    bad = 0
    for f in [a for a in sys.argv[1:] if a != "--fill"]:
        J = json.load(open(f))
        got = decide(J)
        exp = J.get("expected")
        msg = []
        if exp is None and fill:
            J["expected"] = got; msg.append(f"filled expected={got}")
        elif exp != got:
            bad += 1; msg.append(f"MISMATCH expected={exp} computed={got}")
        else:
            msg.append(f"ok {got}")
        if "expected_opt" in J or fill:
            d = distance(J)
            if J.get("expected_opt") is None and fill:
                J["expected_opt"] = d; msg.append(f"filled d={d}")
            elif J["expected_opt"] != d:
                bad += 1; msg.append(f"MISMATCH d expected={J['expected_opt']} computed={d}")
            else:
                msg.append(f"d={d}")
        if fill:
            json.dump(J, open(f, "w"))
        print(f"{os.path.basename(f)}: n={J['n']} wmax={J['wmax']} fixed={len(J['fixed'])} " + " ".join(msg), flush=True)
    sys.exit(1 if bad else 0)
