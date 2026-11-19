#!/usr/bin/env python3
"""learnedlp.py FZN PBP -- classify the PB constraints baguette learned on models/minweight_sym.mzn.

Each learned constraint (an `ia` line of the proof) is tested with a linear program: is it implied,
over the reals, by
  A. the parity equations of the words whose integers y_w it mentions (plus 0 <= x <= 1 and the
     ladder [y >= k+1] <= [y >= k] <= 1 of each y_w)?  Then it is a nonnegative combination of those
     equations and adds no information from the search;
  B. the same plus the model's other constraints on x (1 <= sum x <= Wmax, the clauses x_c ∨ ¬x_b)?
  C. all 17296 parity equations together, plus B (one LP over every word, only for rows not in A, B)?
If none of these, the row is not a linear consequence of the model at all: it needed rounding
(division / saturation), which cutting planes have and clauses do not.
Prints counts per class and per number of y_w. Needs scipy (node venv: /scratch/arthur/tools/venv).
"""
import re, sys, collections
import numpy as np
from scipy.optimize import linprog

fzn, pbp = sys.argv[1:3]
F = open(fzn).read()
xs = [v.strip() for v in re.search(r"array \[1\.\.\d+\] of var bool: x:: output_array\(\[1\.\.\d+\]\) = \[(.*?)\];", F).group(1).split(",")]
n = len(xs)
b2i = dict(re.findall(r"bool2int\((\w+),(\w+)\)", F))
xidx = {}
for i, v in enumerate(xs):
    xidx[v] = i; xidx[b2i[v]] = i
named = dict(re.findall(r"array \[1\.\.\d+\] of var int: (\w+)[^=]*= \[(.*?)\];", F))
word = {}                                                    # y name -> list of coordinates
for args in re.findall(r"int_lin_eq\(\w+,(\[.*?\]|\w+),0\)", F):
    args = named[args] if not args.startswith("[") else args[1:-1]
    vs = [a.strip() for a in args.split(",")]
    ys = [v for v in vs if v not in xidx]
    word[ys[0]] = [xidx[v] for v in vs if v in xidx]
fixc = [(xidx[a], xidx[b]) for a, b in re.findall(r"bool_clause\(\[(\w+)\],\[(\w+)\]\)", F)]
le = re.findall(r"int_lin_le\((\w+),(\[.*?\]|\w+),(-?\d+)\)", F)
Wmax = max(int(c) for _, _, c in le)                          # sum x <= Wmax (the other row is -sum x <= -1)


def implied(terms, deg, ys, extra):
    """min of sum c*lit over the LP; terms: (coef, negated, var, k or None)"""
    yl = sorted(ys)
    K = 4
    nv = n + len(yl) * K
    col = lambda y, k: n + yl.index(y) * K + (k - 1)
    c = np.zeros(nv); const = 0.0
    for coef, neg, v, k in terms:
        j = xidx[v] if v in xidx else col(v, k)
        if neg:
            const += coef; c[j] -= coef
        else:
            c[j] += coef
    Aeq, beq, Aub, bub = [], [], [], []
    for y in yl:                                             # sum_w x - 2 sum_k [y>=k] = 0
        r = np.zeros(nv)
        for i in word[y]:
            r[i] = 1
        for k in range(1, K + 1):
            r[col(y, k)] = -2
        Aeq.append(r); beq.append(0)
        for k in range(1, K):                                # ladder
            r = np.zeros(nv); r[col(y, k + 1)] = 1; r[col(y, k)] = -1
            Aub.append(r); bub.append(0)
    if extra:
        r = np.zeros(nv); r[:n] = 1; Aub.append(r); bub.append(Wmax)
        r = np.zeros(nv); r[:n] = -1; Aub.append(r); bub.append(-1)
        for a, b in fixc:                                    # x_a ∨ ¬x_b  :  x_b - x_a <= 0
            r = np.zeros(nv); r[b] = 1; r[a] = -1; Aub.append(r); bub.append(0)
    res = linprog(c, A_ub=np.array(Aub) if Aub else None, b_ub=bub or None,
                  A_eq=np.array(Aeq) if Aeq else None, b_eq=beq or None, bounds=[(0, 1)] * nv, method="highs")
    if res.status == 2:                                      # infeasible: implies anything
        return True
    return res.fun + const >= deg - 1e-7


from scipy.sparse import lil_matrix, csr_matrix
allY = sorted(word)
def full_lp():
    """the LP of every parity equation, ladders, weight bounds and fixed coordinates (built once)"""
    K = 4; nv = n + len(allY) * K
    col = {y: n + t * K for t, y in enumerate(allY)}
    Aeq = lil_matrix((len(allY), nv)); Aub = lil_matrix((len(allY) * (K - 1) + 2 + len(fixc), nv))
    for t, y in enumerate(allY):
        for i in word[y]:
            Aeq[t, i] = 1
        for k in range(K):
            Aeq[t, col[y] + k] = -2
        for k in range(K - 1):
            Aub[t * (K - 1) + k, col[y] + k + 1] = 1; Aub[t * (K - 1) + k, col[y] + k] = -1
    r0 = len(allY) * (K - 1)
    for i in range(n):
        Aub[r0, i] = 1; Aub[r0 + 1, i] = -1
    bub = [0] * r0 + [Wmax, -1]
    for j, (a, b) in enumerate(fixc):
        Aub[r0 + 2 + j, b] = 1; Aub[r0 + 2 + j, a] = -1; bub.append(0)
    return csr_matrix(Aeq), np.zeros(len(allY)), csr_matrix(Aub), np.array(bub), col, nv
FULL = None
def implied_all(terms, deg):
    global FULL
    if FULL is None:
        FULL = full_lp()
    Aeq, beq, Aub, bub, col, nv = FULL
    c = np.zeros(nv); const = 0.0
    for coef, neg, v, k in terms:
        j = xidx[v] if v in xidx else col[v] + k - 1
        if neg:
            const += coef; c[j] -= coef
        else:
            c[j] += coef
    res = linprog(c, A_ub=Aub, b_ub=bub, A_eq=Aeq, b_eq=beq, bounds=(0, 1), method="highs")
    return res.status == 2 or res.fun + const >= deg - 1e-7

C = collections.Counter()
for line in open(pbp):
    m = re.match(r"@c\d+ ia (.*?)>= (\d+)", line)
    if not m:
        continue
    terms = [(int(c), neg == "~", v, int(k)) for c, neg, v, k in re.findall(r"\+(\d+) (~?)(\w+?_)_ge_(\d+)", m.group(1))]
    ys = {v for _, _, v, _ in terms if v not in xidx}
    ny = len(ys) if len(ys) < 4 else "4+"
    if implied(terms, int(m.group(2)), ys, False):
        C[(ny, "A: sum of its own parity equations")] += 1
    elif implied(terms, int(m.group(2)), ys, True):
        C[(ny, "B: + weight bounds and fixed coordinates")] += 1
    elif implied_all(terms, int(m.group(2))):
        C[(ny, "C: linear consequence of all the parity equations")] += 1
    else:
        C[(ny, "D: not a linear consequence of the model (rounding was used)")] += 1
tot = sum(C.values())
print(f"{tot} learned PB rows")
for cls in ("A", "B", "C", "D"):
    s = sum(v for k, v in C.items() if k[1].startswith(cls))
    print(f"  {cls}: {s}  " + "  ".join(f"[{k[0]} y: {v}]" for k, v in sorted(C.items(), key=lambda t: str(t[0][0])) if k[1].startswith(cls)))
