#!/bin/bash
# Nothing to install: dp.py is plain Python 3. Records the version of the code.
mkdir -p /scratch/arthur/tools/bench/trellis-dp && sha256sum "$(dirname "$0")/dp.py" > /scratch/arthur/tools/bench/trellis-dp/VERSION
