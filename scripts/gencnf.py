#!/usr/bin/env python3
"""gencnf.py IN.dzn OUT.cnf MODE -- a minweight_sym / minweight_chk instance as DIMACS for SAT solvers.

Variables 1..n are the bits x of the word. Each row w of W says that x·w is even:
  MODE xor : one native XOR line of CryptoMiniSat ("x-a b c ... 0", the negated first literal makes
             the XOR false), which its Gaussian elimination can use;
  MODE cnf : the same chain as models/minweight_chk.mzn with ENC = 1 (acc_t = acc_{t-1} xor x, four
             clauses each, acc_last false), i.e. the clauses baguette receives.
The weight bounds are one clause (sum x >= 1) and a totalizer for sum x <= Wmax (pysat), and the
fixed-coordinate clauses x_a ∨ ¬x_b are copied. Needs pysat (node venv)."""
import sys, re
from pysat.card import CardEnc, EncType

src, out, mode = sys.argv[1:4]
s = open(src).read()
n = int(re.search(r"\bn = (\d+);", s).group(1)); Wmax = int(re.search(r"Wmax = (\d+);", s).group(1))
W = [[int(b) for b in r.split(",")] for r in re.search(r"W = \[\|(.*?)\|\];", s, re.S).group(1).split("|")]
FA = [int(v) for v in re.findall(r"\d+", re.search(r"FA = \[(.*?)\];", s).group(1))]
FB = [int(v) for v in re.findall(r"\d+", re.search(r"FB = \[(.*?)\];", s).group(1))]
top = n; lines = []
for w in W:
    sup = [i + 1 for i in range(n) if w[i]]
    if mode == "xor":
        lines.append("x" + " ".join([str(-sup[0])] + [str(v) for v in sup[1:]]) + " 0")
    else:
        acc = sup[0]
        for v in sup[1:]:
            top += 1; z = top                                     # z = acc xor v
            lines += [f"{-z} {acc} {v} 0", f"{-z} {-acc} {-v} 0", f"{z} {-acc} {v} 0", f"{z} {acc} {-v} 0"]
            acc = z
        lines.append(f"{-acc} 0")
lines.append(" ".join(str(i) for i in range(1, n + 1)) + " 0")
card = CardEnc.atmost(lits=list(range(1, n + 1)), bound=Wmax, top_id=top, encoding=EncType.totalizer)
top = max(top, card.nv)
lines += [" ".join(map(str, c)) + " 0" for c in card.clauses]
lines += [f"{a} {-b} 0" for a, b in zip(FA, FB)]
open(out, "w").write(f"p cnf {top} {len(lines)}\n" + "\n".join(lines) + "\n")
print(f"{out}: {top} variables, {len(lines)} lines ({len(W)} parity rows as {mode})")
