#!/bin/bash
# bagq.sh SECONDS "LABEL|DZN|FLAGS" ... -- flatten code.mzn for baguette, solve with
# proof, check with veripb; one line per variant. Output in /scratch/arthur/golay/bq/LABEL.*
G=/scratch/arthur/golay; M=/scratch/arthur/mzn/MiniZincIDE-2.10.1-x86_64-linux-gnu/bin/minizinc
B=$G/baguette/_build/default/bin/main.exe; L=$1; shift; mkdir -p $G/bq; cd $G
for v in "$@"; do IFS='|' read lab dzn fl <<< "$v"; f=$G/bq/$lab; (
  ulimit -v 8000000
  $M -c --solver $G/baguette/tools/baguette.msc -D "nE=0;E=[];$fl" code.mzn $dzn -o $f.fzn > $f.flat 2>&1
  /usr/bin/time -f "rss_kb %M wall %e" timeout $((L+60)) $B $f.fzn --proof $f --stats --time-limit $L > $f.out 2> $f.err
  ex=$?
  st=$(grep -oE "UNSATISFIABLE|UNKNOWN" $f.out | head -1); [ -z "$st" ] && grep -q "true\|false" $f.out && st=SAT
  vr=$(/usr/bin/time -f "vwall %e vrss %M" timeout 3600 ~/.cargo/bin/veripb $f.opb $f.pbp 2>&1 | grep -oE "VERIFIED.*|error.*|vwall.*" | tr '\n' ' ')
  pb=$(stat -c %s $f.pbp 2>/dev/null); rm -f $f.pbp $f.opb
  r=$(python3 check.py < $f.out 2>/dev/null | tr '\n' ' ' | grep -oE "min distance: [0-9]+|extremal.*")
  printf '%-10s %-6s exit=%s %s nodes=%s pbp=%sMB | %s | %s\n' "$lab" "${st:-?}" $ex "$(grep -oE 'rss_kb [0-9]+ wall [0-9.]+' $f.err)" "$(grep -oE '^stats: nodes +[0-9]+' $f.err | grep -oE '[0-9]+$')" "$((${pb:-0}/1000000))" "$vr" "$r"
) & done; wait
