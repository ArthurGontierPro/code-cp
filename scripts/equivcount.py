#!/usr/bin/env python3
"""equivcount.py TASK [P] -- equivalence tests by enumeration (runs on the node).

A model shortcut (two halves, FIRST/SECOND/THIRD cubes, a b-split, a domain bound) is an
axiom of the .opb file, and VeriPB cannot see it. This script tests every shortcut on an
instance where the answer is SAT and the exact number of solutions is known from the weight
enumerator or the theta series. It enumerates all solutions (Chuffed, -a), maps each one to
the original coordinates, and checks:
  - the full model gives exactly the known number of words / vectors, all distinct;
  - each split gives disjoint cases whose union is the parent set (cubes), or a covering
    whose union is the parent set (halves).
TASK: golay | qr48 | leech | p48p | p48q.   P: parallel jobs (default 120).
Writes results/equiv/TASK.txt.
"""
import os, sys, re, subprocess, time, itertools
from concurrent.futures import ThreadPoolExecutor

B = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(B, "scripts"))
MZN = os.environ.get("MZN", "/scratch/arthur/mzn/MiniZincIDE-2.10.1-x86_64-linux-gnu/bin/minizinc")
task = sys.argv[1]
P = int(sys.argv[2]) if len(sys.argv) > 2 else 120
os.makedirs(f"{B}/results/equiv", exist_ok=True)
log = open(f"{B}/results/equiv/{task}.txt", "a")
FAIL = []


def say(s):
    print(s, flush=True); log.write(s + "\n"); log.flush()


def check(ok, what):
    say(("ok   " if ok else "FAIL ") + what)
    if not ok:
        FAIL.append(what)


def load_dzn(path):
    txt = open(path).read()
    d = {}
    for name, body in re.findall(r"(\w+)\s*=\s*\[\|(.*?)\|\]", txt, re.S):
        d[name] = [[int(x) for x in r.split(",")] for r in body.split("|") if r.strip()]
    for name, body in re.findall(r"(\w+)\s*=\s*\[([^|\]]*)\]", txt):
        d[name] = [int(x) for x in body.split(",")]
    for name, v in re.findall(r"(\w+)\s*=\s*(-?\d+)\s*;", txt):
        d[name] = int(v)
    return d


def enum(model, inst, par, key, decode):
    """All solutions. Returns (complete, raw count, set of decoded solutions)."""
    t0 = time.time()
    proc = subprocess.Popen([MZN, "--solver", "chuffed", "-a", "-D", par, f"{B}/models/{model}",
                             f"{B}/instances/{inst}"], stdout=subprocess.PIPE,
                            stderr=subprocess.STDOUT, text=True, bufsize=1 << 20)
    raw, S, done = 0, set(), False
    for line in proc.stdout:
        if line.startswith(key):
            S.add(decode(line[len(key):].strip().strip("[];")))
            raw += 1
        elif line.startswith("=========="):
            done = True
        elif "=====UNSATISFIABLE=====" in line:
            done = True
    proc.wait()
    return done, raw, S, time.time() - t0


# ------------------------------------------------------------------------------ codes
def code_task(name, Wmax, half, expected):
    A = load_dzn(f"{B}/instances/{name}.dzn")["A"]
    k = len(A)
    rowA = [sum(A[i][j] << j for j in range(k)) for i in range(k)]          # u·A as an int
    AT = [[A[j][i] for j in range(k)] for i in range(k)]
    rowAT = [sum(AT[i][j] << j for j in range(k)) for i in range(k)]

    def dec(side):
        def f(s):
            u = [x.strip() == "true" for x in s.split(",")]
            ui = sum(1 << i for i in range(k) if u[i])
            c = 0
            for i in range(k):
                if u[i]:
                    c ^= (rowA if side == "L" else rowAT)[i]
            # original coordinates: (u, uA) on the L side, (u'A^T, u') on the T side
            return ui | (c << k) if side == "L" else c | (ui << k)
        return f

    inst = {"L": f"{name}.dzn", "R": f"{name}_T.dzn"}

    def run(side, H, F, S2, T3):
        par = f"Wmax={Wmax};HALF={H};FIRST={F};SECOND={S2};THIRD={T3};"
        return (side, F, S2, T3), enum("minweight.mzn", inst[side], par, "u = ", dec(side))

    full = run("L", k, 0, 0, 0)[1]
    check(full[0] and full[1] == len(full[2]) == expected,
          f"{name} full model: {full[1]} solutions, {len(full[2])} distinct, expected {expected} ({full[3]:.0f} s)")
    jobs = []
    for side in "LR":
        jobs.append((side, half, 0, 0, 0))
        for i in range(1, k + 1):
            jobs += [(side, half, i, 0, 0), (side, half, i, -1, 0)]
            for j in range(i + 1, k + 1):
                jobs += [(side, half, i, j, 0), (side, half, i, j, -1)]
                jobs += [(side, half, i, j, l) for l in range(j + 1, k + 1)]
    with ThreadPoolExecutor(P) as ex:
        R = dict(ex.map(lambda a: run(*a), jobs))
    check(all(r[0] for r in R.values()), f"{name}: all {len(R)} split runs complete")
    check(all(r[1] == len(r[2]) for r in R.values()), f"{name}: no duplicate inside any run")
    sol = {key: r[2] for key, r in R.items()}
    for side in "LR":
        root = sol[(side, 0, 0, 0)]
        say(f"{name} half {side} (HALF={half}): {len(root)} words")
        ok1 = ok2 = ok3 = True
        kids = [sol[(side, i, 0, 0)] for i in range(1, k + 1)]
        ok1 = sum(map(len, kids)) == len(root) and set().union(*kids) == root
        for i in range(1, k + 1):
            kids = [sol[(side, i, -1, 0)]] + [sol[(side, i, j, 0)] for j in range(i + 1, k + 1)]
            ok2 &= sum(map(len, kids)) == len(sol[(side, i, 0, 0)]) and set().union(*kids) == sol[(side, i, 0, 0)]
            for j in range(i + 1, k + 1):
                kids = [sol[(side, i, j, -1)]] + [sol[(side, i, j, l)] for l in range(j + 1, k + 1)]
                ok3 &= sum(map(len, kids)) == len(sol[(side, i, j, 0)]) and set().union(*kids) == sol[(side, i, j, 0)]
        check(ok1, f"{name} {side}: the {k} FIRST cases partition the half")
        check(ok2, f"{name} {side}: each FIRST case = (alone) + its SECOND cases, disjoint")
        check(ok3, f"{name} {side}: each SECOND case = (no 3rd row) + its THIRD cases, disjoint")
    U = sol[("L", 0, 0, 0)] | sol[("R", 0, 0, 0)]
    check(U == full[2], f"{name}: half L ∪ half R = full model ({len(U)} words)")


