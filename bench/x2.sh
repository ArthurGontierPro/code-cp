#!/bin/bash
# x2.sh -- the controls asked by the review of dom/report.md (2026-11-19), on QR48, weight <= 8:
#  1. the 2x2 design of models/minweight_chk.mzn: rows = a basis (24) or the orbit (17296),
#     parity = XOR clauses (ENC=1) or sum = 2y (ENC=2), with and without the three fixed coordinates;
#     same search for Chuffed, GCS and baguette (the model's bool_search(x, input_order,
#     indomain_max)), RoundingSat on baguette's .opb with its own search;
#  2. Chuffed to completion (48 h cap) on the orbit, ENC=2, without symmetry;
#  3. baguette without PB conflict analysis, stopped by its own time limit so it prints its counters.
# Run on the node: nohup setsid bash bench/x2.sh &   (session id in results/x2.pid)
cd /scratch/arthur/codes-cp; export TL=${TL:-3600}
for f in sym_p47_w8 sym_p47_w8_nofix sym_p23_w4 sym_p23_w4_nofix; do
  [ -f dom/${f}_basis.dzn ] || python3 scripts/basisdzn.py dom/$f.dzn dom/${f}_basis.dzn
done
# a SAT check that each of the four models finds Golay's words of weight 8
for r in "" _basis; do for e in 1 2; do
  sed "s/Wmax = 4;/Wmax = 8;/" dom/sym_p23_w4_nofix$r.dzn > dom/chk_g8$r.dzn
  bash bench/run1.sh chuffed models/minweight_chk.mzn dom/chk_g8$r.dzn "ENC=$e;" X2_g8sat${r}_e${e}_chuffed
done; done
{
for fix in "" _nofix; do for r in "" _basis; do for e in 1 2; do
  I=dom/sym_p47_w8${fix}${r}.dzn; L=X2_q48${fix:-_fix}${r:-_orbit}_e${e}
  for s in chuffed gcs bag; do echo "run1 $s $I ENC=$e; ${L}_$s"; done
  echo "rs1 - $I ENC=$e; ${L}_rs"
done; done; done
} | xargs -P 34 -L 1 bash -c 'if [ $0 = run1 ]; then bench/run1.sh $1 models/minweight_chk.mzn $2 "$3" $4; else bench/rs1.sh models/minweight_chk.mzn $2 "$3" $4; fi' &
TL=172800 bash bench/run1.sh chuffed models/minweight_chk.mzn dom/sym_p47_w8_nofix.dzn "ENC=2;" X2_q48_nofix_orbit_e2_chuffed48h &
B=/scratch/arthur/golay/baguette; MZN=/scratch/arthur/mzn/MiniZincIDE-2.10.1-x86_64-linux-gnu/bin/minizinc
O=results/runs/X2_q48_fix_orbit_e2_bag_pboff
$MZN -c --solver $B/tools/baguette.msc -D "ENC=2;" models/minweight_chk.mzn dom/sym_p47_w8.dzn -o $O.fzn
( BAGUETTE_PB_ANALYSIS=off /usr/bin/time -f "rss_kb %M wall %e" $B/_build/default/bin/main.exe $O.fzn --stats --time-limit 3600 > $O.sol 2> $O.log ) &
wait
echo done > results/runs/x2.done
