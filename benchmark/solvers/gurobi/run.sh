#!/bin/bash
# run.sh INPUT.lp TIMELIMIT_S -- Gurobi 13.0.3 (gurobi_cl) on a CPLEX LP file, one thread.
# MODE=opt|dec (default: opt iff the file name contains "_opt."). The decision files have the zero
# objective "0 x1", so in dec mode SolutionLimit=1 stops at the first feasible point.
# Licence: an academic named-user licence is tied to one machine, so each node has its own file,
# $D/lic-<hostname>/gurobi.lic (fetched with grbgetkey --path on that node, never committed).
D=/scratch/arthur/tools/bench/gurobi; G=$D/gurobi1303/linux64
export LD_LIBRARY_PATH=$G/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
export GRB_LICENSE_FILE=$D/lic-$(hostname -s)/gurobi.lic
export TMPDIR=${BENCH_TMPDIR:-/scratch/arthur/tools/bench/tmp}; mkdir -p "$TMPDIR"
INPUT=$(realpath "$1"); TL=${2:-60}; t0=$(date +%s.%N)
MODE=${MODE:-$(case "$(basename "$INPUT")" in *_opt.*) echo opt;; *) echo dec;; esac)}
EXTRA=(); [ "$MODE" = dec ] && EXTRA=(SolutionLimit=1)
TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT
( cd "$TMP" && timeout -k 10 $((TL + 60)) "$G/bin/gurobi_cl" Threads=1 TimeLimit="$TL" LogFile= "${EXTRA[@]}" "$INPUT" ) 2>&1 | tee "$TMP/log"
rc=${PIPESTATUS[0]}
t=$(echo "$(date +%s.%N) - $t0" | bc)
val=$(sed -nE 's/^Best objective ([-+0-9.eE]+),.*/\1/p' "$TMP/log" | tail -1)
nsol=$(sed -nE 's/^Solution count ([0-9]+):.*/\1/p' "$TMP/log" | tail -1)
if   grep -q '^Optimal solution found' "$TMP/log"; then [ "$MODE" = opt ] && st=OPTIMUM || st=SAT
elif grep -q '^Solution limit reached' "$TMP/log"; then st=SAT
# every variable is bounded, so "infeasible or unbounded" can only be infeasible
elif grep -qE '^Model is infeasible' "$TMP/log"; then st=UNSAT
elif grep -qE '^(Time limit reached|Interrupt request received|Memory limit reached)' "$TMP/log"; then
  [ "${nsol:-0}" -gt 0 ] && st=SAT || st=UNKNOWN
else case $rc in 124|137) st=UNKNOWN;; *) st=ERROR;; esac; fi
if [ "$MODE" = opt ] && [ -n "$val" ] && { [ $st = OPTIMUM ] || [ $st = SAT ]; }; then
  val=$(python3 -c "v=float('$val'); print(int(round(v)) if abs(v-round(v))<1e-6 else v)")
else val=; fi
printf 'RESULT status=%s value=%s time=%.3f\n' "$st" "${val:--}" "$t"
