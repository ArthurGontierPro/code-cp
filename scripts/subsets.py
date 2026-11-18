"""HISTORIQUE (16/11) : première journée, ancien dossier /scratch/arthur/golay du nœud, modèle code.mzn ou golay.mzn. Gardé pour reproduire STATUS.md (16/11).

subsets.py N K > s.dzn -- the combinations of 1..K rows (out of N), each built from
its parent (itself minus its highest row) and one row, so code.mzn can share the xors.
Listed by size, so a parent always comes first."""
import sys, itertools
n, K = int(sys.argv[1]), int(sys.argv[2])
idx, par, row, size = {}, [], [], []
for k in range(1, K + 1):
    for c in itertools.combinations(range(1, n + 1), k):
        idx[c] = len(par) + 1
        par.append(idx[c[:-1]] if k > 1 else 0); row.append(c[-1]); size.append(k)
print(f"n = {n};\nnS = {len(par)};")
for name, a in (("sp", par), ("sr", row), ("sz", size)):
    print(f"{name} = [{','.join(map(str, a))}];")
