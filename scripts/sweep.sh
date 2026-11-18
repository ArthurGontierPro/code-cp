#!/bin/bash
# HISTORIQUE (16/11) : première journée, ancien dossier /scratch/arthur/golay du nœud, modèle code.mzn ou golay.mzn. Gardé pour reproduire STATUS.md (16/11).
# sweep.sh TAG SECONDS "K=..;LEX=..;COLS=..;" ... -- Chuffed on each variant in parallel, on the node
M=/scratch/arthur/mzn/MiniZincIDE-2.10.1-x86_64-linux-gnu/bin/minizinc
cd /scratch/arthur/golay; T=$1; L=$2; shift 2; mkdir -p ch/$T
for v in "$@"; do f=ch/$T/$(echo "$v" | tr -d ';=' ); (
  ulimit -v 4000000
  /usr/bin/time -f "rss_kb %M wall %e" timeout $((L+60)) $M --solver chuffed -D "$v" golay.mzn -s --time-limit ${L}000 $EXTRA > $f.out 2>&1
  r=$(python3 check.py < $f.out 2>/dev/null | tail -1)
  printf '%-28s %s nodes=%s %s\n' "$v" "$(grep -o 'wall [0-9.]*' $f.out)" "$(grep -o 'nodes=[0-9]*' $f.out | sed 's/nodes=//')" "${r:-no solution}"
) & done; wait
