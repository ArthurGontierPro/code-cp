#!/usr/bin/env python3
"""domlex.py FZN OPB PBP OUT -- the column order of models/linear_dom.mzn derived by dominance.

Input: a run of baguette on linear_dom.mzn with LEX = 1 or 2 (FZN, its OPB and proof PBP).
For each pair of neighbouring columns j, j+1 of A, the model has one inequality "column j <=
column j+1" (LEX = 1) or "<" (LEX = 2), each column read as a binary number with row 1 as the
most significant bit. Output OUT.opb without these inequalities, and OUT.pbp that
  1. defines the order "A read column by column as one binary number, the smaller first",
  2. derives each inequality by a `dom` line under its own label, the witness being the swap of
     columns j and j+1: A[i, j] <-> A[i, j+1], X[s, j] <-> X[s, j+1], and the same for the
     integers bool2int(...) that MiniZinc introduced,
  3. continues with baguette's proof unchanged (scripts/domproof.py).
Nothing here has to be trusted: a wrong witness or a wrong inequality is refused by VeriPB.
"""
import sys, os, re
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import domproof

fzn, opb, pbp, out = sys.argv[1:5]
F = open(fzn).read()
arrays = re.findall(r"array \[1\.\.(\d+)\] of var bool: \w+:: output_array\(\[1\.\.\d+\]\) = \[(.*?)\];", F)
Aflat = [v.strip() for v in arrays[0][1].split(",")]
Xflat = [v.strip() for v in arrays[1][1].split(",")]
# sizes: A is k x m, X is (2^k - 1) x m, both row-major
k = None
for kk in range(1, 20):
    if len(Aflat) % kk == 0 and (2 ** kk - 1) * (len(Aflat) // kk) == len(Xflat):
        k = kk; break
m = len(Aflat) // k
A = [[Aflat[i * m + j] for j in range(m)] for i in range(k)]
X = [[Xflat[s * m + j] for j in range(m)] for s in range(2 ** k - 1)]
b2i = dict(re.findall(r"bool2int\((\w+),(\w+)\)", F))
lit = lambda name: f"{name}_ge_1"

# each variable of column j and its partner in column j+1
def column_vars(j):
    vs = [A[i][j] for i in range(k)] + [X[s][j] for s in range(2 ** k - 1)]
    vs = [v for v in vs if v not in ("true", "false")]
    return vs + [b2i[v] for v in vs if v in b2i]

BAD = os.environ.get("BAD")     # negative test: swap the columns of A only, leave X in place
O, body = domproof.opb_lines(opb)
steps = []
for j in range(m - 1):
    L, R = column_vars(j), column_vars(j + 1)
    if BAD:
        L = [v for v in L if v in sum(A, []) or v in [b2i.get(a) for a in sum(A, [])]]
        R = [v for v in R if v in sum(A, []) or v in [b2i.get(a) for a in sum(A, [])]]
    assert len(L) == len(R)
    pairs = dict.fromkeys(zip(L, R))                     # keeps order, drops repeats (aliases)
    w = " ".join(f"{lit(a)} -> {lit(b)} {lit(b)} -> {lit(a)}" for a, b in pairs if a != b)
    # the inequality of columns j, j+1: the only constraint whose variables are exactly the
    # bool2int integers of A[., j] and A[., j+1]
    target = {b2i.get(A[i][c], A[i][c]) for i in range(k) for c in (j, j + 1)}
    labs = [lab for lab, b in body.items()
            if {v[:-5] for v in domproof.opb_vars([b])} == target]
    assert len(labs) == 1, (j, labs)
    # the order compares the bool2int integers; swapping columns j, j+1 changes the order's sum by
    # fac times the inequality, fac = (2^k - 1) * 2^(N - k(j+2)). Both goals (the image is below,
    # and not above) follow from the negated inequality times F plus the goal's premise (-1). The
    # negated inequality is the subproof's first premise: -2 in goal #1, and -4 in goal #2 because
    # goal #1 used two more IDs (its premise and the pol line), deleted at its qed.
    fac = (2 ** k - 1) * 2 ** (k * m - k * (j + 2))
    sub = ["  proofgoal #1", f"    pol -2 {fac} * -1 +;", "  qed : -1;",
           "  proofgoal #2", f"    pol -4 {fac} * -1 +;", "  qed : -1;"]
    steps.append((labs[0], w, sub))

N = k * m
order_vars = " ".join(lit(b2i[A[i][j]]) for j in range(m) for i in range(k))   # column by column, row 1 first
nrem, left = domproof.merge(
    opb, pbp, out, domproof.def_order("colex", N, [2 ** (N - 1 - p) for p in range(N)]),
    f"load_order colex {order_vars};", steps,
    "column order by dominance (scripts/domlex.py): A read column by column, the smaller first")
print(f"k={k} m={m}: removed {nrem} inequalities, {left} constraints left, {len(steps)} dom lines")
