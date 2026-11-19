#!/usr/bin/env bash
# exact: the PB solver by Jo Devriendt (gitlab.com/JoD/exact), pinned to master commit b921cd1c
# (2026-06-06, 306 commits after the last tag 2.1.0). Built WITHOUT SoPlex (optional) and without
# CoinUtils. Exact asks for find_package(Boost CONFIG): cmake 4 has no FindBoost and the unpacked
# Boost 1.84 headers ship no BoostConfig.cmake, so a 10-line header-only config is written here.
set -euo pipefail
source "$(dirname "$(readlink -f "$0")")/../common.sh"
D=$(bench_dir exact)
REF=b921cd1c4e3b6a7b7ba16dfd9c38c419d5e53ee4
COMMIT=$(git_pin "$D/src" https://gitlab.com/JoD/exact.git "$REF")
BOOST=/scratch/arthur/tools/boost_1_84_0
mkdir -p "$D/boost-config"
cat > "$D/boost-config/BoostConfig.cmake" <<CFG
# header-only Boost 1.84 at $BOOST (written by benchmark/solvers/exact/install.sh)
set(Boost_FOUND TRUE)
set(Boost_VERSION 1.84.0)
set(Boost_MAJOR_VERSION 1)
set(Boost_MINOR_VERSION 84)
set(Boost_INCLUDE_DIRS $BOOST)
set(Boost_LIBRARIES "")
if(NOT TARGET Boost::headers)
  add_library(Boost::headers INTERFACE IMPORTED)
  set_target_properties(Boost::headers PROPERTIES INTERFACE_INCLUDE_DIRECTORIES $BOOST)
endif()
CFG
cat > "$D/boost-config/BoostConfigVersion.cmake" <<'CFG'
set(PACKAGE_VERSION 1.84.0)
if(PACKAGE_FIND_VERSION VERSION_GREATER PACKAGE_VERSION)
  set(PACKAGE_VERSION_COMPATIBLE FALSE)
else()
  set(PACKAGE_VERSION_COMPATIBLE TRUE)
endif()
CFG
if [ ! -x "$D/exact" ]; then
  rm -rf "$D/build"; mkdir -p "$D/build"
  ( cd "$D/build" && cmake "$D/src" -DCMAKE_BUILD_TYPE=Release -Dsoplex=OFF -Dcoinutils=OFF \
        -DBoost_DIR="$D/boost-config" && make -j"$NJOBS" ) > "$D/build.log" 2>&1 \
    || { echo "build failed, see $D/build.log" >&2; exit 1; }
  cp "$D/build/Exact" "$D/exact"
fi
write_version exact "$D/exact" "commit $COMMIT (gitlab.com/JoD/exact master), soplex=OFF coinutils=OFF, Boost 1.84 headers"
