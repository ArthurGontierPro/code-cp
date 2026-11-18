#!/bin/bash
# aut3.sh -- the length-72 lazy loops again, in parallel with aut2.sh, with the "1 first" heuristic
# (models/heur/aut_max.mzn), resuming from aut2's light sets. 1 h rounds.
cd /scratch/arthur/codes-cp; PF=results/aut/aut3.pid
while read lab d; do
  cp results/aut/${lab}_chuffed.dzn results/aut/${lab}_max.dzn
  RESUME=1 MODEL=models/heur/aut_max.mzn TL=3600 setsid nohup timeout 604800 python3 scripts/autcegar.py \
    results/aut/${lab}_max "$d" > results/aut/${lab}_max.log 2>&1 < /dev/null &
  echo $! >> $PF
done <<'L'
o7k3 p=7;c=10;f=2;d=16;k=3;K=2;KS=0;LEX=true;
o7k4 p=7;c=10;f=2;d=16;k=4;K=2;KS=0;LEX=true;
o7k5 p=7;c=10;f=2;d=16;k=5;K=2;KS=0;LEX=true;
o5 p=5;c=14;f=2;d=16;k=7;K=1;KS=0;LEX=true;
o3 p=3;c=24;f=0;d=16;k=12;K=1;KS=0;LEX=true;
L
