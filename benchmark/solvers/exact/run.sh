#!/usr/bin/env bash
# Exact on .opb (decision, or optimisation with a `min:` objective). Usage: run.sh INPUT.opb TIMELIMIT_S
#
# Exact's parser follows the PB-competition OPB grammar, which has only `>=` and `=`: a `<=` line
# makes it stop with "Unexpected character encountered in input". When the input has `<=` lines,
# they are rewritten as `>=` with every coefficient and the right-hand side negated (a linear pass
# into a temp file, done before the timer starts). An input already in `>=`/`=` form is passed as is.
source "$(dirname "$(readlink -f "$0")")/../common.sh"
run_init "$@"
IN=$INPUT
if grep -q '<=' "$INPUT"; then
  IN=$(mktemp "${TMPDIR:-/tmp}/bench-exact.XXXXXX.opb")
  trap 'rm -f "$OUTFILE" "$IN"' EXIT
  awk '/^\*/ || !/<=/ { print; next }
       { out = ""; seen = 0
         for (i = 1; i <= NF; i++) {
           t = $i
           if (t == "<=") { t = ">="; seen = 1 }
           else if (t ~ /^[+-]?[0-9]+$/) { t = -t; if (t > 0 && !seen) t = "+" t }
           out = out (i > 1 ? " " : "") t }
         print out }' "$INPUT" > "$IN"
fi
run_solver "$BENCH_ROOT/exact/exact" --timeout="$TIMELIMIT" "$IN"
st=$(s_status)
# Exact reports a parse or internal error as "c UNKNOWN EXCEPTION" and still exits 0.
grep -q 'EXCEPTION' "$OUTFILE" && ! grep -q '^s ' "$OUTFILE" && st=ERROR
# Without an objective Exact still answers "s OPTIMUM FOUND" (objective 0): that is a SAT answer.
v=$(last_o)
if [ "$st" = OPTIMUM ] && ! grep -q '^ *min:' "$INPUT"; then st=SAT; v=-; fi
emit_result "$st" "$v"
