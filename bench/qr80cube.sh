#!/bin/bash
# Lancé le 17/11 avec la version de minweight.mzn d'alors, où FIRST/SECOND/THIRD étaient facultatifs.
# Pour le relancer, ajouter FIRST=0;SECOND=0;THIRD=0; aux paramètres manquants.
# qr80cube.sh -- B4 by 2 x 40 cases (side L/R x first chosen row). Chuffed and baguette in parallel.
cd /cluster/arthur/codes-cp; C=models/minweight.mzn
for side in L R; do f=instances/qr80.dzn; [ $side = R ] && f=instances/qr80_T.dzn
  for i in $(seq 1 40); do
    TL=3600 bench/run1.sh chuffed $C $f "Wmax=12;HALF=6;FIRST=$i;" Q80_${side}_${i}_chuffed &
    TL=10800 bench/run1.sh bag    $C $f "Wmax=12;HALF=6;FIRST=$i;" Q80_${side}_${i}_bag &
  done; done; wait; echo done > results/runs/qr80cube.done
