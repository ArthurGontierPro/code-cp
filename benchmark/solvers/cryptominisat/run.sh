#!/usr/bin/env bash
# CryptoMiniSat on DIMACS .cnf or .xnf (DIMACS + native `x` XOR lines; Gauss-Jordan on by default).
# Usage: run.sh INPUT TIMELIMIT_S
# If PROOF=<file> is set, CMS also writes an XLRUP proof there (text; PROOF_FORMAT=2 for binary),
# checkable by $BENCH_ROOT/cryptominisat/cake_xlrup [--no-binary] INPUT PROOF ("s VERIFIED UNSAT").
# Off by default.
source "$(dirname "$(readlink -f "$0")")/../common.sh"
run_init "$@"
extra=()
[ -n "${PROOF:-}" ] && extra=(--xlrup "${PROOF_FORMAT:-1}")
run_solver "$BENCH_ROOT/cryptominisat/cryptominisat5" --maxtime "$TIMELIMIT" "${extra[@]}" "$INPUT" ${PROOF:+"$PROOF"}
emit_result "$(s_status)"
