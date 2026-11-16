#!/bin/bash
# Lengths 72 and 96 under the BDC hypothesis, Chuffed and GCS in parallel (2026-11-16).
cd /scratch/arthur/golay
for N in 36 48; do for K in 1 2 3; do python3 subsets.py $N $K > s${N}_$K.dzn; done; done
python3 subsets.py 36 4 > s36_4.dzn
G=/scratch/arthur/gcs/build/glasgow.msc
F="LEX=false;COLS=false;WEIGHT=0;BDC=true;"
V=(); for K in 2 3 4; do V+=("x36d16k$K|s36_$K.dzn|K=$K;d=16;$F" "x36d12k$K|s36_$K.dzn|K=$K;d=12;$F"); done
for K in 2 3; do V+=("x48d20k$K|s48_$K.dzn|K=$K;d=20;$F" "x48d16k$K|s48_$K.dzn|K=$K;d=16;$F"); done
( SOLVER=chuffed ./ch.sh 1800 "${V[@]}" > r_big_ch.txt 2>&1; echo done >> r_big_ch.txt ) &
( W=(); for v in "${V[@]}"; do W+=("g${v}"); done
  SOLVER=$G ./ch.sh 1800 "${W[@]}" > r_big_gcs.txt 2>&1; echo done >> r_big_gcs.txt ) &
for c in "36 16" "36 12" "48 20" "48 16"; do set -- $c
  ( timeout 7200 python3 cegar.py cg$1_$2 $1 $2 1 "K=1;d=$2;$F" > r_cegar$1_$2.txt 2>&1; echo done >> r_cegar$1_$2.txt ) &
done
wait
