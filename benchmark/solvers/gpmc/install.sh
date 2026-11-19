#!/usr/bin/env bash
# gpmc: GPMC v1.2.0 (github.com/khashimoto-lab/GPMC; moved from git.trs.css.i.nagoya-u.ac.jp),
# exact (projected) model counter, winner of projected tracks of the Model Counting Competition.
# Release static build (`build.sh rs`) against GMP 6.3.0 from $BENCH_ROOT/gmp.
set -euo pipefail
source "$(dirname "$(readlink -f "$0")")/../common.sh"
D=$(bench_dir gpmc)
ensure_gmp
G=$BENCH_ROOT/gmp
COMMIT=$(git_pin "$D/src" https://github.com/khashimoto-lab/GPMC v1.2.0)
if [ ! -x "$D/gpmc" ]; then
  ( cd "$D/src" && rm -rf build bin lib \
      && cmake -B build -S . -DCMAKE_BUILD_TYPE=Release -DGPMC_STATIC_BUILD=on -DGPMC_BUILD_PP=OFF \
           -DCMAKE_CXX_FLAGS="-I$G/include" -DCMAKE_EXE_LINKER_FLAGS="-L$G/lib" \
      && cmake --build build --parallel "$NJOBS" ) > "$D/build.log" 2>&1 \
    || { echo "build failed, see $D/build.log" >&2; exit 1; }
  cp "$D/src/build/gpmc" "$D/gpmc"
fi
write_version gpmc "$D/gpmc" "v1.2.0 commit $COMMIT (github.com/khashimoto-lab/GPMC), static, GMP 6.3.0"
