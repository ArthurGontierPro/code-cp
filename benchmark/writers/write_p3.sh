#!/bin/bash
# write_p3.sh CANON.json OUTPREFIX -- the P3 formats:
#   OUTPREFIX.cnf        the AAAI-26 CNF (external/AAAI-2026-Codes/Encodings/construct_SAT.py,
#                        "SAT noopt N K D DX SB 6", their symmetry breaking included)
#   OUTPREFIX.cnf-nosb   the same without their symmetry breaking (NOSB)
#   OUTPREFIX.mznpar     the -D parameters for models/linear.mzn (SB=false, T=-1) and
#   OUTPREFIX.mzndompar  for models/linear_dom.mzn (LEX=1, the column order justifiable by dominance)
# Runs on the node (needs the AAAI repository under /cluster/arthur/codes-cp/external).
J=$1; P=$2; B=/cluster/arthur/codes-cp; PY=/scratch/arthur/tools/venv/bin/python
read n k d < <(python3 -c "import json; I=json.load(open('$J')); print(I['n'], I['k'], I['d'])")
T=$(mktemp -d); trap "rm -rf $T" EXIT
for sb in SB NOSB; do
  (cd $T && rm -f *.cnf && $PY $B/external/AAAI-2026-Codes/Encodings/construct_SAT.py SAT noopt $n $k $d DX $sb 6 > /dev/null 2>&1)
  f=$(ls $T/*.cnf 2>/dev/null | head -1)
  [ -n "$f" ] && { [ $sb = SB ] && cp $f $P.cnf || cp $f $P.cnf-nosb; } || echo "construct_SAT.py $sb failed" >&2
done
echo "n=$n;k=$k;d=$d;SB=false;T=-1;" > $P.mznpar
echo "n=$n;k=$k;d=$d;LEX=1;" > $P.mzndompar
ls $P.*
