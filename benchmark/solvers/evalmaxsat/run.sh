#!/usr/bin/env bash
# EvalMaxSAT on a WCNF (2022 format, `h` hard clauses). Usage: run.sh INPUT.wcnf TIMELIMIT_S
# --TCT (target computation time) is set to TIMELIMIT so the solver budgets its core
# minimisation for it; it is not a hard limit, `timeout` enforces that.
# value= the optimum (OPTIMUM), or the best `o` found so far when it is cut off (SAT).
source "$(dirname "$(readlink -f "$0")")/../common.sh"
GRACE=0   # no internal time limit: SIGTERM exactly at TIMELIMIT
run_init "$@"
run_solver "$BENCH_ROOT/evalmaxsat/evalmaxsat" --TCT "$TIMELIMIT" "$INPUT"
emit_result "$(s_status)" "$(last_o)"
