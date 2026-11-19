#!/usr/bin/env bash
# roundingsat: records the binary already built at /scratch/arthur/tools/roundingsat/build
# (gitlab.com/MIAOresearch/software/roundingsat, commit d4edbf79, Release, with SoPlex).
set -euo pipefail
source "$(dirname "$(readlink -f "$0")")/../common.sh"
D=$(bench_dir roundingsat)
SRC=/scratch/arthur/tools/roundingsat
[ -x "$SRC/build/roundingsat" ] || { echo "missing $SRC/build/roundingsat" >&2; exit 1; }
cp "$SRC/build/roundingsat" "$D/roundingsat"
COMMIT=$(git -C "$SRC" rev-parse HEAD)
{ echo "copied from $SRC/build/roundingsat (not rebuilt here); build logs: $SRC/build/{cmake,make}.log";
  grep -E '^(CMAKE_BUILD_TYPE|soplex):' "$SRC/build/CMakeCache.txt"; } > "$D/build.log"
write_version roundingsat "$D/roundingsat" "commit $COMMIT (gitlab.com/MIAOresearch/software/roundingsat), soplex=ON"
