#!/usr/bin/env python3
"""dp.py CANON.json [opt|count] -- dynamic programming on the syndrome trellis of a binary code.

The word x is read one coordinate at a time. The state after i coordinates is the partial
syndrome s = H[:, :i] x[:i] (a bit mask over the parity checks), and setting x_i = 1 adds column i
of H. A codeword is a path from s = 0 back to s = 0. For each state we keep the smallest weight of a
nonzero path (and of the zero path), and states heavier than the bound are dropped. This is the
Viterbi algorithm on the Wolf trellis. The number of states per layer is at most 2^(n-k), and in
practice it is limited by the weight bound.
  default: decide "exists x != 0, H x = 0, weight <= wmax"   -> SAT / UNSAT
  opt:     minimum weight of a nonzero codeword               -> OPTIMUM value=d
  count:   number of codewords of weight exactly count_weight -> value=count
Fixed coordinates of the canonical form are honoured (they must be 1)."""
import sys, json, time

t0 = time.time()
I = json.load(open(sys.argv[1])); mode = sys.argv[2] if len(sys.argv) > 2 else "decide"
n, H = I["n"], I["checks"]
col = [sum(H[r][i] << r for r in range(len(H))) for i in range(n)]
fixed = set(I["fixed"])
if mode == "count":
    W = I["count_weight"]
    layer = {0: [1] + [0] * W}                       # syndrome -> counts by weight 0..W
    for i in range(n):
        new = {}
        for s, cnt in layer.items():
            if i not in fixed:
                a = new.setdefault(s, [0] * (W + 1))
                for t in range(W + 1):
                    a[t] += cnt[t]
            b = new.setdefault(s ^ col[i], [0] * (W + 1))
            for t in range(W):
                b[t + 1] += cnt[t]
        layer = new
    v = layer.get(0, [0] * (W + 1))[W]
    print(f"c states_last_layer {len(layer)}")
    print(f"RESULT status=SAT value={v} time={time.time() - t0:.2f}")
    sys.exit()
bound = n if mode == "opt" else I["wmax"]
INF = n + 1
layer = {(0, False): 0}                              # (syndrome, nonzero) -> minimum weight
peak = 1
for i in range(n):
    new = {}
    for (s, nz), wt in layer.items():
        if i not in fixed and new.get((s, nz), INF) > wt:
            new[(s, nz)] = wt
        if wt + 1 <= bound:
            key = (s ^ col[i], True)
            if new.get(key, INF) > wt + 1:
                new[key] = wt + 1
    layer = new; peak = max(peak, len(layer))
best = layer.get((0, True))
print(f"c peak_states {peak}")
t = time.time() - t0
if mode == "opt":
    print(f"RESULT status=OPTIMUM value={best} time={t:.2f}")
else:
    print(f"RESULT status={'SAT' if best is not None else 'UNSAT'} value=- time={t:.2f}")
