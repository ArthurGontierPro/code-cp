#!/bin/bash
# campaign.sh JOBS.tsv OUTDIR TL PAR -- run every job of JOBS.tsv (run/jobs.py), PAR at a time.
# Each job runs in its own systemd scope (unit b1-<id>) with MemoryMax=32G and no swap, so the cap
# is on the memory actually used; a job does not start while the node has under 96 GB available.
# A job whose OUTDIR/<id>.res exists is skipped, so a stopped campaign resumes where it was.
# The leader's PID is in OUTDIR/pid. To stop: kill $(cat OUTDIR/pid), then
#   systemctl --user stop $(systemctl --user list-units --plain --no-legend 'b1-*' | cut -d' ' -f1)
# which stops only this campaign's scopes. OUTDIR/done appears at the end.
# Run on the node from benchmark/: setsid nohup bash run/campaign.sh JOBS OUT 600 92 &
cd "$(dirname "$0")/.."
JOBS=$(realpath "$1"); OUT=$(realpath -m "$2"); TL=$3; PAR=$4
mkdir -p "$OUT"; echo $$ > "$OUT/pid"; rm -f "$OUT/done"
grep -v '^#' "$JOBS" | xargs -d '\n' -P "$PAR" -n 1 bash run/one.sh "$OUT" "$TL"
touch "$OUT/done"
