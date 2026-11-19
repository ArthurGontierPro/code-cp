#!/bin/bash
# install.sh -- nothing to build: GCS is already built in /scratch/arthur/gcs. Records the version.
set -e
NAME=gcs; SOLVER=/scratch/arthur/gcs/build/glasgow.msc
MZN=/scratch/arthur/mzn/MiniZincIDE-2.10.1-x86_64-linux-gnu/bin/minizinc
EXE=/scratch/arthur/gcs/build/fzn-glasgow
G=/scratch/arthur/gcs
D=/scratch/arthur/tools/bench/$NAME; mkdir -p "$D"
dirty=; [ -n "$(git -C $G status --porcelain --untracked-files=no 2>/dev/null)" ] && dirty=" (tracked files modified)"
{ echo "solver: Glasgow Constraint Solver, git $(git -C $G rev-parse HEAD 2>/dev/null || echo '?')$dirty, msc $SOLVER"
  echo "via: $("$MZN" --version | head -1)"
  echo "minizinc sha256: $(sha256sum "$MZN" | cut -d' ' -f1)"
  echo "$(basename "$EXE") sha256: $(sha256sum "$EXE" | cut -d' ' -f1)"; } > "$D/VERSION"
cat "$D/VERSION"
