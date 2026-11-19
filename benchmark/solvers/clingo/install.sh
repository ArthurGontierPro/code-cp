#!/bin/bash
# install.sh -- clingo (Potassco) from its pip wheel, in its own Python 3.12 venv
# /scratch/arthur/tools/bench/clingo/venv; the solver is run as "python -m clingo". Idempotent.
set -e
PKG=clingo==5.8.3
D=/scratch/arthur/tools/bench/clingo; mkdir -p "$D"
B=/scratch/arthur/tools/bench
export UV_CACHE_DIR=$B/uv/cache UV_PYTHON_INSTALL_DIR=$B/uv/python UV_PYTHON_BIN_DIR=$B/uv/pybin UV_NO_MODIFY_PATH=1
[ -x $B/uv/bin/uv ] || curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR=$B/uv/bin UV_NO_MODIFY_PATH=1 INSTALLER_NO_MODIFY_PATH=1 sh >/dev/null
UV=$B/uv/bin/uv
[ -x $D/venv/bin/python ] || $UV venv -q --python 3.12 $D/venv
$UV pip install -q --python $D/venv/bin/python $PKG
{ echo "solver: $($D/venv/bin/python -m clingo --version | head -1) via $PKG (pip wheel, python 3.12)"
  echo "_clingo.so sha256: $(sha256sum $D/venv/lib/python3.12/site-packages/clingo/_clingo*.so | cut -d' ' -f1)"; } > "$D/VERSION"
cat "$D/VERSION"
