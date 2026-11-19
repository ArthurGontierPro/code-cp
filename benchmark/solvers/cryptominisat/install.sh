#!/usr/bin/env bash
# cryptominisat: records the official release binary already at /scratch/arthur/tools/cms
# (v5.18.0, tag release/v5.18.0, commit 97c6efea) and copies it into the bench tree, then builds
# the proof checker cake_xlrup next to it.
set -euo pipefail
source "$(dirname "$(readlink -f "$0")")/../common.sh"
D=$(bench_dir cryptominisat)
SRC=/scratch/arthur/tools/cms/cryptominisat5
[ -x "$SRC" ] || { echo "missing $SRC" >&2; exit 1; }
"$SRC" --version | grep -q "CryptoMiniSat version 5.18.0" || { echo "unexpected CMS version" >&2; exit 1; }
cp "$SRC" "$D/cryptominisat5"
"$SRC" --version > "$D/build.log"
# cake_xlrup, the CakeML-verified checker of CMS's XLRUP proofs (meelgroup/frat-xor, pinned).
FX=18cd6bc17af10a9891c10a846ce966166f9fe0dc
git_pin "$D/frat-xor" https://github.com/meelgroup/frat-xor "$FX" > /dev/null
[ -x "$D/frat-xor/cake_xlrup/cake_xlrup" ] || make -C "$D/frat-xor/cake_xlrup" >> "$D/build.log" 2>&1
cp "$D/frat-xor/cake_xlrup/cake_xlrup" "$D/cake_xlrup"
echo "cake_xlrup: frat-xor commit $FX, sha256 $(sha256sum "$D/cake_xlrup" | cut -d' ' -f1)" >> "$D/build.log"
write_version cryptominisat "$D/cryptominisat5" \
  "release/v5.18.0 (github.com/msoos/cryptominisat, CMS SHA1 97c6efeae45d93c45d2ebc3e4e83c2014c79513d, static release binary)"
