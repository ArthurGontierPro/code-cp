#!/usr/bin/env bash
# evalmaxsat: EvalMaxSAT (github.com/FlorentAvellaneda/EvalMaxSAT), no tags: pinned to master
# commit 94e67745. CMake build; its CaDiCaL and Glucose are vendored in lib/.
set -euo pipefail
source "$(dirname "$(readlink -f "$0")")/../common.sh"
D=$(bench_dir evalmaxsat)
COMMIT=$(git_pin "$D/src" https://github.com/FlorentAvellaneda/EvalMaxSAT 94e677456cab96b2718f6da3f808bf694ac383d6)
if [ ! -x "$D/evalmaxsat" ]; then
  rm -rf "$D/build"; mkdir -p "$D/build"
  ( cd "$D/build" && cmake "$D/src" -DCMAKE_BUILD_TYPE=Release && make -j"$NJOBS" ) > "$D/build.log" 2>&1 \
    || { echo "build failed, see $D/build.log" >&2; exit 1; }
  cp "$(find "$D/build" -type f -name EvalMaxSAT_bin -perm -u+x | head -1)" "$D/evalmaxsat"
fi
write_version evalmaxsat "$D/evalmaxsat" "master commit $COMMIT (github.com/FlorentAvellaneda/EvalMaxSAT)"
