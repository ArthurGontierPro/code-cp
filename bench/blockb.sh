#!/bin/bash
# Lancé le 17/11 avec la version de minweight.mzn d'alors, où FIRST/SECOND/THIRD étaient facultatifs.
# Pour le relancer, ajouter FIRST=0;SECOND=0;THIRD=0; aux paramètres manquants.
# blockb.sh -- RESULTS.md block B. Phase 1: chuffed + gcs without proof (TL1). Phase 2, per
# instance, only if a no-proof solver concluded within TL1/2: GCS with proof and baguette
# (always proof), both checked by veripb (TL2). Everything in parallel; one line per run in
# results/runs/*.res. Launched detached; PIDs in results/runs/blockb.pid.
cd /scratch/arthur/codes-cp
TL1=${TL1:-3600}; TL2=${TL2:-7200}
job() { # label model inst params
  lab=$1; TL=$TL1 bench/run1.sh chuffed $2 $3 "$4" ${lab}_chuffed & a=$!
  TL=$TL1 bench/run1.sh gcs $2 $3 "$4" ${lab}_gcs & c=$!; wait $a $c
  best=$(grep -hE 'status=(SAT|UNSAT)' results/runs/${lab}_chuffed.res results/runs/${lab}_gcs.res \
         | grep -oE 'wall=[0-9.]+' | cut -d= -f2 | sort -g | head -1)
  if [ -n "$best" ] && [ $(echo "$best < $TL1 / 2" | bc) = 1 ]; then
    TL=$TL2 bench/run1.sh gcsP $2 $3 "$4" ${lab}_gcsP & TL=$TL2 bench/run1.sh bag $2 $3 "$4" ${lab}_bag & wait
  fi
}
S=models/shortvec.mzn; C=models/minweight.mzn
job B1_leech_M2   $S instances/leech.dzn   "M=2;" &
job B1_leech_M4   $S instances/leech.dzn   "M=4;" &
job B5_p48p_M4    $S instances/p48p.dzn    "M=4;" &
job B5_p48q_M4    $S instances/p48q.dzn    "M=4;" &
job B5_p48p_M6    $S instances/p48p.dzn    "M=6;" &
job B2_golay_W4   $C instances/golay24.dzn "Wmax=4;" &
job B3_qr48_W8    $C instances/qr48.dzn    "Wmax=8;" &
job Bx_qr72_W8    $C instances/qr72.dzn    "Wmax=8;" &
job B4_qr80_W12   $C instances/qr80.dzn    "Wmax=12;" &
job Bx_qr104_W16  $C instances/qr104.dzn   "Wmax=16;" &
job Bx_qr48_W12   $C instances/qr48.dzn    "Wmax=12;" &
job Bx_qr80_W16   $C instances/qr80.dzn    "Wmax=16;" &
wait
echo done > results/runs/blockb.done
