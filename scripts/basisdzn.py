#!/usr/bin/env python3
"""basisdzn.py IN.dzn OUT.dzn -- keep, from the rows W of a minweight_sym instance, a greedy set of
linearly independent rows over GF(2) (a basis of the code spanned by the minimum-weight words)."""
import sys, re
s = open(sys.argv[1]).read()
rows = [[int(b) for b in r.split(",")] for r in re.search(r"W = \[\|(.*?)\|\];", s, re.S).group(1).split("|")]
basis, keep = {}, []
for r in rows:
    v = sum(b << j for j, b in enumerate(r)); v0 = v
    while v:
        h = v.bit_length() - 1
        if h not in basis:
            basis[h] = v; keep.append(r); break
        v ^= basis[h]
s = re.sub(r"nW = \d+;", f"nW = {len(keep)};", s)
s = re.sub(r"W = \[\|.*?\|\];", "W = [|" + "|".join(",".join(map(str, r)) for r in keep) + "|];", s, flags=re.S)
open(sys.argv[2], "w").write(s)
print(f"{len(rows)} rows -> {len(keep)} independent rows")
