#!/usr/bin/env bash
# YalSAT local search on a DIMACS .cnf. SAT-only: it can find a model, never prove UNSAT, so a
# run that hits TIMELIMIT is UNKNOWN. Usage: run.sh INPUT.cnf TIMELIMIT_S [SEED]
# No built-in time limit: `timeout` sends SIGTERM at TIMELIMIT (GRACE=0 here, since there is
# nothing to wrap up). Seed defaults to 0, so runs are reproducible.
source "$(dirname "$(readlink -f "$0")")/../common.sh"
GRACE=0
run_init "$@"
run_solver "$BENCH_ROOT/yalsat/yalsat" "$INPUT" "${3:-0}"
emit_result "$(s_status)"
