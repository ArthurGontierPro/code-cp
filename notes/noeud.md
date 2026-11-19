# Le nœud de calcul

## La machine

Les expériences de codes-cp tournent sur fataepyc-07 (192 cœurs, 2 To de mémoire, Ubuntu 26.04). Le
dépôt y est cloné dans `/scratch/arthur/codes-cp`, qui suit `origin/main` par `git pull`. `/scratch` est
local au nœud. Le dossier personnel `/users/grad/arthur` est partagé par NFS entre les nœuds.

La machine est partagée avec d'autres expériences du même utilisateur, souvent pour des jours.
- Les re-vérifications VeriPB de `ladbug` (`/scratch/arthur/ladbug-loop3.sh` et ses `veripb p.opb
  p.pbp`, 34 Go chacun) appartiennent à une session baguette. On n'y touche pas.
- Les sessions baguette elles-mêmes tournent sur fataepyc-06. La règle « ne rien lancer sur
  fataepyc-07 » qu'on trouve dans leurs notes est la leur. Elle ne s'applique pas à codes-cp.

Avant de lancer une campagne, regarder `uptime` et `ps -u arthur`. Au plus 92 runs en parallèle.

## Les outils

| outil | chemin |
|---|---|
| MiniZinc 2.10.1 avec Chuffed (pas dans le PATH) | `/scratch/arthur/mzn/MiniZincIDE-2.10.1-x86_64-linux-gnu/bin/minizinc` |
| GCS | `/scratch/arthur/gcs/build/glasgow.msc` (par `--solver`) |
| baguette b403e28 (celle du benchmark) | `/scratch/arthur/baguette-b403e28` (branche `codes-cp-b403e28`) |
| ancienne baguette (runs de novembre) | `/scratch/arthur/golay/baguette` |
| VeriPB 3.0.2 | `~/.cargo/bin/veripb` |
| Kissat 4.0.2 | `/scratch/arthur/tools/kissat/build/kissat` |
| Python avec pysat, scipy | `/scratch/arthur/tools/venv/bin/python` |
| Python 3.12 avec dd, dwave-neal, fpylll | `/scratch/arthur/tools/bench/venv312` |
| les 25 solveurs du benchmark | `/scratch/arthur/tools/bench/<nom>`, un `VERSION` par solveur |
| Gurobi 13.0.3 | `/scratch/arthur/tools/bench/gurobi/gurobi1303` |

Gurobi tourne avec une licence académique liée à la machine, rangée dans
`/scratch/arthur/tools/bench/gurobi/lic-<hostname>/gurobi.lic` et valable jusqu'au 19/11/2027 sur
fataepyc-07. Pour un autre nœud, il faut une autre licence, obtenue avec `grbgetkey --path` sur ce
nœud depuis le réseau de l'université. Le fichier ne va jamais dans le dépôt.

Pour aplatir un modèle pour baguette, on passe sa bibliothèque à MiniZinc avec
`-c --solver /scratch/arthur/baguette-b403e28/tools/baguette.msc`, puis on lance `main.exe` sur le
`.fzn` (voir `benchmark/solvers/baguette/run.sh`).

## Où vont les sorties

- `results/runs/` : les runs des scripts `bench/` (ignoré par git, 63 Go le 19/11).
- `benchmark/instances/`, `benchmark/results/` : les instances générées et les campagnes (ignorés).
- `dom/` : les preuves fusionnées et leurs `.dzn` (les `.opb`, `.pbp` et `.dzn` sont ignorés).
- `results/` hors `runs/` : les résultats gardés dans git.
