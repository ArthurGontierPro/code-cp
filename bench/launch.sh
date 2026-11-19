#!/bin/bash
# launch.sh P SOLVERS... -- every instance x solver, P jobs at a time, detached-safe
cd /cluster/arthur/codes-cp/bench; P=$1; shift
for s in "$@"; do tail -n +2 instances.csv | while IFS=, read n k d rest; do echo "$s $n $k $d"; done; done \
  | xargs -P $P -L 1 ./job.sh
echo done > launch.done
