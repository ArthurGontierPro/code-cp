#!/usr/bin/env python3
"""phase1.py OUTDIR -- build the phase-1 instance set (notes/benchmark-plan.md §4) on the node.

P1 (minimum distance), every code of rate 1/2:
  - the 7 extended QR codes qr8..qr104. Two questions: UNSAT, a word of weight <= d - 4 (the codes
    are doubly even, so this is the same question as d - 1; Hamming uses d - 1 = 3), and SAT, a word
    of weight <= d. Each with 0 and 3 fixed coordinates (3-homogeneity of PSL(2, p)). Plus the
    optimisation version (minimum weight), without fixed coordinates;
  - the same questions on the orbit of minimum-weight words written as the parity checks (E-ORB),
    for qr24, qr32, qr48, where the orbit is small (759, 620, 17296 rows);
  - 12 random [n, n/2] codes, n = 32, 48, 64, 80, seeds 1..3: UNSAT at d - 1, SAT at d, the
    optimisation version; no fixed coordinates (a random code has no symmetry to justify them).
P3 (existence of an [n, k, d] code):
  - the 8 AAAI-26 triplets measured on 19/11 (all SAT);
  - k = 5..8, d = 8, 12, 16: n = Griesmer - 1 (UNSAT by the Griesmer bound) and n = Griesmer
    (expected unknown: a SAT answer is plausible, an UNSAT one is unverified).
Every P1 answer is recomputed from the checks by verify/verify_p1.py before anything is written;
a mismatch stops the build. Writes OUTDIR/NAME.{json,cnf,...} and OUTDIR/MANIFEST.tsv
(name family kind expected value)."""
import sys, os, json, subprocess

B = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(B, "verify"))
import verify_p1 as V

OUT = sys.argv[1]; os.makedirs(OUT, exist_ok=True)
PY = sys.executable
DIST = {7: 4, 23: 8, 31: 8, 47: 12, 71: 12, 79: 16, 103: 20}
P1_DEC = ["cnf", "xnf", "opb", "lp", "asp", "smt2", "dzn"]
P1_OPT = ["opt-opb", "wcnf", "opt-lp", "opt-asp"]
man = []


def p1(code, w, nfix, name):
    path = f"{OUT}/{name}.json"
    subprocess.run([PY, f"{B}/gen/p1.py", code, str(w), str(nfix), path], check=True, capture_output=True)
    return path, json.load(open(path))


def save(J, path):
    J["name"] = os.path.basename(path)[:-5]
    json.dump(J, open(path, "w"))


def write(path, fmts):
    subprocess.run([PY, f"{B}/writers/write.py", path, path[:-5]] + fmts, check=True, capture_output=True)


def check(path, J, decision=True):
    got = V.decide(J) if decision else "-"
    assert not decision or got == J["expected"], f"{path}: expected {J['expected']}, computed {got}"
    if "expected_opt" in J and not J["fixed"]:
        d = V.distance(J)
        assert d == J["expected_opt"], f"{path}: d expected {J['expected_opt']}, computed {d}"
    print(f"verified {os.path.basename(path)}: {got}" + (f" d={J['expected_opt']}" if "expected_opt" in J else ""), flush=True)


def dec(path, J):
    check(path, J); write(path, P1_DEC)
    man.append((J["name"], "P1", "dec", J["expected"], "-"))


def opt(path, J):
    J["wmax"] = J["expected_opt"]; J["expected"] = "SAT"; save(J, path)   # the opt formats ignore wmax
    check(path, J, decision=False); write(path, P1_OPT)
    man.append((J["name"], "P1", "opt", "OPTIMUM", str(J["expected_opt"])))


# ---- QR codes
for p, d in DIST.items():
    n = p + 1; wu = d - 1 if p == 7 else d - 4
    for f in (0, 3):
        for w in (wu, d):
            dec(*p1(f"qr{p}", w, f, f"qr{n}_w{w}_f{f}"))
    opt(*p1(f"qr{p}", d, 0, f"qr{n}_min"))

# ---- the orbit of minimum-weight words as the checks
for p in (23, 31, 47):
    n, d = p + 1, DIST[p]
    _, J0 = p1(f"qr{p}", d, 0, f"tmp_qr{n}")
    os.remove(f"{OUT}/tmp_qr{n}.json")
    _, _, words = V.low(J0, d // 2, printw=d)
    orb = sorted(w for w in words if bin(w).count("1") == d)
    assert len(V.rref(orb, range(n))[0]) == n // 2, "the orbit does not span the dual"
    print(f"qr{n}: orbit of {len(orb)} words of weight {d}", flush=True)
    for f in (0, 3):
        for w in (d - 4, d):
            J = dict(J0); J["checks"] = [[w_ >> i & 1 for i in range(n)] for w_ in orb]
            J["wmax"] = w; J["fixed"] = list(range(f)); J["expected"] = "SAT" if w >= d else "UNSAT"
            J["source"] += f"; checks = the {len(orb)} codewords of weight {d} (self-dual code)"
            path = f"{OUT}/qr{n}orb_w{w}_f{f}.json"; save(J, path); dec(path, J)

# ---- random codes
for n in (32, 48, 64, 80):
    for s in (1, 2, 3):
        path, J = p1(f"rand{n}s{s}", 0, 0, f"rand{n}s{s}_tmp")
        os.remove(path)
        d = V.distance(J); J["expected_opt"] = d
        for w in (d - 1, d):
            J["wmax"] = w; J["expected"] = "SAT" if w >= d else "UNSAT"
            path = f"{OUT}/rand{n}s{s}_w{w}.json"; save(J, path); dec(path, dict(J))
        path = f"{OUT}/rand{n}s{s}_min.json"; save(J, path); opt(path, dict(J))


# ---- P3
def p3(n, k, d, exp=None, src=None):
    name = f"lin_{n}_{k}_{d}"; path = f"{OUT}/{name}.json"
    subprocess.run([PY, f"{B}/gen/p3.py", str(n), str(k), str(d), path], check=True, capture_output=True)
    J = json.load(open(path))
    if exp:
        J["expected"] = exp; J["source"] += "; " + src; json.dump(J, open(path, "w"))
    subprocess.run(["bash", f"{B}/writers/write_p3.sh", path, path[:-5]], check=True, capture_output=True)
    par = open(f"{OUT}/{name}.mznpar").read().strip()
    open(f"{OUT}/{name}.dzn", "w").write(" ".join(a.replace("=", " = ") + ";" for a in par.split(";") if a) + "\n")
    man.append((name, "P3", "dec", J["expected"], "-"))
    print(f"P3 {name}: {J['expected']}", flush=True)


for n, k, d in [(34, 10, 12), (36, 10, 13), (36, 8, 16), (37, 12, 12), (38, 10, 14), (39, 10, 15), (42, 10, 16), (42, 8, 18)]:
    p3(n, k, d, "SAT", "AAAI-26 benchmark, a code is known (codetables.de); found by Kissat or CMS on 19/11")
for k in (5, 6, 7, 8):
    for d in (8, 12, 16):
        g = sum(-(-d // 2 ** i) for i in range(k))
        p3(g - 1, k, d); p3(g, k, d)

with open(f"{OUT}/MANIFEST.tsv", "w") as f:
    f.write("# name\tfamily\tkind\texpected\tvalue\n")
    for r in man:
        f.write("\t".join(r) + "\n")
print(f"{len(man)} instances in {OUT}/MANIFEST.tsv")
