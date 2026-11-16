# codes-cp

Searching binary linear codes with constraint solvers (Chuffed, GCS, baguette with VeriPB
proofs). Started 2026-11-16 from baguette's `docs/ideas/` (Golay / q48 experiments).

- `models/`   MiniZinc models. `code.mzn` (self-dual doubly-even [2n,n,d], commented
              in French), `golay.mzn` (the n=12 stand-alone version).
- `scripts/`  data generator (`subsets.py`), checkers (`check.py` numpy, `mindist.c`
              exact two-halves search for self-dual codes), lazy loop (`cegar.py`),
              node runners (`ch.sh` Chuffed/GCS, `bagq.sh` baguette + veripb).
              The runners assume the node layout `/scratch/arthur/golay` (to be moved).
- `notes/`    `golay-leech-model.md` (ideas, results, bibliography, comparison with
              the AAAI-26 paper). The AAAI-26 paper PDF is kept locally only (not redistributed): https://github.com/veinamond/AAAI-2026-Codes
- `external/` third-party code, NOT tracked: `AAAI-2026-Codes` cloned from
              https://github.com/veinamond/AAAI-2026-Codes at 4c5b8dc.
- `results/`  run outputs worth keeping.

All experiments run on fataepyc-07, never on the laptop.
