# Shared helpers for solvers/NOM/{install.sh,run.sh}. Sourced, never executed.
#
# install side:  bench_dir NOM, write_version NOM BIN "pin text", ensure_gmp
# run side:      run_solver BIN ARGS...  then  emit_result [status] [value]
#
# All installs live under /scratch/arthur/tools/bench (README.md, "L'interface des solveurs").

BENCH_ROOT=${BENCH_ROOT:-/scratch/arthur/tools/bench}
NJOBS=${NJOBS:-16}   # node rule: make -j16 at most

# ---------------------------------------------------------------- install side

bench_dir() { mkdir -p "$BENCH_ROOT/$1" && echo "$BENCH_ROOT/$1"; }

# write_version NOM BIN PIN...   -> $BENCH_ROOT/NOM/VERSION
write_version() {
  local name=$1 bin=$2; shift 2
  {
    echo "name: $name"
    echo "pin: $*"
    echo "binary: $bin"
    echo "sha256: $(sha256sum "$bin" | cut -d' ' -f1)"
    echo "installed: $(date -u +%Y-%m-%dT%H:%M:%SZ) on $(hostname)"
  } > "$BENCH_ROOT/$name/VERSION"
  cat "$BENCH_ROOT/$name/VERSION"
}

# git_pin DIR URL REF : clone once, then check out REF (tag or commit), print the commit.
git_pin() {
  local dir=$1 url=$2 ref=$3
  [ -d "$dir/.git" ] || git clone -q "$url" "$dir" || return 1
  git -C "$dir" -c advice.detachedHead=false checkout -q "$ref" || return 1
  git -C "$dir" rev-parse HEAD
}

# GMP 6.3.0, built once into $BENCH_ROOT/gmp and reused (UWrMaxSat, GPMC).
# sha256 of gmp-6.3.0.tar.xz; the tarball is also checked against its GnuPG signature
# with the GNU keyring (key 343C2FF0FBEE5EC2EDBEF399F3599FF828C67298, Niels Moeller).
GMP_SHA256=a3c2b80201b89e68616f4ad30bc66aee4927c3ce50e33929ca819d5c43538898
ensure_gmp() {
  local g=$BENCH_ROOT/gmp
  if [ -f "$g/lib/libgmp.a" ] && [ -f "$g/include/gmpxx.h" ]; then return 0; fi
  mkdir -p "$g/dl" && cd "$g/dl" || return 1
  [ -f gmp-6.3.0.tar.xz ] || curl -sSLO https://gmplib.org/download/gmp/gmp-6.3.0.tar.xz || return 1
  [ -f gmp-6.3.0.tar.xz.sig ] || curl -sSLO https://ftp.gnu.org/gnu/gmp/gmp-6.3.0.tar.xz.sig || return 1
  [ -f gnu-keyring.gpg ] || curl -sSLO https://ftp.gnu.org/gnu/gnu-keyring.gpg || return 1
  echo "$GMP_SHA256  gmp-6.3.0.tar.xz" | sha256sum -c - || { echo "GMP sha256 MISMATCH" >&2; return 1; }
  gpgv --keyring ./gnu-keyring.gpg gmp-6.3.0.tar.xz.sig gmp-6.3.0.tar.xz || { echo "GMP signature BAD" >&2; return 1; }
  # GMP's configure needs m4, which the node lacks: build GNU m4 (signature-checked) into gmp/m4.
  if ! command -v m4 >/dev/null && [ ! -x "$g/m4/bin/m4" ]; then
    [ -f m4-1.4.21.tar.xz ] || curl -sSLO https://ftp.gnu.org/gnu/m4/m4-1.4.21.tar.xz || return 1
    [ -f m4-1.4.21.tar.xz.sig ] || curl -sSLO https://ftp.gnu.org/gnu/m4/m4-1.4.21.tar.xz.sig || return 1
    gpgv --keyring ./gnu-keyring.gpg m4-1.4.21.tar.xz.sig m4-1.4.21.tar.xz || { echo "m4 signature BAD" >&2; return 1; }
    rm -rf "$g/m4-src" && mkdir -p "$g/m4-src" && tar -xJf m4-1.4.21.tar.xz -C "$g/m4-src" --strip-components=1 || return 1
    ( cd "$g/m4-src" && ./configure --prefix="$g/m4" && make -j"$NJOBS" && make install ) > "$g/m4-build.log" 2>&1 \
      || { echo "m4 build failed, see $g/m4-build.log" >&2; return 1; }
  fi
  [ -x "$g/m4/bin/m4" ] && export PATH="$g/m4/bin:$PATH"
  rm -rf "$g/src" && mkdir -p "$g/src" && tar -xJf gmp-6.3.0.tar.xz -C "$g/src" --strip-components=1 || return 1
  cd "$g/src" || return 1
  # gcc 15 defaults to C23, where GMP 6.3.0's configure tests fail; force gnu17.
  ( CFLAGS="-O2 -std=gnu17" ./configure --prefix="$g" --enable-cxx --with-pic \
      && make -j"$NJOBS" && make check -j"$NJOBS" && make install ) > "$g/build.log" 2>&1 \
    || { echo "GMP build failed, see $g/build.log" >&2; return 1; }
  { echo "name: gmp"; echo "pin: gmp-6.3.0.tar.xz sha256 $GMP_SHA256 (gpgv good signature)";
    echo "installed: $(date -u +%Y-%m-%dT%H:%M:%SZ)"; } > "$g/VERSION"
}

