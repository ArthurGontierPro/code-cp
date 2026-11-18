#!/bin/bash
# HISTORIQUE (16/11) : première journée, ancien dossier /scratch/arthur/golay du nœud, modèle code.mzn ou golay.mzn. Gardé pour reproduire STATUS.md (16/11).
# run.sh NAME FZN TIMELIMIT -- on the node, in /scratch/arthur/golay/runs/NAME
B=/scratch/arthur/golay/baguette/_build/default/bin/main.exe
D=/scratch/arthur/golay/runs/$1; mkdir -p $D; cp $2 $D/m.fzn; cd $D
( ulimit -v 8000000
  /usr/bin/time -f 'rss_kb %M wall %e' timeout $(( $3 + 60 )) $B m.fzn --proof p --stats --time-limit $3 > out 2> err
  echo "solver_exit $?" >> err
  /usr/bin/time -f 'veripb_rss_kb %M wall %e' timeout 3600 ~/.cargo/bin/veripb p.opb p.pbp > vout 2>&1
  echo "veripb_exit $?" >> vout ) &
echo $! > pid
