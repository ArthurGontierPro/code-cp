#!/bin/bash
# aut2.sh -- the lazy loops again, Chuffed only (GCS never finished a round), 8 h per round,
# resuming from the light sets already found.
cd /cluster/arthur/codes-cp
c() { RESUME=1 TL=28800 timeout 604800 python3 scripts/autcegar.py results/aut/$1 "$2" chuffed >> results/aut/$1.log 2>&1; }
for k in 3 4 5; do c o7k${k}_chuffed "p=7;c=10;f=2;d=16;k=$k;K=2;KS=0;LEX=true;" & done
c o5_chuffed "p=5;c=14;f=2;d=16;k=7;K=1;KS=0;LEX=true;" &
c o3_chuffed "p=3;c=24;f=0;d=16;k=12;K=1;KS=0;LEX=true;" &
wait; echo done > results/aut/aut2.done
