#!/usr/bin/env bash
# RoundingSat on .opb (variables x1..xN, no constraint labels). Decision or optimisation
# (an objective `min:` line). Usage: run.sh INPUT.opb TIMELIMIT_S
source "$(dirname "$(readlink -f "$0")")/../common.sh"
run_init "$@"
run_solver "$BENCH_ROOT/roundingsat/roundingsat" --time-limit="$TIMELIMIT" "$INPUT"
st=$(s_status)
v=$(last_o)
emit_result "$st" "$v"
