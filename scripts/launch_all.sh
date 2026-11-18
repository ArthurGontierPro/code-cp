#!/bin/bash
# HISTORIQUE (16/11) : première journée, ancien dossier /scratch/arthur/golay du nœud, modèle code.mzn ou golay.mzn. Gardé pour reproduire STATUS.md (16/11).
# Every lead of 2026-11-16 afternoon, in parallel. One result file per lead.
cd /scratch/arthur/golay
for N in 12 24; do for K in 1 2 3 4; do python3 subsets.py $N $K > s${N}_$K.dzn; done; done
F="LEX=false;WEIGHT=0;"
# 1. bordered double circulant, Chuffed
( a=(); for N in 12 24; do d=$([ $N = 12 ] && echo 8 || echo 12)
    for K in 1 2 3 4; do a+=("b${N}_$K|s${N}_$K.dzn|K=$K;d=$d;COLS=false;BDC=true;$F" "b${N}_${K}c|s${N}_$K.dzn|K=$K;d=$d;COLS=true;BDC=true;$F"); done; done
  ./ch.sh 1200 "${a[@]}" > r_bdc.txt 2>&1; echo done >> r_bdc.txt ) &
# 2. q48 with Chuffed's free search (activity-based instead of the model order)
( EXTRA="-f" ./ch.sh 1200 "f1|s24_1.dzn|K=1;d=12;COLS=false;BDC=false;$F" "f2|s24_2.dzn|K=2;d=12;COLS=false;BDC=false;$F" \
     "f2c|s24_2.dzn|K=2;d=12;COLS=true;BDC=false;$F" "f2l|s24_2.dzn|K=2;d=12;COLS=true;BDC=false;LEX=true;WEIGHT=0;" \
     "f3|s24_3.dzn|K=3;d=12;COLS=false;BDC=false;$F" > r_free.txt 2>&1; echo done >> r_free.txt ) &
# 3. lazy distance (CEGAR), Chuffed
( python3 cegar.py cg24 24 12 1 "K=1;d=12;COLS=false;BDC=false;LEX=false;WEIGHT=0;" > r_cegar24.txt 2>&1; echo done >> r_cegar24.txt ) &
( python3 cegar.py cg24b 24 12 1 "K=1;d=12;COLS=false;BDC=true;LEX=false;WEIGHT=0;" > r_cegar24b.txt 2>&1; echo done >> r_cegar24b.txt ) &
( python3 cegar.py cg12 12 8 1 "K=1;d=8;COLS=false;BDC=false;LEX=false;WEIGHT=0;" > r_cegar12.txt 2>&1; echo done >> r_cegar12.txt ) &
# 4. baguette with proof: the Golay "K=2 forces d=8" UNSAT, and the BDC searches
( ./bagq.sh 1800 "u2|s12_4.dzn|K=2;d=8;LEX=true;COLS=true;WEIGHT=4;BDC=false;" "u3|s12_4.dzn|K=3;d=8;LEX=true;COLS=true;WEIGHT=4;BDC=false;" \
     "u4|s12_4.dzn|K=4;d=8;LEX=true;COLS=true;WEIGHT=4;BDC=false;" \
     "gb3|s12_3.dzn|K=3;d=8;LEX=false;COLS=false;WEIGHT=0;BDC=true;" "gb7|s12_4.dzn|K=4;d=8;LEX=false;COLS=false;WEIGHT=0;BDC=true;" \
     "qb2|s24_2.dzn|K=2;d=12;LEX=false;COLS=false;WEIGHT=0;BDC=true;" "qb3|s24_3.dzn|K=3;d=12;LEX=false;COLS=false;WEIGHT=0;BDC=true;" > r_bag.txt 2>&1; echo done >> r_bag.txt ) &
wait
