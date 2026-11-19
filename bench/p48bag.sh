#!/bin/bash
# p48bag.sh -- certify P48p and P48q extremal (no vector of norm <= 4) with baguette, the three cases
# of the split (shortvec.mzn header). Two searches: default, and int_search(u, input_order,
# indomain_min) (codeword coefficients, 0 first). TL 48 h, 120 GB per run.
cd /cluster/arthur/codes-cp; mkdir -p models/heur
sed "s/^solve satisfy;/solve :: int_search(u, input_order, indomain_min) satisfy;/" models/shortvec.mzn > models/heur/shortvec_u.mzn
export TL=172800 MEM=120000000
for L in p48q p48p; do for m in shortvec heur/shortvec_u; do t=$(basename $m | sed 's/shortvec_\?//'); t=${t:-def}
  echo "instances/${L}_L.dzn M=4;BFIX=0;HALF=6; P48bag_${L}_b0L_$t models/$m.mzn"
  echo "instances/${L}_R.dzn M=4;BFIX=0;HALF=6; P48bag_${L}_b0R_$t models/$m.mzn"
  echo "instances/${L}.dzn M=4;BFIX=1;HALF=24; P48bag_${L}_b1_$t models/$m.mzn"
done; done | xargs -P 12 -L 1 bash -c 'bench/run1.sh bag $3 $0 "$1" $2'
echo done > results/runs/p48bag.done
