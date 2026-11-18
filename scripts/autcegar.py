#!/usr/bin/env python3
"""autcegar.py OUT "DSTRING" [SOLVER] -- lazy distance for models/aut.mzn. Runs on the node.

DSTRING is the -D string without nE/E, e.g. "p=7;c=10;f=2;d=16;k=5;K=2;KS=0;LEX=true;".
Each round: solve aut.mzn with the light combinations found so far (OUT.dzn), put the
solution's generator matrix G in systematic form [I | A] (column permutation), list every
codeword of weight < d with mindist (exact, it relies on self-duality, which aut.mzn
enforces), map each light word back to the set of rows of G that sums to it, add those sets
to E, and solve again. Stops on UNSAT / UNKNOWN (no solution) or on a code with no light
word (a genuine code, printed as FOUND). Each added set is a valid constraint for every
true code, so an UNSAT here is as valid as the model's.

Environment: TL = time limit per round in s (default 3600), MINDIST = path of the mindist
binary (default: next to this script, compiled from mindist.c if missing),
MZN = minizinc binary. PIDs of this script and of each solver run go to OUT.pid.
"""
import os, sys, subprocess, re, time

out, dstr = sys.argv[1], sys.argv[2]
solver = sys.argv[3] if len(sys.argv) > 3 else "chuffed"
here = os.path.dirname(os.path.abspath(__file__))
model = os.environ.get("MODEL", os.path.join(here, "..", "models", "aut.mzn"))   # e.g. models/heur/aut_max.mzn
MZN = os.environ.get("MZN", "/scratch/arthur/mzn/MiniZincIDE-2.10.1-x86_64-linux-gnu/bin/minizinc")
TL = int(os.environ.get("TL", "3600"))
mindist = os.environ.get("MINDIST", os.path.join(here, "mindist"))
if not os.path.exists(mindist):
    subprocess.run(["gcc", "-O2", "-fopenmp", "-o", mindist, os.path.join(here, "mindist.c")], check=True)
par = dict(kv.split("=") for kv in dstr.replace(" ", "").split(";") if kv)
p, c, f, d = (int(par[x]) for x in "pcfd")
n = p * c + f
m = n // 2
k = int(par["k"])
h = (c + f) // 2
deg = next(t for t in range(1, p) if pow(2, t, p) == 1)          # dim of K1 over F2
T = (p - 1) // deg
GROUPS = [range(1, k + 1)] + ([range(k + 1, c + 1)] if T == 2 else [])   # E1 rows, E2 rows
IMG = os.environ.get("IMG", "")        # "1": also add the images of each light set (see images())


def images(S):
    """Images of a light generator set S (1-based rows of G) under the transpositions of E rows
    within E1 and within E2. Swapping E1 rows a, b together with info cycles a, b (or E2 rows,
    i.e. columns of M, with their cycles) maps a model solution to another one, and S's light word
    to the corresponding light word there; so the image excludes that symmetric solution in
    advance. Any generator set gives a valid constraint for every true code, so this is sound
    whatever the symmetry does to the C0 rows (left unchanged here)."""
    out = set()
    for grp in GROUPS:
        for a in grp:
            for b in grp:
                if a >= b:
                    continue
                def sw(g):
                    if g <= h:
                        return g
                    e, t = (g - h - 1) // deg + 1, (g - h - 1) % deg
                    e = b if e == a else a if e == b else e
                    return h + (e - 1) * deg + t + 1
                out.add(tuple(sorted(sw(g) for g in S)))
    return out
with open(f"{out}.pid", "a") as fh:
    fh.write(f"{os.getpid()}\n")


