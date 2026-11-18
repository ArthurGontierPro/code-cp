#!/bin/bash
# dom/runlex.sh NAME "n=..;k=..;d=..;LEX=..;" -- baguette on models/linear_dom.mzn, then the merged
# proof where the column order is derived by dominance (scripts/domlex.py), checked by VeriPB,
# then the same with a wrong witness (BAD=1: columns of A swapped, X left in place).
cd "$(dirname "$0")"; N=$1; PAR=$2
BAG=/scratch/arthur/golay/baguette; MZN=/scratch/arthur/mzn/MiniZincIDE-2.10.1-x86_64-linux-gnu/bin/minizinc
V=$HOME/.cargo/bin/veripb
$MZN -c --solver $BAG/tools/baguette.msc ../models/linear_dom.mzn -D "$PAR" -o $N.fzn
/usr/bin/time -f "rss_kb %M wall %e" timeout ${TL:-3600} $BAG/_build/default/bin/main.exe $N.fzn --proof $N --stats > $N.sol 2> $N.err
echo "$N [$PAR] baguette: $(head -1 $N.sol | cut -c1-60) $(tail -n 1 $N.err)"
echo "$N alone:  $($V $N.opb $N.pbp 2>&1 | tail -n 1)"
python3 ../scripts/domlex.py $N.fzn $N.opb $N.pbp $N.m
echo "$N merged: $( { /usr/bin/time -f "(%e s)" $V $N.m.opb $N.m.pbp; } 2>&1 | grep -E "^s |Error|\(" | tr '\n' ' ')"
BAD=1 python3 ../scripts/domlex.py $N.fzn $N.opb $N.pbp $N.bad > /dev/null
echo "$N wrong witness: $($V $N.bad.opb $N.bad.pbp 2>&1 | grep -E "^s |Error" | head -1)"
