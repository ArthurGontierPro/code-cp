#!/usr/bin/env bash
# kissat: records the binary already built at /scratch/arthur/tools/kissat (rel-4.0.2) and copies it
# into the bench tree, so a later rebuild of the original cannot change what the benchmark runs.
set -euo pipefail
source "$(dirname "$(readlink -f "$0")")/../common.sh"
D=$(bench_dir kissat)
SRC=/scratch/arthur/tools/kissat
[ -x "$SRC/build/kissat" ] || { echo "missing $SRC/build/kissat" >&2; exit 1; }
[ "$("$SRC/build/kissat" --version)" = 4.0.2 ] || { echo "unexpected kissat version" >&2; exit 1; }
cp "$SRC/build/kissat" "$D/kissat"
COMMIT=$(git -C "$SRC" rev-parse HEAD)
echo "copied from $SRC/build/kissat (built 2026-11-16, not rebuilt here)" > "$D/build.log"
write_version kissat "$D/kissat" "rel-4.0.2 commit $COMMIT (github.com/arminbiere/kissat)"
