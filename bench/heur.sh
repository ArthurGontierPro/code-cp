#!/bin/bash
# heur.sh -- quick look at the branching heuristic (2026-11-18). Same instances, same solvers,
# only the search changes:
#   def  : no annotation (Chuffed default; baguette: SPEC 3.4 first-fail, min value, DFS, no restart)
#   free : Chuffed -f (activity-based search with restarts, alternating with the annotation)
#   u    : annotation bool_search(u, input_order, indomain_min) -- the generator rows in order
#   u1   : same with indomain_max (pick rows first)
# For aut.mzn the annotation is over A0 then M (the free generator bits).
cd /cluster/arthur/codes-cp; mkdir -p models/heur
for v in min max; do
  sed "s/^solve satisfy;/solve :: bool_search(u, input_order, indomain_$v) satisfy;/" models/minweight.mzn > models/heur/minweight_$v.mzn
  sed "s/^solve satisfy;/solve :: bool_search([A0[i,j] | i in 1..h, j in 1..c+f] ++ [M[r,j,i] | r in 1..kr, j in 1..c-kr, i in 0..p-1], input_order, indomain_$v) satisfy;/" models/aut.mzn > models/heur/aut_$v.mzn
done
export TL=${TL:-1800}
{
for I in "qr48 instances/qr48.dzn Wmax=8;HALF=4;FIRST=0;SECOND=0;THIRD=0;" \
         "qr72 instances/qr72.dzn Wmax=8;HALF=4;FIRST=0;SECOND=0;THIRD=0;" \
         "o7k2 - p=7;c=10;f=2;d=16;k=2;K=2;KS=0;LEX=true;nE=0;E=[];"; do
  set -- $I; n=$1; f=$2; par=$3; m=minweight; [ $n = o7k2 ] && m=aut
  for s in chuffed bag; do
    echo "$s models/$m.mzn $f $par H_${n}_${s}_def -"
    echo "$s models/heur/${m}_min.mzn $f $par H_${n}_${s}_u -"
    echo "$s models/heur/${m}_max.mzn $f $par H_${n}_${s}_u1 -"
  done
  echo "chuffed models/$m.mzn $f $par H_${n}_chuffed_free -f"
  echo "chuffed models/heur/${m}_min.mzn $f $par H_${n}_chuffed_ufree -f"
done
} | xargs -P 30 -L 1 bash -c 'EXTRA=$( [ "$5" = - ] || echo $5 ) bench/run1.sh $0 $1 $2 "$3" $4'
echo done > results/runs/heur.done
