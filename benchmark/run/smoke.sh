#!/bin/bash
# smoke.sh [TL] -- every solver of benchmark/solvers on the smoke instances of its format, against
# smoke/EXPECTED. Prints one line per run (solver, file, expected, got) and a final count.
# Runs on the node from benchmark/: bash run/smoke.sh 60
cd "$(dirname "$0")/.."; TL=${1:-60}; S=smoke; MZ=/scratch/arthur/codes-cp/models
ok=0; bad=0
check() {   # check SOLVER EXPECTED FILE [ARGS...] (env vars before the call are passed through)
  local s=$1 exp=$2; shift 2
  local got; got=$(bash solvers/$s/run.sh "$@" 2>/dev/null | grep '^RESULT' | tail -n 1)
  local st=$(sed -E 's/.*status=([A-Z]+).*/\1/' <<< "$got") val=$(sed -E 's/.*value=([^ ]+).*/\1/' <<< "$got")
  local have="$st"; [ "$val" != - ] && [ -n "$val" ] && have="$st:$val"
  local mark=FAIL
  case $exp in *:*) [ "$have" = "$exp" ] && mark=ok ;; UNKNOWN) [ "$st" = UNKNOWN ] && mark=ok ;; *) [ "$st" = "$exp" ] && mark=ok ;; esac
  [ $mark = ok ] && ok=$((ok + 1)) || bad=$((bad + 1))
  printf '%-4s %-13s %-28s expected %-12s got %s\n' $mark $s "$(basename "$1") ${*:3}" $exp "$have"
}
for s in kissat cadical cryptominisat; do
  check $s UNSAT $S/golay24_w4.cnf $TL; check $s SAT $S/golay24_w8.cnf $TL
  check $s UNSAT $S/lin_10_4_5.cnf $TL; check $s SAT $S/lin_10_4_4.cnf $TL
done
check cryptominisat UNSAT $S/golay24_w4.xnf $TL; check cryptominisat SAT $S/golay24_w8.xnf $TL
check yalsat SAT $S/golay24_w8.cnf $TL; check yalsat UNKNOWN $S/golay24_w4.cnf 5
for s in roundingsat exact; do
  check $s UNSAT $S/golay24_w4.opb $TL; check $s SAT $S/golay24_w8.opb $TL; check $s OPTIMUM:8 $S/golay24_opt.opb $TL
done
for s in uwrmaxsat evalmaxsat; do check $s OPTIMUM:8 $S/golay24_opt.wcnf $TL; done
for s in ganak gpmc; do check $s SAT:759 $S/golay24_count.cnf $TL; done
for s in chuffed gecode cpsat highs-mzn gcs baguette pumpkin huub; do
  for e in 1 2; do check $s UNSAT $S/golay24_w4.dzn $TL $e; check $s SAT $S/golay24_w8.dzn $TL $e; done
  MODEL=$MZ/linear.mzn check $s UNSAT $S/lin_10_4_5.dzn $TL -
  MODEL=$MZ/linear.mzn check $s SAT $S/lin_10_4_4.dzn $TL -
done
for s in highs scip clingo; do
  ext=lp; [ $s = clingo ] && ext=asp
  check $s UNSAT $S/golay24_w4.$ext $TL; check $s SAT $S/golay24_w8.$ext $TL; check $s OPTIMUM:8 $S/golay24_opt.$ext $TL
done
for s in z3 cvc5; do check $s UNSAT $S/golay24_w4.smt2 $TL; check $s SAT $S/golay24_w8.smt2 $TL; done
check trellis-dp UNSAT $S/golay24_w4.json $TL; check trellis-dp SAT $S/golay24_w8.json $TL
check trellis-dp OPTIMUM:8 $S/golay24_w8.json $TL opt; check trellis-dp SAT:759 $S/golay24_cnt.json $TL count
echo "smoke: $ok ok, $bad failed"
