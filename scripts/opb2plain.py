#!/usr/bin/env python3
"""opb2plain.py IN.opb OUT.opb -- baguette's .opb as plain OPB for other PB solvers (RoundingSat):
constraint labels (@cN) removed, variables renamed x1..xN (order of first appearance).
The constraints themselves are unchanged, so every solver reads the same encoding."""
import sys, re
names, out = {}, []
def ren(m):
    v = m.group(2)
    if v not in names:
        names[v] = f"x{len(names) + 1}"
    return m.group(1) + names[v]
body = []
for l in open(sys.argv[1]):
    if l.startswith("*"):
        continue
    l = re.sub(r"^@\S+ ", "", l.strip())
    if l:
        body.append(re.sub(r"(~?)([A-Za-z_]\w*)", ren, l))
open(sys.argv[2], "w").write(f"* #variable= {len(names)} #constraint= {len(body)}\n" + "\n".join(body) + "\n")
