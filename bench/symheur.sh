#!/bin/bash
# symheur.sh -- why is the symmetric model (minweight_sym.mzn) 300 times slower for Chuffed on QR48
# and faster for baguette? Hypothesis: without annotation Chuffed (and GCS) branch on every model
# variable, including the 17296 auxiliary integers y_w (Chuffed's peakDepth is 17301). Same runs
# with the search restricted to the word x:
#   def : no annotation      x : bool_search(x, input_order, indomain_min)
#   x1  : indomain_max       free : Chuffed -f (activity-based, restarts)
cd /cluster/arthur/codes-cp; mkdir -p models/heur
for v in min max; do
  sed "s/^solve satisfy;/solve :: bool_search(x, input_order, indomain_$v) satisfy;/" models/minweight_sym.mzn > models/heur/minweight_sym_$v.mzn
done
export TL=${TL:-1800}
{
for I in "g24nofix dom/sym_p23_w4_nofix.dzn" "q48fix dom/sym_p47_w8.dzn" "q48nofix dom/sym_p47_w8_nofix.dzn"; do
  set -- $I; n=$1; f=$2
  for s in chuffed gcs bag; do
    echo "$s models/minweight_sym.mzn $f - SH_${n}_${s}_def -"
    echo "$s models/heur/minweight_sym_min.mzn $f - SH_${n}_${s}_x -"
    echo "$s models/heur/minweight_sym_max.mzn $f - SH_${n}_${s}_x1 -"
  done
  echo "chuffed models/minweight_sym.mzn $f - SH_${n}_chuffed_free -f"
done
} | xargs -P 30 -L 1 bash -c 'P=$3; [ "$P" = - ] && P=""; EXTRA=$( [ "$5" = - ] || echo $5 ) bench/run1.sh $0 $1 $2 "$P" $4'
echo done > results/runs/symheur.done
