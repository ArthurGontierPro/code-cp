#!/bin/bash
# equiv.sh -- tests of the model shortcuts on instances whose answer is known (RESULTS.md, D).
# 1. Counting: scripts/equivcount.py golay | qr48 | leech | p48p | p48q.
# 2. aut.mzn at length 48, d = 12: the extremal [48,24,12] is unique (QR48, Houghten, Lam,
#    Thiel, Parker 2003), with Aut = PSL(2,47), of order 2^4·3·23·47. Elements of order 3 act
#    without fixed points (3^16), order 23 as 23^2 1^2. So: p = 3 (3^16) and p = 23 must be SAT,
#    and p = 5, 7, 11, or p = 3 with fixed points, must be UNSAT.
# PIDs of the detached leaders go to results/equiv/equiv.pid.
cd /cluster/arthur/codes-cp; mkdir -p results/equiv; PF=results/equiv/equiv.pid
for t in qr48 leech p48p p48q; do
  setsid nohup timeout 345600 python3 scripts/equivcount.py $t 60 > results/equiv/$t.out 2>&1 < /dev/null &
  echo $! >> $PF
done
while read lab d; do
  TL=3600 setsid nohup timeout 259200 python3 scripts/autcegar.py results/equiv/$lab "$d" \
    > results/equiv/$lab.log 2>&1 < /dev/null &
  echo $! >> $PF
done <<'L'
a48_p23k0 p=23;c=2;f=2;d=12;k=0;K=1;KS=0;LEX=true;
a48_p23k1 p=23;c=2;f=2;d=12;k=1;K=1;KS=0;LEX=true;
a48_p3f0 p=3;c=16;f=0;d=12;k=8;K=1;KS=0;LEX=true;
a48_p3f6 p=3;c=14;f=6;d=12;k=7;K=1;KS=0;LEX=true;
a48_p5 p=5;c=8;f=8;d=12;k=4;K=2;KS=0;LEX=true;
a48_p7k2 p=7;c=6;f=6;d=12;k=2;K=2;KS=0;LEX=true;
a48_p7k3 p=7;c=6;f=6;d=12;k=3;K=2;KS=0;LEX=true;
a48_p11 p=11;c=4;f=4;d=12;k=2;K=1;KS=0;LEX=true;
L
