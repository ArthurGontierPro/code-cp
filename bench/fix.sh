#!/bin/bash
# fix.sh -- the 3 fixed coordinates of minweight_fix.mzn (PSL(2,p) is 3-homogeneous for p ≡ 3 mod 4).
# 1. counts (Chuffed -a) that must equal λ3 = A_d·C(d,3)/C(n,3), for several triples:
#    Golay d=8: 759·56/2024 = 21.  QR48 d=12: 17296·220/17296 = 220.  QR80 d=16: equal for every triple.
# 2. the UNSAT runs with halves + 3 fixed coordinates: QR80 weight ≤ 12, QR104 weight ≤ 16.
cd /scratch/arthur/codes-cp; O=results/fix; mkdir -p $O
MZN=/scratch/arthur/mzn/MiniZincIDE-2.10.1-x86_64-linux-gnu/bin/minizinc
cnt() {  # name inst Wmax FIXU FIXC
  r=$(timeout 86400 $MZN --solver chuffed -a -D "Wmax=$3;HALF=100;FIRST=0;SECOND=0;THIRD=0;FIXU=$4;FIXC=$5;" \
      models/minweight_fix.mzn instances/$2.dzn 2>&1 | grep -E "^----------|^==========|UNSAT" | sort | uniq -c | tr '\n' ' ')
  echo "$1 $2 Wmax=$3 FIXU=$4 FIXC=$5 : $r" >> $O/counts.txt
}
export -f cnt; export MZN O
{
cat <<'L'
g1 golay24 8 {1,2,3} {}
g2 golay24 8 {2,7,11} {}
g3 golay24 8 {5} {1,9}
g4 golay24_T 8 {} {1,2,3}
q1 qr48 12 {1,2,3} {}
q2 qr48 12 {4,10,17} {}
q3 qr48 12 {2} {5,9}
q4 qr48 12 {} {3,30,31}
r1 qr80 16 {1,2,3} {}
r2 qr80 16 {5,22,39} {}
r3 qr80 16 {7} {2,11}
L
} | xargs -P 11 -L 1 bash -c 'cnt "$@"' _ &
export TL=14400 MEM=60000000
{
for s in chuffed gcs bag; do
  echo "$s instances/qr80.dzn Wmax=12;HALF=6;FIRST=0;SECOND=0;THIRD=0;FIXU={1,2,3};FIXC={}; F80_L_$s"
  echo "$s instances/qr80_T.dzn Wmax=12;HALF=6;FIRST=0;SECOND=0;THIRD=0;FIXU={};FIXC={1,2,3}; F80_R_$s"
  echo "$s instances/qr104.dzn Wmax=16;HALF=8;FIRST=0;SECOND=0;THIRD=0;FIXU={1,2,3};FIXC={}; F104_L_$s"
  echo "$s instances/qr104_T.dzn Wmax=16;HALF=8;FIRST=0;SECOND=0;THIRD=0;FIXU={};FIXC={1,2,3}; F104_R_$s"
done
} | xargs -P 12 -L 1 bash -c 'bench/run1.sh $0 models/minweight_fix.mzn $1 "$2" $3'
wait
echo done > $O/fix.done
