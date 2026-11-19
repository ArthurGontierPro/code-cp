#!/bin/bash
# install.sh -- builds Huub (LCG solver over a SAT engine, Monash) from source at the tag below,
# into /scratch/arthur/tools/bench/huub, and writes huub.msc for MiniZinc. Idempotent.
set -e
TAG=huub-v100.1.0
D=/scratch/arthur/tools/bench/huub
mkdir -p "$D"
[ -d "$D/src" ] || git clone -q https://github.com/huub-solver/huub "$D/src"
git -C "$D/src" checkout -q $TAG
EXE=$D/src/target/release/huub
if [ ! -x "$EXE" ]; then
  ( cd "$D/src" && CARGO_HOME=$D/cargo-home RUSTUP_HOME=$HOME/.rustup PATH=$HOME/.cargo/bin:$PATH \
      cargo build --release -j 16 -p huub-cli ) > "$D/build.log" 2>&1
fi
cat > "$D/huub.msc" <<MSC
{ "id": "solutions.huub", "name": "Huub", "version": "$TAG",
  "executable": "$EXE", "mznlib": "$D/src/share/minizinc/huub",
  "tags": ["cp", "lcg", "int"], "stdFlags": ["-a", "-f", "-i", "-s", "-t", "-v"],
  "inputType": "JSON" }
MSC
{ echo "solver: Huub $TAG, git $(git -C "$D/src" rev-parse HEAD)"
  echo "rustc: $(PATH=$HOME/.cargo/bin:$PATH rustc --version)"
  echo "huub sha256: $(sha256sum "$EXE" | cut -d' ' -f1)"
  echo "msc: $D/huub.msc (flattened with MiniZinc 2.10.1)"; } > "$D/VERSION"
cat "$D/VERSION"
