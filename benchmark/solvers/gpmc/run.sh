#!/usr/bin/env bash
# GPMC, exact (projected) model counting on a DIMACS .cnf. Usage: run.sh INPUT.cnf TIMELIMIT_S
# Projection: when the file has MCC header lines `c p show v1 ... 0`, run.sh selects
# --mode pmc (projected count onto those variables); otherwise --mode mc (all models).
# GPMC does not pick the mode from the file by itself. No built-in time limit; `timeout` enforces it.
# value= the model count; status SAT if count>0, UNSAT if count=0.
source "$(dirname "$(readlink -f "$0")")/../common.sh"
GRACE=0   # no internal time limit: SIGTERM exactly at TIMELIMIT
run_init "$@"
mode=mc
grep -q '^c p show' "$INPUT" && mode=pmc
run_solver "$BENCH_ROOT/gpmc/gpmc" --mode "$mode" "$INPUT"
cnt=$(grep -m1 -E '^c s exact arb int ' "$OUTFILE" | awk '{print $NF}')
if [ -n "$cnt" ]; then
  if [ "$cnt" = 0 ]; then emit_result UNSAT 0; else emit_result SAT "$cnt"; fi
else
  emit_result "$(s_status)"
fi
