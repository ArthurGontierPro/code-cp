#!/usr/bin/env bash
# yalsat: YalSAT local search (github.com/arminbiere/yalsat), no tags: pinned to master commit
# a0fd39f0 (2024-07-21, VERSION 1.0.1). `./configure.sh -O` = optimised, no mems/stats counters.
set -euo pipefail
source "$(dirname "$(readlink -f "$0")")/../common.sh"
D=$(bench_dir yalsat)
COMMIT=$(git_pin "$D/src" https://github.com/arminbiere/yalsat a0fd39f072f2d4693dd5a1977de3c3d3f69c8850)
if [ ! -x "$D/yalsat" ]; then
  ( cd "$D/src" && ./configure.sh -O && make -j"$NJOBS" yalsat ) > "$D/build.log" 2>&1 \
    || { echo "build failed, see $D/build.log" >&2; exit 1; }
  cp "$D/src/yalsat" "$D/yalsat"
fi
write_version yalsat "$D/yalsat" "master commit $COMMIT (github.com/arminbiere/yalsat), VERSION $(cat "$D/src/VERSION")"
