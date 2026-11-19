#!/usr/bin/env python3
"""score.py OUTDIR [TL] -- the tables of a campaign from its .res files.

A run is solved when its status matches the expected answer (OPTIMUM with the expected value).
It is WRONG when it contradicts it: SAT on UNSAT, UNSAT on SAT, OPTIMUM with another value, or, on
an instance whose answer is unknown, SAT and UNSAT from two different runs (both are flagged).
PAR-2: the time of a solved run, 2 * TL otherwise (wrong runs included). Prints, per family and
per (solver, encoding): runs, solved, wrong, PAR-2 in hours, then every wrong run in full."""
import sys, glob, collections

OUT = sys.argv[1]; TL = float(sys.argv[2]) if len(sys.argv) > 2 else 600.0
R = [l.split() for f in sorted(glob.glob(f"{OUT}/*.res")) for l in open(f)]
by_inst = collections.defaultdict(set)
for id_, s, exp, val, st, gv, t, rss in R:
    if exp == "unknown" and st in ("SAT", "UNSAT"):
        by_inst[id_.split("__")[0]].add(st)
T = collections.defaultdict(lambda: [0, 0, 0, 0.0]); wrong = []
for id_, s, exp, val, st, gv, t, rss in R:
    inst, tag, _ = id_.split("__")
    fam = "P3" if inst.startswith("lin_") else "P1"
    if exp == "unknown":
        ok, bad = st in ("SAT", "UNSAT"), len(by_inst[inst]) > 1
    elif exp == "OPTIMUM":
        ok, bad = st == "OPTIMUM" and gv == val, st == "OPTIMUM" and gv != val
    else:
        ok, bad = st == exp, st in ("SAT", "UNSAT") and st != exp
    row = T[(fam, s, tag)]
    row[0] += 1; row[1] += ok and not bad; row[2] += bad
    row[3] += float(t) if ok and not bad else 2 * TL
    if bad:
        wrong.append(" ".join((id_, s, exp, val, st, gv, t)))
print(f"{len(R)} runs\n\n{'family':6} {'solver':14} {'encoding':10} {'runs':>5} {'solved':>6} {'wrong':>5} {'PAR-2 h':>8}")
for (fam, s, tag), (n, ok, bad, par) in sorted(T.items(), key=lambda kv: (kv[0][0], kv[1][3] / kv[1][0])):
    print(f"{fam:6} {s:14} {tag:10} {n:5} {ok:6} {bad:5} {par / 3600:8.2f}")
print("\nwrong runs:" if wrong else "\nno wrong run")
for w in wrong:
    print("  " + w)
