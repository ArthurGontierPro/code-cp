#!/bin/bash
# Lancé le 17/11 avec la version de minweight.mzn d'alors, où FIRST/SECOND/THIRD étaient facultatifs.
# Pour le relancer, ajouter FIRST=0;SECOND=0;THIRD=0; aux paramètres manquants.
# blockb2.sh -- B2-B4 again with the two-halves split (models/minweight.mzn, HALF = Wmax/2),
# one instance per side (X.dzn and X_T.dzn). Same phases as blockb.sh.
cd /scratch/arthur/codes-cp
TL1=${TL1:-3600}; TL2=${TL2:-7200}
job() { lab=$1; TL=$TL1 bench/run1.sh chuffed $2 $3 "$4" ${lab}_chuffed & a=$!
  TL=$TL1 bench/run1.sh gcs $2 $3 "$4" ${lab}_gcs & c=$!; wait $a $c
  best=$(grep -hE 'status=(SAT|UNSAT)' results/runs/${lab}_chuffed.res results/runs/${lab}_gcs.res \
         | grep -oE 'wall=[0-9.]+' | cut -d= -f2 | sort -g | head -1)
  if [ -n "$best" ] && [ $(echo "$best < $TL1 / 2" | bc) = 1 ]; then
    TL=$TL2 bench/run1.sh gcsP $2 $3 "$4" ${lab}_gcsP & TL=$TL2 bench/run1.sh bag $2 $3 "$4" ${lab}_bag & wait; fi; }
C=models/minweight.mzn
for x in golay24:4 qr48:8 qr72:8 qr80:12 qr104:16; do n=${x%:*}; w=${x#*:}; h=$((w / 2))
  job H_${n}_W${w}_L $C instances/$n.dzn   "Wmax=$w;HALF=$h;" &
  job H_${n}_W${w}_R $C instances/${n}_T.dzn "Wmax=$w;HALF=$h;" &
done; wait; echo done > results/runs/blockb2.done
