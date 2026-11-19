#!/bin/bash
# aut.sh -- RESULTS.md B6 (order 7, expected UNSAT) and C1/C2 (orders 5 and 3, open).
# Direct runs go through bench/run1.sh on models/aut.mzn (no data file: everything in -D);
# lazy runs through scripts/autcegar.py (TL = per round). Detached; PIDs in results/aut/aut.pid.
cd /cluster/arthur/codes-cp; mkdir -p results/aut
G=/scratch/arthur/gcs/build/glasgow.msc; A=models/aut.mzn
direct() { TL=${2:-21600} bench/run1.sh $1 $A - "$3" $4; }
cegar()  { TL=3600 timeout 86400 python3 scripts/autcegar.py results/aut/$1 "$2" $3 > results/aut/$1.log 2>&1; }
o7="p=7;c=10;f=2;d=16;KS=0;LEX=true;nE=0;E=[];"
for k in 0 1 2; do
  direct chuffed 3600 "${o7}k=$k;K=2;" B6_o7_k${k}_chuffed &
  direct gcs     3600 "${o7}k=$k;K=2;" B6_o7_k${k}_gcs &
  direct gcsP    7200 "${o7}k=$k;K=2;" B6_o7_k${k}_gcsP &
  direct bag     7200 "${o7}k=$k;K=2;" B6_o7_k${k}_bag &
done
for k in 3 4 5; do
  direct chuffed 21600 "${o7}k=$k;K=3;" B6_o7_k${k}_K3_chuffed &
  direct gcs     21600 "${o7}k=$k;K=3;" B6_o7_k${k}_K3_gcs &
  cegar o7k${k}_chuffed "p=7;c=10;f=2;d=16;k=$k;K=2;KS=0;LEX=true;" chuffed &
  cegar o7k${k}_gcs     "p=7;c=10;f=2;d=16;k=$k;K=2;KS=0;LEX=true;" $G &
done
o5="p=5;c=14;f=2;d=16;k=7;KS=0;LEX=true;nE=0;E=[];"
direct chuffed 21600 "${o5}K=2;" C1_o5_K2_chuffed &
direct gcs     21600 "${o5}K=2;" C1_o5_K2_gcs &
direct chuffed 21600 "${o5}K=3;" C1_o5_K3_chuffed &
cegar o5_chuffed "p=5;c=14;f=2;d=16;k=7;K=1;KS=0;LEX=true;" chuffed &
cegar o5_gcs     "p=5;c=14;f=2;d=16;k=7;K=1;KS=0;LEX=true;" $G &
cegar o3_chuffed "p=3;c=24;f=0;d=16;k=12;K=1;KS=0;LEX=true;" chuffed &
wait; echo done > results/aut/aut.done
