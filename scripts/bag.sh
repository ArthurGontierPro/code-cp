#!/bin/bash
# bag.sh NAME FZN SECONDS proof|noproof -- baguette (and veripb if proof) on the node.
# Output in /scratch/arthur/golay/runs/NAME: out, err (stats + rss/wall), vout.
B=/scratch/arthur/golay/baguette/_build/default/bin/main.exe
D=/scratch/arthur/golay/runs/$1; mkdir -p $D; cd $D
P=""; [ "$4" = proof ] && P="--proof p"
ulimit -v 8000000
/usr/bin/time -f 'rss_kb %M wall %e' timeout $(( $3 + 60 )) $B $2 $P --stats --time-limit $3 > out 2> err
echo "solver_exit $?" >> err
if [ "$4" = proof ]; then
  ls -l p.pbp | awk '{print "pbp_bytes", $5}' >> err
  /usr/bin/time -f 'veripb_rss_kb %M wall %e' timeout 3600 ~/.cargo/bin/veripb p.opb p.pbp > vout 2>&1
  echo "veripb_exit $?" >> vout
  rm -f p.pbp p.opb
fi
