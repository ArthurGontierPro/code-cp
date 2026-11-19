#!/bin/bash
# one.sh OUTDIR TL "JOBLINE" -- one job of campaign.sh. Writes OUTDIR/<id>.log (the solver's output,
# last 200 kB) and OUTDIR/<id>.res, one line:
#   id solver expected value status got_value time maxrss_kb
# status is the wrapper's RESULT, or MEMOUT when it did not answer and its peak RSS reached 31 GB.
OUT=$1; TL=$2
IFS=$'\t' read -r id exp val env solver input extra <<< "$3"
[ -f "$OUT/$id.res" ] && exit 0
while [ "$(awk '/MemAvailable/ {print int($2 / 1048576)}' /proc/meminfo)" -lt 96 ]; do sleep 30; done
ENV=(); [ "$env" != . ] && ENV=("$env")
EX=(); [ "$extra" != . ] && EX=("$extra")
log=$OUT/$id.log
env "${ENV[@]}" systemd-run --user --scope --quiet --collect --unit="b1-$id" \
  -p MemoryMax=32G -p MemorySwapMax=0 \
  /usr/bin/time -f 'maxrss_kb %M' bash "solvers/$solver/run.sh" "$input" "$TL" "${EX[@]}" > "$log" 2>&1
r=$(grep '^RESULT' "$log" | tail -n 1)
st=$(sed -nE 's/.*status=([A-Z]+).*/\1/p' <<< "$r"); st=${st:-ERROR}
gv=$(sed -nE 's/.*value=([^ ]+).*/\1/p' <<< "$r"); gv=${gv:--}
t=$(sed -nE 's/.*time=([^ ]+).*/\1/p' <<< "$r"); t=${t:-$TL}
rss=$(sed -nE 's/^maxrss_kb ([0-9]+).*/\1/p' "$log" | tail -n 1); rss=${rss:-0}
case $st in SAT|UNSAT|OPTIMUM) ;; *) [ "$rss" -ge 32505856 ] && st=MEMOUT;; esac
if [ "$(stat -c %s "$log")" -gt 204800 ]; then tail -c 204800 "$log" > "$log.t" && mv "$log.t" "$log"; fi
echo "$id $solver $exp $val $st $gv $t $rss" > "$OUT/$id.res"