# ------------------------------------------------------------------------------ lattices
def lat_task(name, M, half, expected, parts):
    base = load_dzn(f"{B}/instances/{name}.dzn")
    N, k = base["N"], base["k"]
    maps = {name: list(range(N))}
    if os.path.exists(f"{B}/instances/{name}_L.dzn"):
        import gen_instances as gi
        G = gi.pless(23) if name == "p48p" else gi.extended_qr(47, 3)
        _, perm = gi.systematic(G, 3)
        maps[name + "_L"] = perm                                         # w_L[i] = orig[perm[i]]
        maps[name + "_R"] = [perm[(i + k) % N] for i in range(N)]
        for v in ("_L", "_R"):
            Tv = load_dzn(f"{B}/instances/{name}{v}.dzn")["T"]
            check(all(Tv[i] == base["T"][maps[name + v][i]] for i in range(N)),
                  f"{name}{v}: coordinate map reproduces the permuted T")

    def dec(inst):
        mp = maps[inst]

        def f(s):
            w = [0] * N
            for i, x in enumerate(s.split(",")):
                w[mp[i]] = int(x)
            return bytes(x & 255 for x in w)
        return f

    def run(inst, bfix, H):
        par = f"M={M};BFIX={bfix};HALF={H};"
        return enum("shortvec.mzn", f"{inst}.dzn", par, "w = ", dec(inst))

    jobs = {"full": (name, -1, k), "b0": (name, 0, k), "b1": (name, 1, k)}
    if half:
        jobs["b0L"] = (name + "_L", 0, half)
        jobs["b0R"] = (name + "_R", 0, half)
    with ThreadPoolExecutor(len(jobs)) as ex:
        fut = {key: ex.submit(run, *a) for key, a in jobs.items()}
        R = {key: f.result() for key, f in fut.items()}
    for key, r in R.items():
        say(f"{name} {key}: complete={r[0]} raw={r[1]} distinct={len(r[2])} ({r[3]:.0f} s)")
    full = R["full"][2]
    check(R["full"][0] and len(full) == R["full"][1] == expected,
          f"{name} full model, norm ≤ {M}: {len(full)} vectors, expected {expected}")
    check(R["b0"][2] | R["b1"][2] == full and not (R["b0"][2] & R["b1"][2]),
          f"{name}: b=0 ⊔ b=1 = full ({len(R['b0'][2])} + {len(R['b1'][2])})")
    if parts:
        check((len(R["b0"][2]), len(R["b1"][2])) == parts, f"{name}: (b=0, b=1) counts = {parts}")
    if half:
        U = R["b0L"][2] | R["b0R"][2]
        check(U == R["b0"][2], f"{name}: b=0 left (HALF={half}) ∪ b=0 right = b=0 ({len(R['b0L'][2])}, "
              f"{len(R['b0R'][2])}, union {len(U)})")


say(f"=== {task} {time.strftime('%Y-%m-%d %H:%M')}")
if task == "golay":
    code_task("golay24", 8, 4, 759)
elif task == "qr48":
    code_task("qr48", 12, 6, 17296)
elif task == "leech":
    # shapes of the 196560: (±4,±4,0^22) 1104 and (±2^8,0^16) 97152 have b = 0, (∓3,±1^23) 98304 b = 1
    lat_task("leech", 4, 0, 196560, (1104 + 97152, 98304))
elif task in ("p48p", "p48q"):
    # norm ≤ 6 with b = 0: w = 2y, y·y ≤ 18, the codeword has ≤ 18 nonzero coordinates, ≤ 9 on one half
    lat_task(task, 6, 9, 52416000, None)
say(f"=== {task}: {'ALL OK' if not FAIL else str(len(FAIL)) + ' FAILURES'}")
