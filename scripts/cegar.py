"""cegar.py OUT N d K FLAGS  (SOLVER=... in the environment, default chuffed) -- lazy distance: solve code.mzn with combinations <= K,
compute the code's minimum-weight word, and if it is below d add that word's row set to
E and solve again. Prints one line per round. Runs on the node."""
import os, sys, subprocess, re, time, itertools
out, n, d, K, flags = sys.argv[1], int(sys.argv[2]), int(sys.argv[3]), int(sys.argv[4]), sys.argv[5]
MZN = "/scratch/arthur/mzn/MiniZincIDE-2.10.1-x86_64-linux-gnu/bin/minizinc"
E = []
t0 = time.time()
for rnd in range(1, 100000):
    with open(f"{out}.dzn", "w") as f:
        f.write(subprocess.run(["python3", "subsets.py", str(n), str(K)], capture_output=True, text=True).stdout)
        f.write(f"nE = {len(E)};\nE = [" + ",".join("{" + ",".join(map(str, e)) + "}" for e in E) + "];\n")
    r = subprocess.run([MZN, "--solver", os.environ.get("SOLVER", "chuffed"), "-D", flags, "code.mzn", f"{out}.dzn", "--time-limit", "1800000"],
                       capture_output=True, text=True)
    m = re.search(r'\[((?:\s*(?:true|false),)+\s*(?:true|false))\]', r.stdout)
    if not m:
        print(f"round {rnd}: no solution ({'UNSAT' if 'UNSATISFIABLE' in r.stdout else 'UNKNOWN'}), {time.time()-t0:.0f} s", flush=True); break
    bits = "".join("1" if v.strip() == "true" else "0" for v in m.group(1).split(","))
    c = subprocess.run(["./mindist", str(n), str(d)], input=bits, capture_output=True, text=True).stdout.splitlines()
    new = [tuple(map(int, l.split()[1:])) for l in c if l.startswith("light")]
    new = [e for e in dict.fromkeys(new) if e not in E]
    print(f"round {rnd}: {c[-1]}, {len(new)} new light row sets, |E| {len(E)} -> {len(E)+len(new)}, {time.time()-t0:.0f} s", flush=True)
    if not new:
        print("FOUND", "A =", bits, flush=True); break
    E += new
