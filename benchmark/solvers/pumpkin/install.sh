#!/bin/bash
# install.sh -- builds Pumpkin (LCG solver, TU Delft) from source at the commit below with the
# stable Rust toolchain, into /scratch/arthur/tools/bench/pumpkin. Idempotent.
# Cargo's registry goes to $D/cargo-home, so nothing is written under ~/.cargo.
set -e
COMMIT=82d30b71a81747ce969f809cb14edf679128f12c   # main of 2026-11 (crate version 0.5.0)
D=/scratch/arthur/tools/bench/pumpkin
mkdir -p "$D"
[ -d "$D/src" ] || git clone -q https://github.com/consol-lab/pumpkin "$D/src"
git -C "$D/src" checkout -q $COMMIT
EXE=$D/src/target/release/pumpkin-solver
if [ ! -x "$EXE" ]; then
  ( cd "$D/src" && CARGO_HOME=$D/cargo-home RUSTUP_HOME=$HOME/.rustup PATH=$HOME/.cargo/bin:$PATH \
      cargo build --release -j 16 -p pumpkin-solver -p pumpkin-checker ) > "$D/build.log" 2>&1
fi
{ echo "solver: Pumpkin git $COMMIT ($(grep -m1 '"version"' "$D/src/minizinc/pumpkin.msc" | tr -d ' ,'))"
  echo "rustc: $(PATH=$HOME/.cargo/bin:$PATH rustc --version)"
  echo "pumpkin-solver sha256: $(sha256sum "$EXE" | cut -d' ' -f1)"
  echo "msc: $D/src/minizinc/pumpkin.msc (flattened with MiniZinc 2.10.1)"; } > "$D/VERSION"
cat "$D/VERSION"
