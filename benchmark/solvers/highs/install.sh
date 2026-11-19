#!/bin/bash
# install.sh -- builds the standalone HiGHS binary (tag below) from source into
# /scratch/arthur/tools/bench/highs/bin/highs. Idempotent: does nothing if the binary exists.
set -e
TAG=v1.16.0
D=/scratch/arthur/tools/bench/highs
mkdir -p "$D"
if [ ! -x "$D/bin/highs" ]; then
  [ -d "$D/src" ] || git clone -q --depth 1 -b $TAG https://github.com/ERGO-Code/HiGHS "$D/src"
  cmake -S "$D/src" -B "$D/build" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$D" \
        -DBUILD_SHARED_LIBS=OFF -DBUILD_TESTING=OFF > "$D/build.log" 2>&1
  cmake --build "$D/build" -j16 >> "$D/build.log" 2>&1
  cmake --install "$D/build" >> "$D/build.log" 2>&1
fi
{ echo "solver: HiGHS $TAG, git $(git -C "$D/src" rev-parse HEAD)"
  echo "$("$D/bin/highs" --version 2>&1 | head -1)"
  echo "highs sha256: $(sha256sum "$D/bin/highs" | cut -d' ' -f1)"; } > "$D/VERSION"
cat "$D/VERSION"
