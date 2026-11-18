#!/bin/bash
# dom/run.sh NAME -- baguette on dom/NAME.dzn (models/minweight_sym.mzn), then the merged proof
# (scripts/dommerge.py) checked by VeriPB, then the same with a wrong witness (BAD=1), which
# VeriPB must reject. Runs on the node, in dom/.
cd "$(dirname "$0")"; N=$1
BAG=/scratch/arthur/golay/baguette; MZN=/scratch/arthur/mzn/MiniZincIDE-2.10.1-x86_64-linux-gnu/bin/minizinc
V=$HOME/.cargo/bin/veripb
$MZN -c --solver $BAG/tools/baguette.msc ../models/minweight_sym.mzn $N.dzn -o $N.fzn
/usr/bin/time -f "rss_kb %M wall %e" timeout ${TL:-3600} $BAG/_build/default/bin/main.exe $N.fzn --proof $N --stats > $N.sol 2> $N.err
echo "$N baguette: $(head -1 $N.sol) $(tail -n 1 $N.err)"
echo "$N alone:  $($V $N.opb $N.pbp 2>&1 | tail -n 1)"
python3 ../scripts/dommerge.py $N.fzn $N.opb $N.pbp $N.json $N.m
echo "$N merged: $( { /usr/bin/time -f "(%e s)" $V $N.m.opb $N.m.pbp; } 2>&1 | grep -E "^s |Error|error|\(" | tr '\n' ' ')"
BAD=all python3 ../scripts/dommerge.py $N.fzn $N.opb $N.pbp $N.json $N.bad > /dev/null
echo "$N wrong witness: $($V $N.bad.opb $N.bad.pbp 2>&1 | grep -E "^s |Error at|error at" | head -2 | tr '\n' ' ')"
