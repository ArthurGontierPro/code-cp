#!/bin/bash
# job.sh SOLVER n k d -- one benchmark job on the node; writes out/SOLVER_n_k_d.{res,log}
# SOLVER: chuffed | gcs | baguette (with --proof + veripb) | kissat (their CNF, SAT noopt DX SB e6)
S=$1; n=$2; k=$3; d=$4; TL=${TL:-3600}
B=/scratch/arthur/codes-cp; O=$B/bench/out/${S}_${n}_${k}_${d}; mkdir -p $B/bench/out
MZN=/scratch/arthur/mzn/MiniZincIDE-2.10.1-x86_64-linux-gnu/bin/minizinc
BAG=/scratch/arthur/golay/baguette; TOOLS=/scratch/arthur/tools
D="n=$n;k=$k;d=$d;SB=true;T=-1;"
ulimit -v 8000000
t0=$(date +%s.%N); st=UNKNOWN; extra=""
case $S in
  chuffed|gcs)
    sol=chuffed; [ $S = gcs ] && sol=/scratch/arthur/gcs/build/glasgow.msc
    timeout $((TL+120)) $MZN --solver $sol -D "$D" $B/models/linear.mzn --time-limit ${TL}000 -s > $O.log 2>&1 ;;
  baguette)
    $MZN -c --solver $BAG/tools/baguette.msc -D "$D" $B/models/linear.mzn -o $O.fzn > $O.log 2>&1
    /usr/bin/time -f "rss_kb %M" timeout $((TL+60)) $BAG/_build/default/bin/main.exe $O.fzn --proof $O --stats --time-limit $TL > $O.sol 2>> $O.log
    cat $O.sol >> $O.log
    pb=$(stat -c %s $O.pbp 2>/dev/null)
    v=$(timeout $TL ~/.cargo/bin/veripb $O.opb $O.pbp 2>&1 | grep -oE "VERIFIED [A-Z ]+|Checking error.*|error.*" | head -1)
    extra="pbp_MB=$(( ${pb:-0} / 1000000 )) veripb=\"$v\""; rm -f $O.pbp $O.opb $O.fzn ;;
  kissat)
    cd $B/bench/out && mkdir -p cnf_$n_$k_$d.d && cd cnf_$n_$k_$d.d
    $TOOLS/venv/bin/python $B/external/AAAI-2026-Codes/Encodings/construct_SAT.py SAT noopt $n $k $d DX SB 6 > /dev/null 2>&1
    f=$(ls *.cnf | head -1)
    timeout $((TL+60)) $TOOLS/kissat/build/kissat --time=$TL -q $f > $O.log 2>&1
    m=$((n-k)); python3 -c "
import sys,re
v=[int(x) for l in open('$O.log') if l.startswith('v') for x in l.split()[1:]]
s=set(x for x in v if x>0)
if v: print('A = array2d(1..$((k*m)), [' + ', '.join('true' if i in s else 'false' for i in range(1,$((k*m))+1)) + '])')
" >> $O.log
    cd ..; rm -rf cnf_$n_$k_$d.d ;;
esac
t1=$(date +%s.%N)
grep -q "UNSATISFIABLE\|^s UNSATISFIABLE" $O.log && st=UNSAT
grep -q "A = array2d\|^s SATISFIABLE" $O.log && st=SAT
q=""; [ $st = SAT ] && q=$(python3 $B/scripts/lincheck.py $k $n < $O.log 2>&1)
printf '%s n=%s k=%s d=%s status=%s wall=%.1f %s %s\n' $S $n $k $d $st $(echo "$t1 - $t0" | bc) "$q" "$extra" > $O.res
