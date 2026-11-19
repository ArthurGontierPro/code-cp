#!/usr/bin/env python3
"""qr2sym.py instances/qrN.dzn WMAX NFIX OUT.dzn -- a minweight_chk / gencnf instance whose parity
checks are the k rows of the generator G = [I | A] (the code is self-dual, so x is a codeword iff
G·x = 0). No enumeration of codewords, so it works for QR72, QR80, QR104. NFIX coordinates (1, 2, 3)
are imposed in the support by the same clauses x_c ∨ ¬x_b as scripts/symcode.py (valid because
PSL(2, p) is 3-homogeneous)."""
import sys, re
src, Wmax, nfix, out = sys.argv[1], int(sys.argv[2]), int(sys.argv[3]), sys.argv[4]
s = open(src).read()
k = int(re.search(r"\bk = (\d+);", s).group(1)); m = int(re.search(r"\bm = (\d+);", s).group(1))
A = [[int(b) for b in r.split(",")] for r in re.search(r"A = \[\|(.*?)\|\];", s, re.S).group(1).split("|") if r.strip()]
n = k + m
W = [[int(j == i) for j in range(k)] + A[i] for i in range(k)]
FA, FB = [], []
for t in range(nfix):
    for b in range(t + 1, n):
        FA.append(t + 1); FB.append(b + 1)
with open(out, "w") as f:
    f.write(f"n = {n}; nW = {k}; Wmax = {Wmax}; wd = {Wmax};\n")
    f.write("W = [|" + "|".join(",".join(map(str, r)) for r in W) + "|];\n")
    f.write(f"nF = {len(FA)};\nFA = {FA};\nFB = {FB};\n")
print(f"{out}: n={n}, {k} generator rows, Wmax={Wmax}, {len(FA)} fixing clauses")
