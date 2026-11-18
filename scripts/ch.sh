#!/bin/bash
# HISTORIQUE (16/11) : première journée, ancien dossier /scratch/arthur/golay du nœud, modèle code.mzn ou golay.mzn. Gardé pour reproduire STATUS.md (16/11).
# ch.sh SECONDS "LABEL|DZN|FLAGS" ... -- Chuffed on code.mzn, one variant per arg, in
# parallel, on the node. Output in /scratch/arthur/golay/ch2/LABEL.out
M=/scratch/arthur/mzn/MiniZincIDE-2.10.1-x86_64-linux-gnu/bin/minizinc
SOLVER=${SOLVER:-chuffed}   # or /scratch/arthur/gcs/build/glasgow.msc
cd /scratch/arthur/golay; L=$1; shift; mkdir -p ch2
for v in "$@"; do IFS='|' read lab dzn fl <<< "$v"; f=ch2/$lab; (
  ulimit -v 8000000
  /usr/bin/time -f "rss_kb %M wall %e" timeout $((L+120)) $M --solver $SOLVER $EXTRA -D "nE=0;E=[];$fl" code.mzn $dzn -s --time-limit ${L}000 > $f.out 2>&1
  st=$(grep -oE "=====UNSATISFIABLE=====|=====UNKNOWN=====" $f.out); [ -z "$st" ] && grep -q "^A =" $f.out && st=SAT
  dd=$(echo "$fl" | grep -oE '(^|;)d=[0-9]+' | grep -oE '[0-9]+'); bb=$(python3 bits.py < $f.out 2>/dev/null)
  r=""; [ -n "$bb" ] && r=$(echo $bb | ./mindist $(python3 -c "print(int(len('$bb')**0.5))") $dd | grep -v '^light')
  printf '%-14s %-20s %s nodes=%s rss=%s %s\n' "$lab" "${st:-?}" "$(grep -o 'wall [0-9.]*' $f.out)" "$(grep -o 'nodes=[0-9]*' $f.out | tail -1 | sed 's/nodes=//')" "$(grep -o 'rss_kb [0-9]*' $f.out | sed 's/rss_kb //')" "$r"
) & done; wait
