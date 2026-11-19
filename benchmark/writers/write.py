#!/usr/bin/env python3
"""write.py CANON.json OUTPREFIX FORMAT... -- write a P1 instance in each requested format.

FORMAT: cnf xnf opb wcnf lp asp smt2 dzn countcnf, plus the variants opt-opb, opt-lp, opt-asp
(minimise the weight instead of bounding it; the weight bound is then dropped). See
benchmark/README.md for what each format contains. cnf/xnf/wcnf/countcnf need pysat.
Variables: x_1..x_n are the bits of the word (1-based in every format)."""
import sys, json, math

I = json.load(open(sys.argv[1])); pre = sys.argv[2]; fmts = sys.argv[3:]
n, H, w = I["n"], I["checks"], I["wmax"]
rows = [[i + 1 for i in range(n) if h[i]] for h in H]
fix = [(a + 1, b + 1) for t, a in enumerate(I["fixed"]) for b in range(t + 1, n) if b not in I["fixed"][:t + 1]]
X = list(range(1, n + 1))


def xor_clauses(top):
    """Tseitin chains: acc = x_a, acc' = acc xor x, four clauses each, last acc false"""
    cls = []
    for r in rows:
        acc = r[0]
        for v in r[1:]:
            top += 1; z = top
            cls += [[-z, acc, v], [-z, -acc, -v], [z, -acc, v], [z, acc, -v]]
            acc = z
        cls.append([-acc])
    return cls, top


def card(kind, top, bound):
    from pysat.card import CardEnc, EncType
    f = {"atmost": CardEnc.atmost, "equals": CardEnc.equals}[kind]
    e = f(lits=X, bound=bound, top_id=top, encoding=EncType.totalizer)
    return e.clauses, max(top, e.nv)


def dimacs(path, cls, top, xors=(), extra=""):
    with open(path, "w") as f:
        f.write(f"p cnf {top} {len(cls) + len(xors)}\n{extra}")
        for x in xors:
            f.write("x" + " ".join(map(str, x)) + " 0\n")
        for c in cls:
            f.write(" ".join(map(str, c)) + " 0\n")


def base_clauses():
    return [X[:]] + [[a, -b] for a, b in fix]


for fmt in fmts:
    path = f"{pre}.{fmt.replace('opt-', '')}" if not fmt.startswith("opt-") else f"{pre}_opt.{fmt[4:]}"
    if fmt == "countcnf":
        path = f"{pre}_count.cnf"
    if fmt == "cnf":
        cls, top = xor_clauses(n); c2, top = card("atmost", top, w)
        dimacs(path, cls + c2 + base_clauses(), top)
    elif fmt == "xnf":
        c2, top = card("atmost", n, w)
        dimacs(path, c2 + base_clauses(), top, xors=[[-r[0]] + r[1:] for r in rows])
    elif fmt == "countcnf":
        cw = I["count_weight"]
        cls, top = xor_clauses(n); c2, top = card("equals", top, cw)
        dimacs(path, cls + c2 + [[a, -b] for a, b in fix], top,
               extra="c p show " + " ".join(map(str, X)) + " 0\n")
    elif fmt == "wcnf":
        cls, top = xor_clauses(n)
        with open(path, "w") as f:
            for c in cls + base_clauses():
                f.write("h " + " ".join(map(str, c)) + " 0\n")
            for v in X:
                f.write(f"1 {-v} 0\n")
    elif fmt in ("opb", "opt-opb"):
        top = n; lines = []
        for r in rows:
            half = len(r) // 2; nb = max(1, math.ceil(math.log2(half + 1)))
            ys = list(range(top + 1, top + nb + 1)); top += nb
            lines.append(" ".join(f"+1 x{v}" for v in r) + " " + " ".join(f"-{2 ** (j + 1)} x{y}" for j, y in enumerate(ys)) + " = 0 ;")
            lines.append(" ".join(f"+{2 ** j} x{y}" for j, y in enumerate(ys)) + f" <= {half} ;")
        lines.append(" ".join(f"+1 x{v}" for v in X) + " >= 1 ;")
        if fmt == "opb":
            lines.append(" ".join(f"-1 x{v}" for v in X) + f" >= -{w} ;")
        lines += [f"+1 x{a} -1 x{b} >= 0 ;" for a, b in fix]
        head = f"* #variable= {top} #constraint= {len(lines)}\n"
        if fmt == "opt-opb":
            head += "min: " + " ".join(f"+1 x{v}" for v in X) + " ;\n"
        open(path, "w").write(head + "\n".join(lines) + "\n")
    elif fmt in ("lp", "opt-lp"):
        # decision files have a zero objective (a feasibility problem); only opt-lp minimises the weight
        obj = " + ".join(f"x{v}" for v in X) if fmt == "opt-lp" else "0 x1"
        L = ["Minimize", " obj: " + obj, "Subject To"]
        for t, r in enumerate(rows):
            L.append(f" p{t + 1}: " + " + ".join(f"x{v}" for v in r) + f" - 2 y{t + 1} = 0")
        L.append(" nz: " + " + ".join(f"x{v}" for v in X) + " >= 1")
        if fmt == "lp":
            L.append(" wt: " + " + ".join(f"x{v}" for v in X) + f" <= {w}")
        L += [f" f{t + 1}: x{a} - x{b} >= 0" for t, (a, b) in enumerate(fix)]
        L += ["Bounds"] + [f" 0 <= y{t + 1} <= {len(r) // 2}" for t, r in enumerate(rows)]
        L += ["Binary", " " + " ".join(f"x{v}" for v in X), "General", " " + " ".join(f"y{t + 1}" for t in range(len(rows))), "End"]
        open(path, "w").write("\n".join(L) + "\n")
    elif fmt in ("asp", "opt-asp"):
        L = [f"coord(1..{n}).", "{ x(I) } :- coord(I)."]
        L += [f"chk({t + 1},{v})." for t, r in enumerate(rows) for v in r]
        L += ["row(R) :- chk(R,_).",
              ":- row(R), C = #count{ I : x(I), chk(R,I) }, C \\ 2 = 1.",
              ":- #count{ I : x(I) } = 0."]
        L += [f":- not x({a}), x({b})." for a, b in fix]
        L += [f":- #count{{ I : x(I) }} > {w}."] if fmt == "asp" else ["#minimize{ 1,I : x(I) }."]
        L += ["#show x/1."]
        open(path, "w").write("\n".join(L) + "\n")
    elif fmt == "smt2":
        S = lambda vs: "(+ " + " ".join(f"(ite x{v} 1 0)" for v in vs) + ")"
        L = ["(set-logic QF_LIA)"] + [f"(declare-const x{v} Bool)" for v in X]
        L += [f"(assert (not (xor {' '.join(f'x{v}' for v in r)})))" for r in rows]
        L += [f"(assert (>= {S(X)} 1))", f"(assert (<= {S(X)} {w}))"]
        L += [f"(assert (or x{a} (not x{b})))" for a, b in fix]
        L += ["(check-sat)", "(exit)"]
        open(path, "w").write("\n".join(L) + "\n")
    elif fmt == "dzn":
        wd = max(len(r) for r in rows)
        with open(path, "w") as f:
            f.write(f"n = {n}; nW = {len(H)}; wd = {wd}; Wmax = {w};\n")
            f.write("W = [|" + "|".join(",".join(map(str, h)) for h in H) + "|];\n")
            f.write(f"nF = {len(fix)};\nFA = {[a for a, b in fix]};\nFB = {[b for a, b in fix]};\n")
    else:
        sys.exit(f"unknown format {fmt}")
    print(path)
