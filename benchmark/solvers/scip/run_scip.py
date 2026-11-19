"""run_scip.py FILE.lp TIMELIMIT_S -- solve with SCIP (pyscipopt) and print the RESULT line.

Mode (env MODE=opt|dec, default from the file name: '_opt.' in the name means opt): in dec mode
the objective is zeroed, so SCIP stops at the first feasible point and answers SAT/UNSAT.
"""
import os, sys, time
t0 = time.time()
from pyscipopt import Model
path, tl = sys.argv[1], float(sys.argv[2])
mode = os.environ.get("MODE") or ("opt" if "_opt." in os.path.basename(path) else "dec")
st, val = "ERROR", "-"
try:
    m = Model()
    m.readProblem(path)
    if mode == "dec":
        m.setObjective(0, clear=True)
    m.setParam("limits/time", max(1.0, tl - (time.time() - t0)))
    m.setParam("display/verblevel", int(os.environ.get("VERB", "4")))
    m.optimize()
    s, nsol = m.getStatus(), m.getNSols()
    print(f"scip status: {s}, solutions: {nsol}", flush=True)
    if s == "optimal":
        st = "OPTIMUM" if mode == "opt" else "SAT"
    elif s == "infeasible":
        st = "UNSAT"
    elif nsol > 0:
        st = "SAT"
    elif s in ("timelimit", "userinterrupt", "memlimit", "nodelimit", "gaplimit"):
        st = "UNKNOWN"
    if st in ("OPTIMUM", "SAT") and mode == "opt":
        o = m.getObjVal()
        val = str(int(round(o))) if abs(o - round(o)) < 1e-6 else repr(o)
except Exception as e:
    print("error:", e, flush=True)
print(f"RESULT status={st} value={val} time={time.time() - t0:.3f}", flush=True)
