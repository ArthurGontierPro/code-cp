#!/bin/bash
# run.sh INPUT.dzn TIMELIMIT_S [ENC] -- Chuffed 0.14 through MiniZinc 2.10.1.
# Solves $MODEL (default models/minweight_chk.mzn) with the data INPUT.dzn and -D "ENC=..;" (default 2).
# Env: MODEL overrides the model; THREADS=N adds -p N (default: the solver's own default, one thread).
NAME=chuffed
SOLVER=org.chuffed.chuffed
# temporary files stay on the node's scratch, not in /tmp
export TMPDIR=${BENCH_TMPDIR:-/scratch/arthur/tools/bench/tmp}; mkdir -p "$TMPDIR"
INPUT=$1; TL=${2:-60}; ENC=${3:-2}
MZN=/scratch/arthur/mzn/MiniZincIDE-2.10.1-x86_64-linux-gnu/bin/minizinc
ENCARG=(); [ "$ENC" != - ] && ENCARG=(-D "ENC=$ENC;")   # ENC "-": the model has no ENC (e.g. linear.mzn)
MODEL=${MODEL:-/scratch/arthur/codes-cp/models/minweight_chk.mzn}
EXTRA=(); [ -n "$THREADS" ] && EXTRA+=(-p "$THREADS")
LOG=$(mktemp); trap 'rm -f "$LOG"' EXIT
t0=$(date +%s.%N)
timeout -k 10 $((TL + 60)) "$MZN" --solver "$SOLVER" "${EXTRA[@]}" --time-limit $((TL * 1000)) \
  --output-mode dzn --output-objective "${ENCARG[@]}" "$MODEL" "$INPUT" 2>&1 | tee "$LOG"
rc=${PIPESTATUS[0]}
t=$(echo "$(date +%s.%N) - $t0" | bc)
val=$(sed -nE 's/^_objective = (-?[0-9.]+);.*/\1/p' "$LOG" | tail -1)
if   grep -qx '=====ERROR=====' "$LOG"; then st=ERROR
elif grep -qx '=====UNSATISFIABLE=====' "$LOG"; then st=UNSAT
elif grep -qx '==========' "$LOG"; then st=OPTIMUM
elif grep -qx -- '----------' "$LOG"; then st=SAT
elif [ "$rc" -eq 0 ] || [ "$rc" -eq 124 ] || [ "$rc" -eq 137 ] || grep -qx '=====UNKNOWN=====' "$LOG"; then st=UNKNOWN
else st=ERROR; fi
case $st in SAT|OPTIMUM) ;; *) val=;; esac
printf 'RESULT status=%s value=%s time=%.3f\n' "$st" "${val:--}" "$t"
