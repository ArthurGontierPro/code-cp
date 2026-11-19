#!/bin/bash
# install.sh -- the shared Python 3.12 venv /scratch/arthur/tools/bench/venv312 for the
# coordinator's own Python solvers (not a solver: no run.sh). Python 3.12 comes from uv, because
# several of these packages have no wheel for the node's Python 3.14. Idempotent.
set -e
PKGS="dd==0.6.0 dwave-neal==0.6.0 dwave-samplers==1.8.0 dimod==0.12.23 fpylll==0.6.4 cysignals==1.12.6 numpy==2.5.5 networkx==3.7 highspy==1.16.0 pyscipopt==6.3.0 clingo==5.8.3 z3-solver==5.4.1.0 cvc5==1.4.2"
B=/scratch/arthur/tools/bench
export UV_CACHE_DIR=$B/uv/cache UV_PYTHON_INSTALL_DIR=$B/uv/python UV_PYTHON_BIN_DIR=$B/uv/pybin UV_NO_MODIFY_PATH=1
[ -x $B/uv/bin/uv ] || curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR=$B/uv/bin UV_NO_MODIFY_PATH=1 INSTALLER_NO_MODIFY_PATH=1 sh >/dev/null
UV=$B/uv/bin/uv
V=$B/venv312
[ -x $V/bin/python ] || $UV venv -q --python 3.12 $V
$UV pip install -q --python $V/bin/python $PKGS
$V/bin/python -I -c "
import dd.autoref, dd.cudd, neal, dwave.samplers, dimod, fpylll, highspy, pyscipopt, clingo, z3, cvc5
from fpylll import IntegerMatrix, LLL
A = IntegerMatrix.random(8, 'uniform', bits=8); LLL.reduction(A)
b = dd.cudd.BDD(); b.declare('x', 'y'); assert b.add_expr(r'x /\ y') != b.false
s = neal.SimulatedAnnealingSampler().sample_qubo({(0, 0): -1, (0, 1): 2, (1, 1): -1}, num_reads=10)
print('imports ok: dd (with dd.cudd), neal, dwave.samplers, fpylll, highspy, pyscipopt, clingo, z3, cvc5; qubo min', s.first.energy)
"
{ echo "venv: $V, $($V/bin/python -V)"; $UV pip freeze --python $V/bin/python; } > $V/VERSION
