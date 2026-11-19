#!/bin/bash
# install.sh -- nothing to build: baguette is already built in /scratch/arthur/baguette-b403e28
# (do not rebuild it here). Records the version.
set -e
NAME=baguette
BG=/scratch/arthur/baguette-b403e28
MZN=/scratch/arthur/mzn/MiniZincIDE-2.10.1-x86_64-linux-gnu/bin/minizinc
EXE=$BG/_build/default/bin/main.exe
D=/scratch/arthur/tools/bench/$NAME; mkdir -p "$D"
{ echo "solver: baguette, git $(git -C $BG rev-parse HEAD 2>/dev/null || echo b403e28), $EXE"
  echo "flattening: $("$MZN" --version | head -1), msc $BG/tools/baguette.msc"
  echo "main.exe sha256: $(sha256sum "$EXE" | cut -d' ' -f1)"
  echo "checker for its proofs: $(~/.cargo/bin/veripb --version 2>&1 | head -1)"; } > "$D/VERSION"
cat "$D/VERSION"
