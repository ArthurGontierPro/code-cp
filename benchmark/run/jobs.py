#!/usr/bin/env python3
"""jobs.py INSTDIR > JOBS.tsv -- every (instance, encoding, solver) run of phase 1, one per line.

Columns: id, expected, value, env (or .), solver, input, extra argument after the time limit (or .;
"-" is a real argument, the MiniZinc wrappers' "model without ENC").
Which solver reads which file is the table of benchmark/README.md. Choices of phase 1:
  - YalSAT (local search) only where the answer is not UNSAT, since it can never prove UNSAT;
  - the MiniZinc solvers on both parity encodings of minweight_chk.mzn (ENC 1 = XOR chains,
    ENC 2 = sums) for P1, on models/linear.mzn for P3;
  - no proof logging (PROOF unset everywhere)."""
import sys, os

D = os.path.abspath(sys.argv[1]); MZ = "/scratch/arthur/codes-cp/models"
MZN = ["chuffed", "gecode", "cpsat", "highs-mzn", "gcs", "baguette", "pumpkin", "huub"]
out = []
for line in open(f"{D}/MANIFEST.tsv"):
    if line.startswith("#"):
        continue
    name, fam, kind, exp, val = line.rstrip("\n").split("\t")
    f = lambda ext: f"{D}/{name}{ext}"
    J = []                                            # (tag, env, solver, input, extra)
    if fam == "P1" and kind == "dec":
        J += [("cnf", ".", s, f(".cnf"), ".") for s in ("kissat", "cadical", "cryptominisat")]
        if exp != "UNSAT":
            J += [("cnf", ".", "yalsat", f(".cnf"), ".")]
        J += [("xnf", ".", "cryptominisat", f(".xnf"), ".")]
        J += [("opb", ".", s, f(".opb"), ".") for s in ("roundingsat", "exact")]
        J += [("lp", ".", s, f(".lp"), ".") for s in ("highs", "scip", "gurobi")]
        J += [("asp", ".", "clingo", f(".asp"), ".")]
        J += [("smt2", ".", s, f(".smt2"), ".") for s in ("z3", "cvc5")]
        J += [(f"enc{e}", ".", s, f(".dzn"), str(e)) for s in MZN for e in (1, 2)]
        J += [("trellis", ".", "trellis-dp", f(".json"), ".")]
    elif fam == "P1" and kind == "opt":
        J += [("opb", ".", s, f("_opt.opb"), ".") for s in ("roundingsat", "exact")]
        J += [("wcnf", ".", s, f(".wcnf"), ".") for s in ("uwrmaxsat", "evalmaxsat")]
        J += [("lp", ".", s, f("_opt.lp"), ".") for s in ("highs", "scip", "gurobi")]
        J += [("asp", ".", "clingo", f("_opt.asp"), ".")]
        J += [("trellis", ".", "trellis-dp", f(".json"), "opt")]
    elif fam == "P3":
        for ext, tag in ((".cnf", "aaai"), (".cnf-nosb", "aaainosb")):
            J += [(tag, ".", s, f(ext), ".") for s in ("kissat", "cadical", "cryptominisat")]
        if exp != "UNSAT":
            J += [("aaai", ".", "yalsat", f(".cnf"), ".")]
        J += [("lin", f"MODEL={MZ}/linear.mzn", s, f(".dzn"), "-") for s in MZN]   # "-": linear.mzn has no ENC
    for tag, env, s, inp, extra in J:
        out.append("\t".join((f"{name}__{tag}__{s}", exp, val, env, s, inp, extra)))
print("\n".join(out))
print(f"{len(out)} jobs", file=sys.stderr)
