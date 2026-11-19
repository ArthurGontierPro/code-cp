#!/bin/bash
# install.sh -- z3 from the z3-solver pip wheel (which ships the z3 binary), in its own Python 3.12
# venv /scratch/arthur/tools/bench/z3/venv; the binary is venv/bin/z3. Idempotent.
set -e
PKG=z3-solver==5.4.1.0
D=/scratch/arthur/tools/bench/z3; mkdir -p "$D"
B=/scratch/arthur/tools/bench
export UV_CACHE_DIR=$B/uv/cache UV_PYTHON_INSTALL_DIR=$B/uv/python UV_PYTHON_BIN_DIR=$B/uv/pybin UV_NO_MODIFY_PATH=1
[ -x $B/uv/bin/uv ] || curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR=$B/uv/bin UV_NO_MODIFY_PATH=1 INSTALLER_NO_MODIFY_PATH=1 sh >/dev/null
UV=$B/uv/bin/uv
[ -x $D/venv/bin/python ] || $UV venv -q --python 3.12 $D/venv
$UV pip install -q --python $D/venv/bin/python $PKG
{ echo "solver: $($D/venv/bin/z3 --version) via $PKG (pip wheel)"
  echo "libz3.so sha256: $(sha256sum $D/venv/lib/python3.12/site-packages/z3/lib/libz3.so | cut -d' ' -f1)"
  echo "z3 sha256: $(sha256sum $(readlink -f $D/venv/bin/z3) | cut -d' ' -f1)"; } > "$D/VERSION"
cat "$D/VERSION"
