#!/usr/bin/env bash
# cadical: latest release of github.com/arminbiere/cadical, pinned to tag rel-3.1.0.
set -euo pipefail
source "$(dirname "$(readlink -f "$0")")/../common.sh"
D=$(bench_dir cadical)
TAG=rel-3.1.0
COMMIT=$(git_pin "$D/src" https://github.com/arminbiere/cadical "$TAG")
if [ ! -x "$D/cadical" ]; then
  ( cd "$D/src" && ./configure && make -j"$NJOBS" ) > "$D/build.log" 2>&1 \
    || { echo "build failed, see $D/build.log" >&2; exit 1; }
  cp "$D/src/build/cadical" "$D/cadical"
fi
write_version cadical "$D/cadical" "$TAG commit $COMMIT (github.com/arminbiere/cadical)"
