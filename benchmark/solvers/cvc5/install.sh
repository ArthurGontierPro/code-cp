#!/bin/bash
# install.sh -- cvc5 official static release binary (tag below) into /scratch/arthur/tools/bench/cvc5.
set -e
TAG=cvc5-1.4.2
D=/scratch/arthur/tools/bench/cvc5; mkdir -p "$D"
if [ ! -x "$D/bin/cvc5" ]; then
  curl -fsSL -o "$D/cvc5.zip" "https://github.com/cvc5/cvc5/releases/download/$TAG/cvc5-Linux-x86_64-static.zip"
  rm -rf "$D/unz"; mkdir "$D/unz"; (cd "$D/unz" && unzip -q ../cvc5.zip)
  mkdir -p "$D/bin"; cp "$(find "$D/unz" -type f -path '*/bin/cvc5' | head -1)" "$D/bin/cvc5"; chmod +x "$D/bin/cvc5"
fi
{ echo "solver: $("$D/bin/cvc5" --version | head -1) (release $TAG, Linux-x86_64-static)"
  echo "zip sha256: $(sha256sum "$D/cvc5.zip" | cut -d' ' -f1)"
  echo "cvc5 sha256: $(sha256sum "$D/bin/cvc5" | cut -d' ' -f1)"; } > "$D/VERSION"
cat "$D/VERSION"
