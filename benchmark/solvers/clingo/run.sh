#!/bin/bash
# run.sh INPUT.asp TIMELIMIT_S -- clingo, one thread, default configuration. Optimisation
# (#minimize) reports OPTIMUM value=<last Optimization line> when clingo says OPTIMUM FOUND.
D=/scratch/arthur/tools/bench/clingo
# temporary files stay on the node's scratch, not in /tmp
export TMPDIR=${BENCH_TMPDIR:-/scratch/arthur/tools/bench/tmp}; mkdir -p "$TMPDIR"
INPUT=$1; TL=${2:-60}; t0=$(date +%s.%N)
LOG=$(mktemp); trap 'rm -f "$LOG"' EXIT
timeout -k 10 $((TL + 60)) "$D/venv/bin/python" -I -m clingo --time-limit="$TL" "$INPUT" 2>&1 | tee "$LOG"
rc=${PIPESTATUS[0]}
t=$(echo "$(date +%s.%N) - $t0" | bc)
val=$(sed -nE 's/^Optimization ?: *(-?[0-9]+).*/\1/p' "$LOG" | tail -1)
if   grep -qx 'OPTIMUM FOUND' "$LOG"; then st=OPTIMUM
elif grep -qx 'UNSATISFIABLE' "$LOG"; then st=UNSAT
elif grep -qx 'SATISFIABLE' "$LOG" || grep -qE '^Models +: [1-9]' "$LOG"; then st=SAT
elif grep -qx 'UNKNOWN' "$LOG" || [ "$rc" -eq 124 ] || [ "$rc" -eq 137 ]; then st=UNKNOWN
else st=ERROR; fi
grep -q '^\*\*\* ERROR' "$LOG" && st=ERROR
case $st in SAT|OPTIMUM) ;; *) val=;; esac
printf 'RESULT status=%s value=%s time=%.3f\n' "$st" "${val:--}" "$t"
