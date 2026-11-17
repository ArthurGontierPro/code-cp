#!/bin/bash
cd /scratch/arthur/codes-cp; export TL=3600
for s in chuffed gcs kissat; do for t in "40 8 17" "35 10 13"; do bench/job.sh $s $t & done; done; wait
echo done > bench/out/b8.done