# ---------------------------------------------------------------- run side
#
# run_solver BIN ARGS...
#   runs under `timeout` with a hard limit of TIMELIMIT+GRACE (the solver's own limit, when it
#   has one, is set to TIMELIMIT by the caller), copies its output to stdout and to $OUTFILE,
#   and sets RC and ELAPSED.

GRACE=${GRACE:-10}

run_init() {   # run_init "$@"  -> INPUT, TIMELIMIT, OUTFILE
  INPUT=${1:?usage: run.sh INPUT TIMELIMIT_S}
  TIMELIMIT=${2:-${TIMELIMIT:-60}}
  OUTFILE=$(mktemp "${TMPDIR:-/tmp}/bench-run.XXXXXX")
  trap 'rm -f "$OUTFILE"' EXIT
  [ -r "$INPUT" ] || { echo "cannot read $INPUT" >&2; echo "RESULT status=ERROR value=- time=0"; exit 1; }
}

run_solver() {
  local t0 t1
  t0=$(date +%s.%N)
  timeout -k 5 "$((TIMELIMIT + GRACE))" "$@" 2>&1 | tee "$OUTFILE"
  RC=${PIPESTATUS[0]}
  t1=$(date +%s.%N)
  ELAPSED=$(awk -v a="$t0" -v b="$t1" 'BEGIN{printf "%.2f", b-a}')
}

# status from the competition `s` line; ERROR when the process crashed without one.
s_status() {
  local s
  s=$(grep -m1 -E '^s ' "$OUTFILE" | sed 's/^s  *//; s/ *$//')
  case "$s" in
    SATISFIABLE)        echo SAT ;;
    UNSATISFIABLE)      echo UNSAT ;;
    "OPTIMUM FOUND")    echo OPTIMUM ;;
    *)                  if [ -z "$s" ] && crashed; then echo ERROR; else echo UNKNOWN; fi ;;
  esac
}

# exit codes that are not a crash: 0, 10 (SAT), 20 (UNSAT), 30 (optimum, some MaxSAT solvers),
# 124/137 (our timeout fired), 143 (SIGTERM from timeout).
crashed() { case "$RC" in 0|10|20|30|124|137|143) return 1 ;; *) return 0 ;; esac; }

last_o() { grep -E '^o ' "$OUTFILE" | tail -1 | awk '{print $2}'; }

emit_result() {   # emit_result STATUS [VALUE]
  echo "RESULT status=$1 value=${2:--} time=$ELAPSED"
}
