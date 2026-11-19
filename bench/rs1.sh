#!/bin/bash
# rs1.sh MODEL INSTANCE PARAMS LABEL -- RoundingSat on the SAME .opb that baguette writes for this
# model (baguette run with a node limit of 1 only to write the .opb, then scripts/opb2plain.py).
# Writes results/runs/LABEL.{log,res}. TL env (seconds, default 3600).
MOD=$1; INST=$2; PAR=$3; LAB=$4; TL=${TL:-3600}
B=/scratch/arthur/codes-cp; O=$B/results/runs/$LAB; cd $B
MZN=/scratch/arthur/mzn/MiniZincIDE-2.10.1-x86_64-linux-gnu/bin/minizinc; BAG=/scratch/arthur/golay/baguette
RS=/scratch/arthur/tools/roundingsat/build/roundingsat
ulimit -S -v ${MEM:-16000000}
DA=(); [ -n "$PAR" ] && DA=(-D "$PAR")
$MZN -c --solver $BAG/tools/baguette.msc "${DA[@]}" $MOD $INST -o $O.fzn > $O.log 2>&1
BAGUETTE_NODE_LIMIT=1 $BAG/_build/default/bin/main.exe $O.fzn --proof $O.tmp > /dev/null 2>> $O.log
python3 scripts/opb2plain.py $O.tmp.opb $O.opb; rm -f $O.tmp.opb $O.tmp.pbp $O.fzn
t0=$(date +%s.%N)
/usr/bin/time -f "rss_kb %M" timeout $TL $RS $O.opb >> $O.log 2>&1
t1=$(date +%s.%N)
st=UNKNOWN; grep -q "^s UNSATISFIABLE" $O.log && st=UNSAT; grep -q "^s SATISFIABLE" $O.log && st=SAT
conf=$(grep -oE "^c conflicts [0-9]+" $O.log | tail -n 1 | awk '{print $3}')
dec=$(grep -oE "^c decisions [0-9]+" $O.log | tail -n 1 | awk '{print $3}')
printf '%s rs %s %s status=%s wall=%.1f conflicts=%s decisions=%s %s\n' "$LAB" $(basename -- $INST .dzn) "$PAR" $st \
  $(echo "$t1 - $t0" | bc) "$conf" "$dec" "$(grep rss_kb $O.log | tail -n 1)" > $O.res
gzip -f $O.opb
