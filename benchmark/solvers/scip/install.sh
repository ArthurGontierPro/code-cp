#!/bin/bash
# install.sh -- SCIP through its official Python wheel (pyscipopt bundles the SCIP library), in its
# own Python 3.12 venv /scratch/arthur/tools/bench/scip/venv (Python from uv). Idempotent.
set -e
PKG=pyscipopt==6.3.0
D=/scratch/arthur/tools/bench/scip; mkdir -p "$D"
B=/scratch/arthur/tools/bench
export UV_CACHE_DIR=$B/uv/cache UV_PYTHON_INSTALL_DIR=$B/uv/python UV_PYTHON_BIN_DIR=$B/uv/pybin UV_NO_MODIFY_PATH=1
[ -x $B/uv/bin/uv ] || curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR=$B/uv/bin UV_NO_MODIFY_PATH=1 INSTALLER_NO_MODIFY_PATH=1 sh >/dev/null
UV=$B/uv/bin/uv
[ -x $D/venv/bin/python ] || $UV venv -q --python 3.12 $D/venv
$UV pip install -q --python $D/venv/bin/python $PKG
{ echo "solver: SCIP $($D/venv/bin/python -c 'import pyscipopt; print(pyscipopt.Model().version())') via $PKG (pip wheel, python 3.12)"
  echo "wheel lib sha256: $(sha256sum $(ls $D/venv/lib/python3.12/site-packages/pyscipopt.libs/libscip*.so* 2>/dev/null | head -1) 2>/dev/null | cut -d' ' -f1)"; } > "$D/VERSION"
cat "$D/VERSION"
