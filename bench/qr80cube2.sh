#!/bin/bash
# qr80cube2.sh -- second level for the QR80 cases FIRST = 1..19 (baguette did not finish them):
# split each by the second chosen row (or "alone"). 120 baguette jobs at a time.
cd /scratch/arthur/codes-cp; C=models/minweight.mzn
for side in L R; do f=instances/qr80.dzn; [ $side = R ] && f=instances/qr80_T.dzn
  for i in $(seq 1 19); do for j in -1 $(seq $((i+1)) 40); do
    echo "$f $i $j $side"; done; done; done |
  xargs -P 120 -L 1 bash -c 'TL=7200 bench/run1.sh bag models/minweight.mzn $0 "Wmax=12;HALF=6;FIRST=$1;SECOND=$2;" Q80b_$3_$1_$2_bag'
echo done > results/runs/qr80cube2.done
