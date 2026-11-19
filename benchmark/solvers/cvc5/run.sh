#!/bin/bash
# run.sh INPUT.smt2 TIMELIMIT_S -- cvc5, default options. The first line of the answer (sat, unsat,
# unknown, timeout) gives the status; value=- (decision instances).
D=/scratch/arthur/tools/bench/cvc5
# temporary files stay on the node's scratch, not in /tmp
export TMPDIR=${BENCH_TMPDIR:-/scratch/arthur/tools/bench/tmp}; mkdir -p "$TMPDIR"
INPUT=$1; TL=${2:-60}; t0=$(date +%s.%N)
LOG=$(mktemp); trap 'rm -f "$LOG"' EXIT
timeout -k 10 $((TL + 60)) "$D/bin/cvc5" --tlimit=$((TL * 1000)) "$INPUT" 2>&1 | tee "$LOG"
rc=${PIPESTATUS[0]}
t=$(echo "$(date +%s.%N) - $t0" | bc)
case "$(grep -m1 -xE 'sat|unsat|unknown|timeout' "$LOG")" in
  sat) st=SAT;; unsat) st=UNSAT;; unknown|timeout) st=UNKNOWN;;
  *) case $rc in 124|137) st=UNKNOWN;; *) st=ERROR;; esac;;
esac
grep -q '^(error' "$LOG" && st=ERROR
grep -q "interrupted by timeout" "$LOG" && st=UNKNOWN
printf 'RESULT status=%s value=- time=%.3f\n' "$st" "$t"
