#!/bin/bash
# b8.sh -- RESULTS.md B8 : la non-existence des codes linéaires (40,8,17) et (35,10,13) du benchmark
# AAAI-26, avec Chuffed, GCS et Kissat (leur CNF), 1 h chacun, par bench/job.sh.
cd /scratch/arthur/codes-cp; export TL=3600
for s in chuffed gcs kissat; do for t in "40 8 17" "35 10 13"; do bench/job.sh $s $t & done; done; wait
echo done > bench/out/b8.done
