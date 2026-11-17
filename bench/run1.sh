#!/bin/bash
# run1.sh SOLVER MODEL INSTANCE PARAMS LABEL -- one run on the node, writes results/runs/LABEL.{log,res}
#   SOLVER: chuffed | gcs (no proof) | gcsP (GCS --prove, then veripb) | bag (baguette, proof, veripb)
#   MODEL: models/X.mzn   INSTANCE: instances/Y.dzn   PARAMS: e.g. "M=2;"
# TL env (seconds, default 3600). Memory cap 16 GB per run.
S=$1; MOD=$2; INST=$3; PAR=$4; LAB=$5; TL=${TL:-3600}
B=/scratch/arthur/codes-cp; O=$B/results/runs/$LAB; mkdir -p $B/results/runs
MZN=/scratch/arthur/mzn/MiniZincIDE-2.10.1-x86_64-linux-gnu/bin/minizinc
GCS=/scratch/arthur/gcs/build/glasgow.msc; BAG=/scratch/arthur/golay/baguette
VERIPB=$HOME/.cargo/bin/veripb
ulimit -v 16000000
cd $B; t0=$(date +%s.%N); extra=""
case $S in
  chuffed) timeout $((TL+120)) $MZN --solver chuffed -D "$PAR" $MOD $INST --time-limit ${TL}000 -s > $O.log 2>&1 ;;
  gcs)     timeout $((TL+120)) $MZN --solver $GCS -D "$PAR" $MOD $INST --time-limit ${TL}000 -s > $O.log 2>&1 ;;
  gcsP)    timeout $((TL+120)) $MZN --solver $GCS -D "$PAR" $MOD $INST --time-limit ${TL}000 -s \
             --prove --proof-files-basename $O > $O.log 2>&1 ;;
  bag)     $MZN -c --solver $BAG/tools/baguette.msc -D "$PAR" $MOD $INST -o $O.fzn > $O.log 2>&1
           /usr/bin/time -f "rss_kb %M" timeout $((TL * 3 / 2 + 120)) $BAG/_build/default/bin/main.exe $O.fzn \
             --proof $O --stats --time-limit $TL > $O.sol 2>> $O.log
           cat $O.sol >> $O.log ;;
esac
t1=$(date +%s.%N)
st=UNKNOWN
grep -q "UNSATISFIABLE" $O.log && st=UNSAT
grep -qE "^(norm|weight) = |^----------" $O.log && st=SAT
if [ $S = gcsP -o $S = bag ] && [ $st != UNKNOWN ] && [ -f $O.pbp ]; then
  pb=$(stat -c %s $O.pbp)
  v0=$(date +%s.%N)
  v=$( { /usr/bin/time -f "vrss_kb %M" timeout $((TL * 4)) $VERIPB $O.opb $O.pbp; } 2>&1 | grep -oE "VERIFIED[A-Z ]*|Checking error.*|Verification error.*|vrss_kb [0-9]+" | tr '\n' ' ')
  v1=$(date +%s.%N)
  extra="pbp_MB=$(( pb / 1000000 )) veripb=\"$v\" vwall=$(printf %.1f $(echo "$v1 - $v0" | bc))"
fi
rm -f $O.fzn
[ -z "$KEEP" ] && rm -f $O.pbp $O.opb
printf '%s %s %s %s status=%s wall=%.1f %s %s\n' "$LAB" $S $(basename $INST .dzn) "$PAR" $st \
  $(echo "$t1 - $t0" | bc) "$(grep -oE 'rss_kb [0-9]+' $O.log | tail -1)" "$extra" > $O.res
