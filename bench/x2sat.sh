#!/bin/bash
# x2sat.sh -- the 2x2 design of bench/x2.sh for SAT solvers: rows = basis or orbit, parity = native
# XOR (CryptoMiniSat) or clauses; CryptoMiniSat with and without Gaussian elimination, Kissat on the
# clauses. Same four instances (3, 2, 0 fixed coordinates at weight <= 8, and weight <= 4).
cd /scratch/arthur/codes-cp; export TL=${TL:-3600}; mkdir -p dom/cnf; PY=/scratch/arthur/tools/venv/bin/python
{
for c in "sym_p47_w8 q48_fix" "sym_p47_w8_f2 q48f2" "sym_p47_w8_nofix q48_nofix" "sym_p47_w4_nofix q48w4"; do set -- $c
  for r in "" _basis; do
    I=dom/$1$r.dzn; L=X2_$2${r:-_orbit}
    $PY scripts/gencnf.py $I dom/cnf/$1${r}_xor.cnf xor >&2; $PY scripts/gencnf.py $I dom/cnf/$1${r}_cnf.cnf cnf >&2
    echo "cms dom/cnf/$1${r}_xor.cnf ${L}_xor_cms"
    echo "cmsng dom/cnf/$1${r}_xor.cnf ${L}_xor_cmsng"
    echo "cms dom/cnf/$1${r}_cnf.cnf ${L}_e1_cms"
    echo "kissat dom/cnf/$1${r}_cnf.cnf ${L}_e1_kissat"
  done
done
} | xargs -P 32 -L 1 bash bench/sat1.sh
echo done > results/runs/x2sat.done
