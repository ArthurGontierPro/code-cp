#!/usr/bin/env python3
"""dommerge.py FZN OPB PBP JSON OUT -- turn baguette's symmetry AXIOMS into DOMINANCE steps.

Input: a run of baguette on models/minweight_sym.mzn (FZN, its OPB and its proof PBP), and
the witnesses written by scripts/symcode.py (JSON).
Output: OUT.opb, the same model WITHOUT the clauses x_c ∨ ¬x_b that impose coordinates in the
support, and OUT.pbp, a single proof that
  1. defines the order "x_c1, then x_c2, then x_c3, a 1 before a 0" (def_order lex3),
  2. re-derives every removed clause by a `dom` line carrying the SAME label (@cN) as in the
     original .opb, the witness being the automorphism pi written variable by variable,
  3. unloads the order and continues with baguette's proof unchanged.
Baguette's proof refers to constraints only by their labels, so nothing is renumbered.
VeriPB on (OUT.opb, OUT.pbp) then checks the whole chain: the symmetry breaking and the UNSAT.
"""
import sys, re, json

fzn, opb, pbp, js, out = sys.argv[1:6]
J = json.load(open(js))
n = J["n"]
F = open(fzn).read()

# ---- model variables -> FlatZinc names
xs = re.search(r"array \[1\.\.\d+\] of var bool: x:: output_array\(\[1\.\.\d+\]\) = \[(.*?)\];", F).group(1)
xs = [v.strip() for v in xs.split(",")]
assert len(xs) == n
b2i = dict(re.findall(r"bool2int\((\w+),(\w+)\)", F))          # bool name -> int name
bvar = [b2i[v] for v in xs]                                     # bool2int(x[i]) per coordinate
coord_of_b = {b: i for i, b in enumerate(bvar)}
words = [tuple(w) for w in J["words"]]
widx = {w: i for i, w in enumerate(words)}
yvar = [None] * len(words)
for args in re.findall(r"int_lin_eq\(\w+,\[(.*?)\],0\)", F):
    vs = [v.strip() for v in args.split(",")]
    sup = [coord_of_b[v] for v in vs if v in coord_of_b]
    rest = [v for v in vs if v not in coord_of_b]
    assert len(rest) == 1, args
    w = tuple(int(i in sup) for i in range(n))
    yvar[widx[w]] = rest[0]
assert all(yvar), "a word has no parity constraint"

# ---- the .opb: its variables, and the clauses to remove
O = open(opb).read().splitlines()
lines = [l for l in O if l.startswith("@c")]
opbvars = set(re.findall(r"~?([A-Za-z_]\w*)", " ".join(l.split(" ", 1)[1] for l in lines)))
lit = lambda name, v: f"{name}_ge_{v}"
VALS = {}                                         # name -> the values v of its literals name_ge_v in the .opb
for name, v in re.findall(r"([A-Za-z_]\w*?)_ge_(\d+)\b", " ".join(lines)):
    VALS.setdefault(name, set()).add(int(v))
vals = lambda name: sorted(VALS.get(name, ()))

want = [f"+1 {lit(xs[c['c']], 1)} +1 ~{lit(xs[c['b']], 1)} >= 1 ;" for c in J["clauses"]]
label = {}
for l in lines:
    lab, body = l.split(" ", 1)
    if body in want:
        label[body] = lab
assert len(label) == len(want), f"found {len(label)} of {len(want)} symmetry clauses in the .opb"
removed = {label[b] for b in want}
keep = [l for l in O if not (l.startswith("@c") and l.split(" ", 1)[0] in removed)]
keep = [re.sub(r"#constraint= \d+", f"#constraint= {len(lines) - len(removed)}", l) for l in keep]
open(out + ".opb", "w").write("\n".join(keep) + "\n")

# ---- witness: every variable of the .opb must be moved consistently or be fixed by pi
import os
BAD = os.environ.get("BAD")          # negative test: the transposition (c b), not an automorphism (BAD=all, or BAD=k for the k-th dom line only)
def witness(c):
    pi, wpi = c["pi"], c["wpi"]
    if BAD and (BAD == "all" or J["clauses"].index(c) + 1 == int(BAD)):
        pi = list(range(n)); pi[c["c"]], pi[c["b"]] = c["b"], c["c"]; wpi = list(range(len(words)))
    m = {}
    for i in range(n):
        m[lit(xs[i], 1)] = lit(xs[pi[i]], 1)
        for v in vals(bvar[i]):
            m[lit(bvar[i], v)] = lit(bvar[pi[i]], v)
    for w in range(len(words)):
        for v in vals(yvar[w]):
            m[lit(yvar[w], v)] = lit(yvar[wpi[w]], v)
    unmapped = opbvars - set(m)
    assert not unmapped, f"variables the witness does not know: {sorted(unmapped)[:5]}"
    return " ".join(f"{a} -> {b}" for a, b in m.items() if a != b)

c1, c2, c3 = (lit(xs[c], 1) for c in J["fixed"])
P = open(pbp).read().splitlines()
assert P[1].startswith("f "), P[1]
head = [P[0], f"f {len(lines) - len(removed)} ;",
        "% ---- symmetry breaking by dominance (scripts/dommerge.py) ----",
        "% order: compare x_c1, then x_c2, then x_c3; an assignment with a 1 comes first",
        "def_order lex3", "  vars", "    left u1 u2 u3;", "    right v1 v2 v3;", "    aux;", "  end;",
        "  def", "    -4 u1 -2 u2 -1 u3 4 v1 2 v2 1 v3 >= 0;", "  end;",
        "  transitivity", "    vars", "      fresh_right w1 w2 w3;", "    end;", "    proof",
        "      proofgoal #1", "        pol 1 2 + 3 +;", "      qed : -1;", "    qed;", "  end;", "end;",
        f"load_order lex3 ~{c1} ~{c2} ~{c3};"]
for c, body in zip(J["clauses"], want):
    head.append(f"{label[body]} dom {body.rstrip(' ;')} : {witness(c)} ;")
head += ["load_order;", "% ---- baguette's proof, unchanged ----"]
open(out + ".pbp", "w").write("\n".join(head + P[2:]) + "\n")
print(f"removed {len(removed)} clauses, {len(lines) - len(removed)} constraints left; "
      f"{len(want)} dom lines; witness size {len(witness(J['clauses'][0]).split(' -> ')) - 1} moves")
