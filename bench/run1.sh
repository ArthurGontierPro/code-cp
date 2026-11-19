#!/bin/bash
# run1.sh SOLVER MODEL INSTANCE PARAMS LABEL -- one run on the node, writes results/runs/LABEL.{log,res}
#   SOLVER: chuffed | gcs (no proof) | gcsP (GCS --prove, then veripb) | bag (baguette, proof, veripb)
#   MODEL: models/X.mzn   INSTANCE: instances/Y.dzn   PARAMS: e.g. "M=2;"
# TL env (seconds, default 3600). Memory cap 16 GB per run. EXTRA env: extra Chuffed flags (e.g. -f).
# BAG env: baguette checkout (default the old 2c97b16 one); BAGFLAGS env: extra baguette flags.
# The FlatZinc and the .opb are part of the trust chain (RESULTS.md, E), so both are kept, gzipped:
# LABEL.fzn.gz for every solver (for chuffed and gcs a separate `-c` with the same flags, flattening
# is deterministic), LABEL.opb.gz for gcsP and bag. Only the .pbp is deleted unless KEEP is set.
S=$1; MOD=$2; INST=$3; PAR=$4; LAB=$5; TL=${TL:-3600}
B=/scratch/arthur/codes-cp; O=$B/results/runs/$LAB; mkdir -p $B/results/runs
MZN=/scratch/arthur/mzn/MiniZincIDE-2.10.1-x86_64-linux-gnu/bin/minizinc
GCS=/scratch/arthur/gcs/build/glasgow.msc; BAG=${BAG:-/scratch/arthur/golay/baguette}   # BAG env: another baguette checkout
VERIPB=$HOME/.cargo/bin/veripb
ulimit -S -v ${MEM:-16000000}; ulimit -f 200000000   # 200 GB cap per proof file
IA=$INST; [ "$INST" = - ] && IA=""
DA=(); [ -n "$PAR" ] && DA=(-D "$PAR")   # no -D at all when PARAMS is empty (minizinc refuses -D "")
cd $B; extra=""
case $S in chuffed) SL=chuffed ;; gcs|gcsP) SL=$GCS ;; bag) SL=$BAG/tools/baguette.msc ;; esac
$MZN -c --solver $SL "${DA[@]}" $MOD $IA -o $O.fzn > $O.log 2>&1
t0=$(date +%s.%N)
case $S in
  chuffed) timeout $((TL+120)) $MZN --solver chuffed $EXTRA "${DA[@]}" $MOD $IA --time-limit ${TL}000 -s >> $O.log 2>&1 ;;
  gcs)     timeout $((TL+120)) $MZN --solver $GCS "${DA[@]}" $MOD $IA --time-limit ${TL}000 -s >> $O.log 2>&1 ;;
  gcsP)    timeout $((TL+120)) $MZN --solver $GCS "${DA[@]}" $MOD $IA --time-limit ${TL}000 -s \
             --prove --proof-files-basename $O >> $O.log 2>&1 ;;
  bag)     /usr/bin/time -f "rss_kb %M" timeout $((TL * 3 / 2 + 120)) $BAG/_build/default/bin/main.exe $O.fzn \
             --proof $O --stats --time-limit $TL $BAGFLAGS > $O.sol 2>> $O.log
           cat $O.sol >> $O.log ;;
esac
t1=$(date +%s.%N)
st=UNKNOWN
grep -q "UNSATISFIABLE" $O.log && st=UNSAT
grep -qE "^(norm|weight) = |^----------" $O.log && st=SAT
if [ $S = gcsP -o $S = bag ] && [ $st != UNKNOWN ] && [ -f $O.pbp ]; then
  pb=$(stat -c %s $O.pbp)
  v0=$(date +%s.%N)
  v=$( { ulimit -S -v ${VMEM:-120000000}; /usr/bin/time -f "vrss_kb %M" timeout $((TL * 4)) $VERIPB $O.opb $O.pbp; } 2>&1 | grep -oE "VERIFIED[A-Z ]*|Checking error.*|Verification error.*|vrss_kb [0-9]+" | tr '\n' ' ')
  v1=$(date +%s.%N)
  extra="pbp_MB=$(( pb / 1000000 )) veripb=\"$v\" vwall=$(printf %.1f $(echo "$v1 - $v0" | bc))"
fi
gzip -f $O.fzn; [ -f $O.opb ] && gzip -f $O.opb
[ -z "$KEEP" ] && rm -f $O.pbp
printf '%s %s %s %s status=%s wall=%.1f %s %s\n' "$LAB" $S $(basename -- $INST .dzn) "$PAR" $st \
  $(echo "$t1 - $t0" | bc) "$(grep -oE 'rss_kb [0-9]+' $O.log | tail -1)" "$extra" > $O.res
