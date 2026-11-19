#!/bin/bash
# save.sh -- copy what /scratch would lose on a reset to the permanent /cluster (NFS, slower).
# We work on /scratch for speed; /scratch can be wiped by a reset or a crash, /cluster is kept.
# The code is on GitHub, so only what git does not hold is copied:
#   - results/runs without the raw proofs (*.pbp, regenerable and 50+ GB), dom/ without *.pbp,
#   - benchmark/instances and benchmark/results (the verified answers and the campaign .res files),
#   - bench/out and bench/launch.* (old node-only outputs), papers/ and the PDFs (not in git),
#   - from /scratch/arthur/tools: every VERSION file and the Gurobi licence files.
# rsync only sends what changed, so running it at the end of every session is cheap.
# Usage on the node: bash scripts/save.sh   (DEST overrides /cluster/arthur/codes-cp-save)
set -e
SRC=/scratch/arthur/codes-cp; T=/scratch/arthur/tools; DEST=${DEST:-/cluster/arthur/codes-cp-save}
mkdir -p "$DEST"; chmod 700 "$DEST"   # /cluster/arthur is world-writable; the copy holds a licence and PDFs
cd "$SRC"
rsync -a --exclude='*.pbp' results/runs/ "$DEST/results-runs/"
rsync -a --exclude='*.pbp' dom/ "$DEST/dom/"
rsync -a benchmark/instances/ "$DEST/benchmark-instances/"
rsync -a benchmark/results/ "$DEST/benchmark-results/"
rsync -a --ignore-missing-args bench/out bench/launch.done bench/launch.log bench/launch.pid "$DEST/bench/"
rsync -a --ignore-missing-args papers DIM80.pdf conway1999.pdf extrem.pdf notes/23958-AAAI26.KochemazovS-CS.pdf "$DEST/private/"
(cd "$T" && find . -name VERSION -o -path '*gurobi/lic-*/gurobi.lic' | rsync -a --files-from=- . "$DEST/tools/")
git log -1 --format='%H %cd' > "$DEST/SAVED-AT-COMMIT"; date -u +%FT%TZ >> "$DEST/SAVED-AT-COMMIT"
du -sh "$DEST"
