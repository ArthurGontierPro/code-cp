#!/bin/bash
# sat1.sh SOLVER CNF LABEL -- one SAT run, writes results/runs/LABEL.{log,res}. TL env (default 3600).
#   SOLVER: cms (CryptoMiniSat 5.18.0, Gaussian elimination on) | cmsng (same, --maxnummatrices 0:
#   no Gauss) | kissat (4.0.2)
S=$1; CNF=$2; LAB=$3; TL=${TL:-3600}
B=/scratch/arthur/codes-cp; O=$B/results/runs/$LAB
CMS=/scratch/arthur/tools/cms/cryptominisat5; KIS=/scratch/arthur/tools/kissat/build/kissat
ulimit -S -v ${MEM:-16000000}
t0=$(date +%s.%N)
case $S in
  cms)    timeout $((TL + 60)) $CMS --maxtime $TL --verb 1 $CNF > $O.log 2>&1 ;;
  cmsng)  timeout $((TL + 60)) $CMS --maxtime $TL --verb 1 --maxnummatrices 0 $CNF > $O.log 2>&1 ;;
  kissat) timeout $TL $KIS $CNF > $O.log 2>&1 ;;
esac
t1=$(date +%s.%N)
st=UNKNOWN; grep -q "^s UNSATISFIABLE" $O.log && st=UNSAT; grep -q "^s SATISFIABLE" $O.log && st=SAT
conf=$(grep -oE "^c conflicts *:? *[0-9]+" $O.log | tail -n 1 | grep -oE "[0-9]+$")
printf '%s %s %s status=%s wall=%.1f conflicts=%s\n' "$LAB" $S $(basename $CNF .cnf) $st $(echo "$t1 - $t0" | bc) "$conf" > $O.res
