#!/bin/bash
# p48split.sh -- B5 by cases (see models/shortvec.mzn header): b=0 left/right halves, b=1.
cd /scratch/arthur/codes-cp
TL1=${TL1:-3600}; TL2=${TL2:-7200}
job() { lab=$1; TL=$TL1 bench/run1.sh chuffed $2 $3 "$4" ${lab}_chuffed & a=$!
  TL=$TL1 bench/run1.sh gcs $2 $3 "$4" ${lab}_gcs & c=$!; wait $a $c
  best=$(grep -hE 'status=(SAT|UNSAT)' results/runs/${lab}_chuffed.res results/runs/${lab}_gcs.res \
         | grep -oE 'wall=[0-9.]+' | cut -d= -f2 | sort -g | head -1)
  if [ -n "$best" ] && [ $(echo "$best < $TL1 / 2" | bc) = 1 ]; then
    TL=$TL2 bench/run1.sh gcsP $2 $3 "$4" ${lab}_gcsP & TL=$TL2 bench/run1.sh bag $2 $3 "$4" ${lab}_bag & wait; fi; }
S=models/shortvec.mzn
for x in p48p p48q; do
  job P_${x}_b0_L $S instances/${x}_L.dzn "M=4;BFIX=0;HALF=6;" &
  job P_${x}_b0_R $S instances/${x}_R.dzn "M=4;BFIX=0;HALF=6;" &
  job P_${x}_b1   $S instances/${x}_L.dzn "M=4;BFIX=1;HALF=24;" &
  job P_${x}_M6_check $S instances/${x}_L.dzn "M=6;BFIX=-1;HALF=24;" &
done; wait; echo done > results/runs/p48split.done
