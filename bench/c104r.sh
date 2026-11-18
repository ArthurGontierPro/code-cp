#!/bin/bash
# c104r.sh -- QR104, right half with the triple {L1,L2,R1} (u1 fixed, c1 c2 fixed): split by the
# second chosen row (FIRST=1 is already forced by FIXU={1}). Chuffed, 52 jobs.
cd /scratch/arthur/codes-cp; export TL=14400
for j in -1 $(seq 2 52); do echo $j; done | xargs -P 52 -I{} bench/run1.sh chuffed models/minweight_fix.mzn instances/qr104_T.dzn "Wmax=16;HALF=8;FIRST=1;SECOND={};THIRD=0;FIXU={1};FIXC={1,2};" C104R2_{}_chuffed
echo done > results/runs/c104r.done
