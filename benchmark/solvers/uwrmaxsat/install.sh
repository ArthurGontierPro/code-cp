#!/usr/bin/env bash
# uwrmaxsat: UWrMaxSat v2.0.6 (github.com/marekpiotrow/UWrMaxSat), the build of its README "Quick
# Install": CaDiCaL as SAT solver (patched with uwrmaxsat/cadical.patch), MaxPre preprocessor,
# COMiniSatPS for headers, WITHOUT SCIP (USESCIP= ; the optional SCIP/SoPlex LP back end is a
# large separate build). Its Makefile always links -lgmp: GMP comes from $BENCH_ROOT/gmp.
set -euo pipefail
source "$(dirname "$(readlink -f "$0")")/../common.sh"
D=$(bench_dir uwrmaxsat)
ensure_gmp
G=$BENCH_ROOT/gmp
mkdir -p "$D/src"; cd "$D/src"
U=$(git_pin uwrmaxsat https://github.com/marekpiotrow/UWrMaxSat v2.0.6)
C=$(git_pin cadical https://github.com/arminbiere/cadical rel-3.1.0)
M=$(git_pin cominisatps https://github.com/marekpiotrow/cominisatps f5a634f34eaefee40c043c2ca8062471b07650fa)
P=$(git_pin maxpre https://github.com/Laakeri/maxpre 721f5dd129a7d50bda2d1b0d6729877ac1d3d768)
if [ ! -x "$D/uwrmaxsat" ]; then
  {
    set -x
    cd "$D/src/cominisatps" && rm -rf core simp mtl utils && ln -s minisat/core minisat/simp minisat/mtl minisat/utils .
    cd "$D/src/cadical" && git checkout -q . && patch -p1 < ../uwrmaxsat/cadical.patch
    ./configure --no-contracts --no-tracing && make -j"$NJOBS" cadical
    cd "$D/src/maxpre" && git checkout -q . && sed -i 's/-g/-D NDEBUG/' src/Makefile && make -j"$NJOBS" lib
    cd "$D/src/uwrmaxsat" && cp config.cadical config.mk && make clean
    MAXPRE="-D MAXPRE" USESCIP= make -j"$NJOBS" r \
      MINISAT_INCLUDE="-I../cominisatps -I../cadical/src -I$G/include" \
      MINISAT_LIB="-L../cadical/build -lcadical -L$G/lib"
  } > "$D/build.log" 2>&1 || { echo "build failed, see $D/build.log" >&2; exit 1; }
  cp "$D/src/uwrmaxsat/build/release/bin/uwrmaxsat" "$D/uwrmaxsat"
fi
write_version uwrmaxsat "$D/uwrmaxsat" "UWrMaxSat v2.0.6 commit $U; CaDiCaL rel-3.1.0 $C (+cadical.patch); COMiniSatPS $M; MaxPre $P; no SCIP; GMP 6.3.0"
