#!/bin/bash
# x2rs.sh -- RoundingSat on every cell of bench/x2.sh and bench/x2f2.sh (they could not start it:
# bench/rs1.sh was not executable). Session id in results/x2rs.pid.
cd /scratch/arthur/codes-cp; export TL=${TL:-3600}
{
for c in "sym_p47_w8 q48_fix" "sym_p47_w8_nofix q48_nofix" "sym_p47_w8_f2 q48f2" "sym_p47_w4_nofix q48w4"; do set -- $c
  for r in "" _basis; do for e in 1 2; do echo "dom/$1$r.dzn ENC=$e; X2_$2${r:-_orbit}_e${e}_rs"; done; done
done
} | xargs -P 16 -L 1 bash -c 'bash bench/rs1.sh models/minweight_chk.mzn $0 "$1" $2'
echo done > results/runs/x2rs.done
