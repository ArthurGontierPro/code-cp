#!/bin/bash
# satbig.sh -- does CryptoMiniSat's Gaussian elimination carry over to the codes that resist?
#  good (pure GF(2) parity + weight bound): QR72 weight <= 8, QR80 <= 12, QR104 <= 16, checks = the
#    generator rows as native XOR, with 0 or 3 fixed coordinates; CMS with/without Gauss, Kissat on
#    the clause form.
#  expected bad: the AAAI-26 benchmark (the generator matrix is the unknown), their CNF, CMS against
#    Kissat on instances Kissat solved in 4 s to 15 min on 2026-11-16.
# TL 3600 (good) and 1800 (AAAI).
cd /scratch/arthur/codes-cp; mkdir -p dom/cnf; PY=/scratch/arthur/tools/venv/bin/python
{
for c in "qr72 8" "qr80 12" "qr104 16"; do set -- $c
  for f in 0 3; do
    N=gen_$1_w$2_f$f; python3 scripts/qr2sym.py instances/$1.dzn $2 $f dom/$N.dzn >&2
    $PY scripts/gencnf.py dom/$N.dzn dom/cnf/${N}_xor.cnf xor >&2; $PY scripts/gencnf.py dom/$N.dzn dom/cnf/${N}_cnf.cnf cnf >&2
    echo "3600 cms dom/cnf/${N}_xor.cnf SB_${N}_xor_cms"
    echo "3600 cmsng dom/cnf/${N}_xor.cnf SB_${N}_xor_cmsng"
    echo "3600 kissat dom/cnf/${N}_cnf.cnf SB_${N}_cnf_kissat"
    echo "3600 cms dom/cnf/${N}_cnf.cnf SB_${N}_cnf_cms"
  done
done
for c in "34 10 12" "37 12 12" "38 10 14" "36 8 16" "42 10 16" "42 8 18" "39 10 15" "36 10 13"; do set -- $c
  D=dom/cnf/aaai_$1_$2_$3; mkdir -p $D
  (cd $D && $PY ../../../external/AAAI-2026-Codes/Encodings/construct_SAT.py SAT noopt $1 $2 $3 DX SB 6 > /dev/null 2>&1)
  f=$(ls $D/*.cnf | head -1)
  for s in cms cmsng kissat; do echo "1800 $s $f SB_aaai_$1_$2_$3_$s"; done
done
} | xargs -P 40 -L 1 bash -c 'TL=$0 bash bench/sat1.sh $1 $2 $3'
echo done > results/runs/satbig.done