def systematic(G):
    """Row-reduce the m x n matrix G (rows as ints). Returns (piv, rows, U): pivot columns,
    reduced rows (rows[i] has a 1 in piv[i] and 0 in the other pivots), and U[i] = set of
    original row indices whose sum is rows[i]."""
    rows, U, piv = list(G), [{i} for i in range(len(G))], []
    r = 0
    for col in range(n):
        s = next((i for i in range(r, len(rows)) if rows[i] >> col & 1), None)
        if s is None:
            continue
        rows[r], rows[s], U[r], U[s] = rows[s], rows[r], U[s], U[r]
        for i in range(len(rows)):
            if i != r and rows[i] >> col & 1:
                rows[i] ^= rows[r]; U[i] = U[i] ^ U[r]
        piv.append(col); r += 1
    assert r == m, f"rank {r} != {m}"
    return piv, rows, U


E = []
if os.environ.get("RESUME") and os.path.exists(f"{out}.dzn"):   # restart from the last round's E
    txt = open(f"{out}.dzn").read()
    E = [sorted(int(x) for x in grp.split(",") if x.strip()) for grp in re.findall(r"\{([^}]*)\}", txt)]
    print(f"resumed with |E| = {len(E)}", flush=True)
t0 = time.time()
for rnd in range(1, 100000):
    with open(f"{out}.dzn", "w") as fh:
        fh.write(f"nE = {len(E)};\nE = [" + ",".join("{" + ",".join(map(str, e)) + "}" for e in E) + "];\n")
    proc = subprocess.Popen([MZN, "--solver", solver, "-D", dstr, model, f"{out}.dzn",
                             "--time-limit", str(TL * 1000)], stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    with open(f"{out}.pid", "a") as fh:
        fh.write(f"{proc.pid}\n")
    txt = proc.communicate()[0]
    rows = [l.split()[1] for l in txt.splitlines() if l.startswith("G ")]
    if not rows:
        st = "UNSAT" if "UNSATISFIABLE" in txt else "UNKNOWN"
        print(f"round {rnd}: no solution ({st}), |E| = {len(E)}, {time.time()-t0:.0f} s", flush=True)
        break
    G = [int(r[::-1], 2) for r in rows]            # bit q = position q+1
    piv, R, U = systematic(G)
    rest = [q for q in range(n) if q not in piv]
    # A[i][j] = bit rest[j] of reduced row i: G_sys = [I | A] in the column order piv + rest
    bits = "".join("1" if R[i] >> rest[j] & 1 else "0" for i in range(m) for j in range(m))
    res = subprocess.run([mindist, str(m), str(d)], input=bits, capture_output=True, text=True).stdout.splitlines()
    new = set()
    for line in res:
        if not line.startswith("light"):
            continue
        S = [int(x) - 1 for x in line.split()[1:]]
        # mindist prints the identity bits of the side it enumerated: rows S of [I|A]
        # (side 0) or of [A^T|I] (side 1). Rebuild both candidates and keep the light ones.
        w0 = 0
        for i in S:
            w0 ^= R[i]
        left1 = [sum(1 for i in S if R[a] >> rest[i] & 1) % 2 for a in range(m)]
        w1 = 0
        for a in range(m):
            if left1[a]:
                w1 ^= R[a]                             # the word whose G_sys coefficients are left1
        for w in (w0, w1):
            if 0 < bin(w).count("1") < d:
                coef = [a for a in range(m) if w >> piv[a] & 1]
                orig = set()
                for a in coef:
                    orig ^= U[a]
                chk = 0
                for g in orig:
                    chk ^= G[g]
                assert chk == w
                new.add(tuple(sorted(g + 1 for g in orig)))
    if IMG and new:
        new |= set().union(*(images(S) for S in new))
    Eset = set(map(tuple, E))
    new = [e for e in sorted(new) if tuple(e) not in Eset]
    print(f"round {rnd}: {res[-1] if res else '?'}, {len(new)} new light sets, |E| {len(E)} -> {len(E)+len(new)}, "
          f"{time.time()-t0:.0f} s", flush=True)
    if not new:
        print("FOUND", flush=True)
        print("\n".join("G " + r for r in rows), flush=True)
        break
    E += new
