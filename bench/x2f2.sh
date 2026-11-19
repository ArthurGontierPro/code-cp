#!/bin/bash
# x2f2.sh -- the 2x2 design of bench/x2.sh on QR48, weight <= 8, with TWO fixed coordinates
# (dom/sym_p47_w8_f2.dzn): the intermediate instance where Chuffed finishes (534 s), so that node
# counts are compared at completion rather than at a timeout. Also the four solvers on QR48, weight
# <= 4, no symmetry, where baguette loses. Session id in results/x2f2.pid.
cd /cluster/arthur/codes-cp; export TL=${TL:-7200}
[ -f dom/sym_p47_w8_f2_basis.dzn ] || python3 scripts/basisdzn.py dom/sym_p47_w8_f2.dzn dom/sym_p47_w8_f2_basis.dzn
[ -f dom/sym_p47_w4_nofix_basis.dzn ] || python3 scripts/basisdzn.py dom/sym_p47_w4_nofix.dzn dom/sym_p47_w4_nofix_basis.dzn
{
for c in "sym_p47_w8_f2 q48f2" "sym_p47_w4_nofix q48w4"; do set -- $c
  for r in "" _basis; do for e in 1 2; do
    I=dom/$1$r.dzn; L=X2_$2${r:-_orbit}_e${e}
    for s in chuffed gcs bag; do echo "run1 $s $I ENC=$e; ${L}_$s"; done
    echo "rs1 - $I ENC=$e; ${L}_rs"
  done; done
done
} | xargs -P 32 -L 1 bash -c 'if [ $0 = run1 ]; then bench/run1.sh $1 models/minweight_chk.mzn $2 "$3" $4; else bench/rs1.sh models/minweight_chk.mzn $2 "$3" $4; fi'
echo done > results/runs/x2f2.done
