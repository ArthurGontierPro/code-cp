#!/usr/bin/env python3
"""best.py OUTDIR [TL] -- the best solver per model type, from a campaign's .res files.

Model type = the instance group (QR systematic, QR orbit, random code, P3 AAAI, P3 Griesmer) crossed
with the question (UNSAT, SAT, opt) and the encoding the solver read. For each (group, encoding) the
solvers are ranked by solved runs, then PAR-2; prints the best and the runner-up, then for each group
the best (solver, encoding) overall."""
import sys, glob, re, collections
OUT = sys.argv[1]; TL = float(sys.argv[2]) if len(sys.argv) > 2 else 600.0
AAAI = {"lin_34_10_12", "lin_36_10_13", "lin_36_8_16", "lin_37_12_12", "lin_38_10_14", "lin_39_10_15", "lin_42_10_16", "lin_42_8_18"}
def group(inst, exp):
    q = {"UNSAT": "UNSAT", "SAT": "SAT", "OPTIMUM": "opt", "unknown": "?"}[exp]
    if inst.startswith("lin_"):
        return ("P3 AAAI" if inst in AAAI else "P3 Griesmer") + " " + q
    if "orb" in inst: g = "QR orbit"
    elif inst.startswith("rand"): g = "random"
    else: g = "QR systematic"
    return f"{g} {q}"
S = collections.defaultdict(lambda: [0, 0, 0.0])
for f in glob.glob(f"{OUT}/*.res"):
    id_, s, exp, val, st, gv, t, rss = open(f).read().split()
    inst, tag, _ = id_.split("__")
    ok = (st == "OPTIMUM" and gv == val) if exp == "OPTIMUM" else (st in ("SAT", "UNSAT") if exp == "unknown" else st == exp)
    r = S[(group(inst, exp), tag, s)]; r[0] += 1; r[1] += ok; r[2] += float(t) if ok else 2 * TL
groups = sorted({k[0] for k in S}, key=lambda g: (g.startswith("P3"), g))
rank = lambda kv: (-kv[1][1], kv[1][2])
fmt = lambda k, v: f"{k[2]} {v[1]}/{v[0]} {v[2] / 3600:.2f} h"
for g in groups:
    print(f"\n## {g}")
    tags = sorted({k[1] for k in S if k[0] == g})
    rows = []
    for tag in tags:
        L = sorted(((k, v) for k, v in S.items() if k[0] == g and k[1] == tag), key=rank)
        rows.append((rank(L[0]), tag, fmt(*L[0]), fmt(*L[1]) if len(L) > 1 else "-"))
    for _, tag, a, b in sorted(rows):
        print(f"  {tag:9} best {a:32} next {b}")
