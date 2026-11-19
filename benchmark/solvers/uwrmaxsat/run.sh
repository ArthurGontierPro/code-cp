#!/usr/bin/env bash
# UWrMaxSat on a WCNF (2022 format, `h` hard clauses). Usage: run.sh INPUT.wcnf TIMELIMIT_S
# Default search (core-guided + CaDiCaL); MaxPre is compiled in but off, as in the solver's
# defaults (UWR_OPTS="-maxpre" turns it on). -bm prints the model as one 0-1 string.
# value= the optimum (OPTIMUM), or the best `o` found so far when it is cut off (SAT).
source "$(dirname "$(readlink -f "$0")")/../common.sh"
run_init "$@"
# shellcheck disable=SC2086
run_solver "$BENCH_ROOT/uwrmaxsat/uwrmaxsat" "$INPUT" -m -bm -cpu-lim="$TIMELIMIT" ${UWR_OPTS:-}
emit_result "$(s_status)" "$(last_o)"
