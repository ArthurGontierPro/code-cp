#!/usr/bin/env bash
# Ganak, exact (projected) model counting on a DIMACS .cnf. Usage: run.sh INPUT.cnf TIMELIMIT_S
# Projection: Ganak reads the MCC 2024 header lines `c p show v1 v2 ... 0` (the projection set;
# several lines are allowed) and counts models projected onto those variables. Without them it
# counts all models. --prob 0: deterministic mode (no probabilistic cache hashing), so the count is
# exact, not exact-with-probability-1-delta. No built-in time limit; `timeout` enforces it.
# value= the model count; status SAT if count>0, UNSAT if count=0.
source "$(dirname "$(readlink -f "$0")")/../common.sh"
GRACE=0   # no internal time limit: SIGTERM exactly at TIMELIMIT
run_init "$@"
run_solver "$BENCH_ROOT/ganak/ganak" --prob 0 "$INPUT"
cnt=$(grep -m1 -E '^c s exact (arb|quadruple|double)? *int ' "$OUTFILE" | awk '{print $NF}')
[ -z "$cnt" ] && cnt=$(grep -m1 -E '^s mc ' "$OUTFILE" | awk '{print $3}')
if [ -n "$cnt" ]; then
  if [ "$cnt" = 0 ]; then emit_result UNSAT 0; else emit_result SAT "$cnt"; fi
else
  emit_result "$(s_status)"
fi
