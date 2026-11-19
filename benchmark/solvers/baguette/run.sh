#!/bin/bash
# run.sh INPUT.dzn TIMELIMIT_S [ENC] -- baguette (CP, VeriPB proof logging), build b403e28.
# Flattens $MODEL (default models/minweight_chk.mzn) + INPUT.dzn + -D "ENC=..;" (default 2) with
# MiniZinc 2.10.1 against baguette's mznlib, then runs main.exe --stats --time-limit (TL minus the
# flattening time); its output goes through MiniZinc's solns2out. The reported time includes the
# flattening.
# Env: MODEL overrides the model; PROOF=PREFIX also writes PREFIX.opb / PREFIX.pbp (--proof).
NAME=baguette
# temporary files stay on the node's scratch, not in /tmp
export TMPDIR=${BENCH_TMPDIR:-/scratch/arthur/tools/bench/tmp}; mkdir -p "$TMPDIR"
INPUT=$1; TL=${2:-60}; ENC=${3:-2}
BG=/scratch/arthur/baguette-b403e28
MZN=/scratch/arthur/mzn/MiniZincIDE-2.10.1-x86_64-linux-gnu/bin/minizinc
ENCARG=(); [ "$ENC" != - ] && ENCARG=(-D "ENC=$ENC;")   # ENC "-": the model has no ENC (e.g. linear.mzn)
MODEL=${MODEL:-/scratch/arthur/codes-cp/models/minweight_chk.mzn}
TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT
t0=$(date +%s.%N)
timeout -k 10 "$TL" "$MZN" -c --solver "$BG/tools/baguette.msc" --output-mode dzn --output-objective "${ENCARG[@]}" "$MODEL" "$INPUT" \
  --fzn "$TMP/m.fzn" --ozn "$TMP/m.ozn" 2>&1
frc=$?
el=$(echo "$(date +%s.%N) - $t0" | bc)
left=$(python3 -c "print(max(1, round($TL - $el, 1)))")   # --time-limit takes fractional seconds
LOG=$TMP/log
if [ $frc -eq 0 ]; then
  EXTRA=(); [ -n "$PROOF" ] && EXTRA+=(--proof "$PROOF")
  # main.exe's stdout goes through solns2out (the .ozn) so that _objective is printed; its stderr
  # (the stats line) goes straight to ours
  ( timeout -k 10 $((TL + 60)) "$BG/_build/default/bin/main.exe" "$TMP/m.fzn" --stats --time-limit "$left" "${EXTRA[@]}"
    echo $? > "$TMP/rc" ) | "$MZN" --ozn-file "$TMP/m.ozn" 2>&1 | tee "$LOG"
  rc=$(cat "$TMP/rc" 2>/dev/null || echo 1)
else rc=$frc; : > "$LOG"; fi
t=$(echo "$(date +%s.%N) - $t0" | bc)
val=$(sed -nE 's/^_objective = (-?[0-9]+);.*/\1/p' "$LOG" | tail -1)
if   [ $frc -eq 124 ]; then st=UNKNOWN
elif [ $frc -ne 0 ]; then st=ERROR
elif grep -qx '=====ERROR=====' "$LOG"; then st=ERROR
elif grep -qx '=====UNSATISFIABLE=====' "$LOG"; then st=UNSAT
elif grep -qx '==========' "$LOG"; then st=OPTIMUM
elif grep -qx -- '----------' "$LOG"; then st=SAT
elif [ "$rc" -eq 0 ] || [ "$rc" -eq 124 ] || [ "$rc" -eq 137 ] || grep -qx '=====UNKNOWN=====' "$LOG"; then st=UNKNOWN
else st=ERROR; fi
case $st in SAT|OPTIMUM) ;; *) val=;; esac
printf 'RESULT status=%s value=%s time=%.3f\n' "$st" "${val:--}" "$t"
