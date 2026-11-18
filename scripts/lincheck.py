"""HISTORIQUE (16/11) : première journée, ancien dossier /scratch/arthur/golay du nœud, modèle code.mzn ou golay.mzn. Gardé pour reproduire STATUS.md (16/11).

lincheck.py k n < solver output -> minimum distance and T (number of words of that
weight) of the code [I_k | A], by enumerating the 2^k words (k <= 20)."""
import re, sys, collections
k, n = int(sys.argv[1]), int(sys.argv[2]); m = n - k
mt = re.search(r'\[((?:\s*(?:true|false),)+\s*(?:true|false))\]', sys.stdin.read())
if not mt: sys.exit("no A")
b = [v.strip() == "true" for v in mt.group(1).split(",")]
rows = [(1 << i) | sum(1 << (k + j) for j in range(m) if b[m*i + j]) for i in range(k)]
spec = collections.Counter()
w = [0]
for r in rows: w = w + [x ^ r for x in w]
for x in w[1:]: spec[bin(x).count("1")] += 1
dmin = min(spec); print(f"d={dmin} T={spec[dmin]}")
