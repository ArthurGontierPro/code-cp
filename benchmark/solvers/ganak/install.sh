#!/usr/bin/env bash
# ganak: official static release binary v2.9.0 (github.com/meelgroup/ganak, tag release/v2.9.0,
# Ganak SHA1 f262be53). The tarball is checked against the sha256 digest GitHub publishes for it.
set -euo pipefail
source "$(dirname "$(readlink -f "$0")")/../common.sh"
D=$(bench_dir ganak)
TGZ=ganak-v2.9.0-linux-amd64.tar.gz
TGZ_SHA256=a303febfa889d887771d9c97680ca83475987d39166c524f50e8d9d344655183
mkdir -p "$D/dl" "$D/rel"
[ -f "$D/dl/$TGZ" ] || curl -sSL -o "$D/dl/$TGZ" "https://github.com/meelgroup/ganak/releases/download/release/v2.9.0/$TGZ"
echo "$TGZ_SHA256  $D/dl/$TGZ" | sha256sum -c - > "$D/build.log" || { echo "tarball sha256 mismatch" >&2; exit 1; }
tar xzf "$D/dl/$TGZ" -C "$D/rel"
cp "$D/rel/ganak" "$D/ganak"
"$D/ganak" --version >> "$D/build.log" 2>&1
write_version ganak "$D/ganak" "release/v2.9.0 binary $TGZ (sha256 $TGZ_SHA256), $(grep 'Ganak SHA1' "$D/build.log" | sed 's/^c o //')"
