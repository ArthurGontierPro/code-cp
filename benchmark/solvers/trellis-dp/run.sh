#!/bin/bash
# run.sh CANON.json TIMELIMIT [opt|count] -- the syndrome-trellis DP (dp.py), our own solver.
D=$(dirname "$0"); timeout $2 python3 $D/dp.py $1 ${3:-decide} || echo "RESULT status=UNKNOWN value=- time=$2"
