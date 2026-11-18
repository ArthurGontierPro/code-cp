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
import sys, os, re, json
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

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
# the variable list is either written inline or, when MiniZinc shares it, as a named array
named = dict(re.findall(r"array \[1\.\.\d+\] of var int: (\w+)[^=]*= \[(.*?)\];", F))
for args in re.findall(r"int_lin_eq\(\w+,(\[.*?\]|\w+),0\)", F):
    args = named[args] if not args.startswith("[") else args[1:-1]
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

# ---- witness: every variable of the .opb must be moved consistently or be fixed by pi
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
import domproof
nrem, left = domproof.merge(
    opb, pbp, out, domproof.def_order("lex3", 3, [4, 2, 1]), f"load_order lex3 ~{c1} ~{c2} ~{c3};",
    [(label[b], witness(c)) for c, b in zip(J["clauses"], want)],
    "symmetry breaking by dominance (scripts/dommerge.py): order x_c1, then x_c2, then x_c3, a 1 first")
print(f"removed {nrem} clauses, {left} constraints left; {len(want)} dom lines; "
      f"witness size {len(witness(J['clauses'][0]).split(' -> ')) - 1} moves")
