#!/usr/bin/env bash
# kissat on a DIMACS .cnf. Usage: run.sh INPUT.cnf TIMELIMIT_S
source "$(dirname "$(readlink -f "$0")")/../common.sh"
run_init "$@"
run_solver "$BENCH_ROOT/kissat/kissat" --time="$TIMELIMIT" "$INPUT"
emit_result "$(s_status)"
