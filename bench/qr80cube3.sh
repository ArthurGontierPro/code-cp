#!/bin/bash
# qr80cube3.sh -- third level for the 26 (FIRST, SECOND) cases of QR80 that baguette left
# UNKNOWN at 2 h: split by the third chosen row (or none). 150 baguette jobs at a time.
cd /scratch/arthur/codes-cp
for c in $(cat results/runs/Q80b_*.res | grep -v VERIFIED | grep -oE "Q80b_[LR]_[0-9]+_[0-9]+" | sed 's/Q80b_//'); do
  IFS=_ read side i j <<< "$c"; f=instances/qr80.dzn; [ $side = R ] && f=instances/qr80_T.dzn
  for t in -1 $(seq $((j+1)) 40); do echo "$f $i $j $t $side"; done
done | xargs -P 150 -L 1 bash -c 'TL=7200 bench/run1.sh bag models/minweight.mzn $0 "Wmax=12;HALF=6;FIRST=$1;SECOND=$2;THIRD=$3;" Q80c_$4_$1_$2_$3_bag'
echo done > results/runs/qr80cube3.done
