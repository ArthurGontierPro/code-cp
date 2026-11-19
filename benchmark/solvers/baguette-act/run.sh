#!/bin/bash
# run.sh INPUT.dzn TIMELIMIT_S [ENC] -- baguette b403e28 with its M10 search options, the "act"
# setting of bench/x3.sh: activity (VSIDS) branching, Luby restarts, phase saving, trail reuse, and
# the tiered learned-constraint retention. Everything else is solvers/baguette/run.sh.
export BAGUETTE_FLAGS="--search activity --restarts luby --phase-saving --reuse-trail"
export BAGUETTE_RETENTION=tiered
exec bash "$(dirname "$(readlink -f "$0")")/../baguette/run.sh" "$@"
