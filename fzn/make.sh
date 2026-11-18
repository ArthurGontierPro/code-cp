#!/bin/bash
# fzn/make.sh -- the FlatZinc each solver receives, for a few representative runs.
# Same commands as bench/run1.sh. Usage: bash fzn/make.sh SOLVERLIB  (chuffed | baguette.msc | glasgow.msc path)
cd "$(dirname "$0")/.."; S=$1; tag=$2; MZN=${MZN:-minizinc}
while read name model inst par; do
  $MZN -c --solver $S -D "$par" models/$model instances/$inst -o fzn/${name}_$tag.fzn
done <<'L'
golay_w4 minweight.mzn golay24.dzn Wmax=4;HALF=12;FIRST=0;SECOND=0;THIRD=0;
qr48_w8_L minweight.mzn qr48.dzn Wmax=8;HALF=4;FIRST=0;SECOND=0;THIRD=0;
qr80_w12_L_1_3 minweight.mzn qr80.dzn Wmax=12;HALF=6;FIRST=1;SECOND=3;THIRD=0;
leech_m2 shortvec.mzn leech.dzn M=2;BFIX=-1;HALF=12;
p48q_m4_b0L shortvec.mzn p48q_L.dzn M=4;BFIX=0;HALF=6;
p48q_m4_b1 shortvec.mzn p48q.dzn M=4;BFIX=1;HALF=24;
L
