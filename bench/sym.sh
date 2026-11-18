#!/bin/bash
# sym.sh -- symmetric model (minweight_sym.mzn, one parity per minimum-weight word) against the
# systematic one (minweight.mzn, XOR chains), with and without three coordinates imposed, on
# Golay (weight ≤ 4) and QR48 (weight ≤ 8), all UNSAT. Chuffed, GCS without proof, baguette with
# proof. Then the merged dominance proof on QR48 (dom/run.sh). See dom/README.md.
# Run on the node from the repo root: nohup setsid bash bench/sym.sh &  (PIDs in results/sym.pid)
cd /scratch/arthur/codes-cp; export TL=${TL:-3600}
P0="HALF=99;FIRST=0;SECOND=0;THIRD=0;"
for S in chuffed gcs bag; do
  for c in "golay24 sym_p23_w4 4 12" "qr48 sym_p47_w8 8 24"; do
    set -- $c; C=$1; Y=$2; W=$3; K=$4; P0="HALF=$K;FIRST=0;SECOND=0;THIRD=0;Wmax=$W;"
    bash bench/run1.sh $S models/minweight_sym.mzn dom/$Y.dzn "" SYM_${C}_symfix_$S &
    bash bench/run1.sh $S models/minweight_sym.mzn dom/${Y}_nofix.dzn "" SYM_${C}_symnofix_$S &
    bash bench/run1.sh $S models/minweight_fix.mzn instances/$C.dzn "${P0}FIXU={1,2,3};FIXC={};" SYM_${C}_sysfix_$S &
    bash bench/run1.sh $S models/minweight.mzn instances/$C.dzn "$P0" SYM_${C}_sysnofix_$S &
  done
done
TL=$((TL * 2)) bash dom/run.sh sym_p47_w8 > results/sym_merge_p47.txt 2>&1 &
wait
