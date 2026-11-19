#!/bin/bash
# run.sh INPUT.lp TIMELIMIT_S -- standalone HiGHS 1.16.0 binary on a CPLEX LP file, one thread.
# MODE=opt|dec (default: opt iff the file name contains "_opt."). In dec mode the objective is
# dropped from a temporary copy, so HiGHS stops at the first feasible point and answers SAT/UNSAT.
D=/scratch/arthur/tools/bench/highs
# temporary files stay on the node's scratch, not in /tmp
export TMPDIR=${BENCH_TMPDIR:-/scratch/arthur/tools/bench/tmp}; mkdir -p "$TMPDIR"
INPUT=$1; TL=${2:-60}; t0=$(date +%s.%N)
MODE=${MODE:-$(case "$(basename "$INPUT")" in *_opt.*) echo opt;; *) echo dec;; esac)}
TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT
F=$INPUT
if [ "$MODE" = dec ]; then
  F=$TMP/dec.lp
  awk 'BEGIN{s=0} /^[ \t]*(min|max)[a-z]*[ \t]*$/ {print; print " obj:"; s=1; next}
       /^[ \t]*(subject to|such that|st|s\.t\.)[ \t]*$/ {s=0} !s' IGNORECASE=1 "$INPUT" > "$F"
fi
F=$(realpath "$F")
# run inside $TMP: HiGHS writes Highs.log into its working directory
( cd "$TMP" && timeout -k 10 $((TL + 60)) "$D/bin/highs" --model_file "$F" --time_limit "$TL" --threads 1 ) 2>&1 | tee "$TMP/log"
rc=${PIPESTATUS[0]}
t=$(echo "$(date +%s.%N) - $t0" | bc)
# a MIP ends with a summary block ("  Status  Optimal", "  Primal bound  8"); a pure LP prints
# "Model status : Optimal" and "Objective value : ..."
ms=$(sed -nE 's/^(Model status *: *|  Status +)(.*[^ ]) *$/\2/p' "$TMP/log" | tail -1)
val=$(sed -nE 's/^(Objective value *: *|  Primal bound +)([-+0-9.eE]+).*/\2/p' "$TMP/log" | tail -1)
feas=$(grep -cE '^ *Solution status +feasible' "$TMP/log")
case "$ms" in
  Optimal)    [ "$MODE" = opt ] && st=OPTIMUM || st=SAT;;
  Infeasible) st=UNSAT;;
  "Time limit reached"|"Interrupted by user"|"Iteration limit reached"|"Solution limit reached"|"Memory limit reached")
              [ "$feas" -gt 0 ] && st=SAT || st=UNKNOWN;;
  "")         case $rc in 124|137) st=UNKNOWN;; *) st=ERROR;; esac;;
  *)          st=ERROR;;
esac
if [ "$MODE" = opt ] && [ -n "$val" ] && { [ $st = OPTIMUM ] || [ $st = SAT ]; }; then
  val=$(python3 -c "v=float('$val'); print(int(round(v)) if abs(v-round(v))<1e-6 else v)")
else val=; fi
printf 'RESULT status=%s value=%s time=%.3f\n' "$st" "${val:--}" "$t"
