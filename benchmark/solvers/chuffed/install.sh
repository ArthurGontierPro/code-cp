#!/bin/bash
# install.sh -- nothing to build: the solver comes with the MiniZinc 2.10.1 bundle. Records the version.
set -e
NAME=chuffed; SOLVER=org.chuffed.chuffed
MZN=/scratch/arthur/mzn/MiniZincIDE-2.10.1-x86_64-linux-gnu/bin/minizinc
EXE=/scratch/arthur/mzn/MiniZincIDE-2.10.1-x86_64-linux-gnu/bin/fzn-chuffed
D=/scratch/arthur/tools/bench/$NAME; mkdir -p "$D"
{ echo "solver: $("$MZN" --solvers | grep -F "($SOLVER" | sed 's/^ *//')"
  echo "via: $("$MZN" --version | head -1)"
  echo "minizinc sha256: $(sha256sum "$MZN" | cut -d' ' -f1)"
  echo "$(basename "$EXE") sha256: $(sha256sum "$EXE" | cut -d' ' -f1)"; } > "$D/VERSION"
cat "$D/VERSION"
