#!/bin/bash
# run.sh INPUT.lp TIMELIMIT_S -- SCIP (pyscipopt wheel) on a CPLEX LP file.
# MODE=opt|dec (default: opt iff the file name contains "_opt."); dec zeroes the objective.
D=/scratch/arthur/tools/bench/scip; H=$(cd "$(dirname "$0")" && pwd)
# temporary files stay on the node's scratch, not in /tmp
export TMPDIR=${BENCH_TMPDIR:-/scratch/arthur/tools/bench/tmp}; mkdir -p "$TMPDIR"
INPUT=$1; TL=${2:-60}; t0=$(date +%s.%N)
LOG=$(mktemp); trap 'rm -f "$LOG"' EXIT
timeout -k 10 $((TL + 60)) "$D/venv/bin/python" -I "$H/run_scip.py" "$INPUT" "$TL" 2>&1 | tee "$LOG"
rc=${PIPESTATUS[0]}
if ! grep -q '^RESULT ' "$LOG"; then
  case $rc in 124|137) st=UNKNOWN;; *) st=ERROR;; esac
  printf 'RESULT status=%s value=- time=%.3f\n' "$st" "$(echo "$(date +%s.%N) - $t0" | bc)"
fi
