#!/bin/bash
# x3.sh -- the baguette cells of the 2x2 design (bench/x2.sh, x2f2.sh) again with baguette b403e28
# (2026-11-19: the M11 complexity passes on by default, the M10 search strategies as options), in
# three settings, every proof checked by VeriPB:
#   def : default flags, the model's annotation (the search shared with Chuffed and GCS)
#   f   : -f  (alternate between the annotation and activity, Luby restarts, phase saving)
#   act : --search activity --restarts luby --phase-saving --reuse-trail, BAGUETTE_RETENTION=tiered
cd /cluster/arthur/codes-cp; export TL=${TL:-3600} BAG=/scratch/arthur/baguette-b403e28
{
for c in "sym_p47_w8 q48_fix" "sym_p47_w8_f2 q48f2" "sym_p47_w8_nofix q48_nofix" "sym_p47_w4_nofix q48w4"; do set -- $c
  for r in "" _basis; do for e in 1 2; do
    echo "def dom/$1$r.dzn ENC=$e; X3_$2${r:-_orbit}_e${e}_bagdef"
    echo "f dom/$1$r.dzn ENC=$e; X3_$2${r:-_orbit}_e${e}_bagf"
    echo "act dom/$1$r.dzn ENC=$e; X3_$2${r:-_orbit}_e${e}_bagact"
  done; done
done
} | xargs -P 48 -L 1 bash -c 'case $0 in def) F="";; f) F="-f";; act) F="--search activity --restarts luby --phase-saving --reuse-trail"; export BAGUETTE_RETENTION=tiered;; esac; BAGFLAGS="$F" bench/run1.sh bag models/minweight_chk.mzn $1 "$2" $3'
echo done > results/runs/x3.done
