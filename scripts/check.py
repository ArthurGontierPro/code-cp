"""Read a solution for code.mzn / golay.mzn (A as a flat n*n bool array) and report the
weight distribution of the code spanned by [I_n | A] (all 2^n codewords, numpy)."""
import re, sys, collections
import numpy as np
txt = sys.stdin.read()
m = re.search(r'\[((?:\s*(?:true|false),)+\s*(?:true|false))\]', txt)
if not m: sys.exit("no A in output:\n" + txt[-300:])
b = [v.strip() == 'true' for v in m.group(1).split(',')]
n = int(round(len(b) ** 0.5))
rows = [(1 << i) | sum(1 << (n + k) for k in range(n) if b[n*i + k]) for i in range(n)]
w = np.zeros(1, dtype=np.uint64)
for r in rows:
    w = np.concatenate([w, w ^ np.uint64(r)])
pc = np.unpackbits(w.view(np.uint8).reshape(-1, 8), axis=1).sum(1, dtype=np.int64)
dist = collections.Counter(pc[1:].tolist())
print(f"n={n} weights:", dict(sorted(dist.items())), "min distance:", min(dist))
known = {12: {8: 759, 12: 2576, 16: 759, 24: 1},
         24: {12: 17296, 16: 535095, 20: 3995376, 24: 7681680, 28: 3995376, 32: 535095, 36: 17296, 48: 1}}
print("extremal (Golay / q48):", dict(dist) == known.get(n))
