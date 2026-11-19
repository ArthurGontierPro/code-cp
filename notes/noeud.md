# Le nœud de calcul

## La machine

Les expériences de codes-cp tournent sur fataepyc-07 (192 cœurs, 2 To de mémoire, Ubuntu 26.04). Le
dépôt y est cloné dans `/cluster/arthur/codes-cp`, qui suit `origin/main` par `git pull` (voir plus bas
pourquoi `/cluster` et pas `/scratch`). `/scratch` est local au nœud. Le dossier personnel `/users/grad/arthur` est partagé par NFS entre les nœuds.

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
`/cluster/arthur/licences/gurobi/lic-<hostname>/gurobi.lic` (mode 700) et valable jusqu'au 19/11/2027 sur
fataepyc-07. Pour un autre nœud, il faut une autre licence, obtenue avec `grbgetkey --path` sur ce
nœud depuis le réseau de l'université. Le fichier ne va jamais dans le dépôt.

Pour aplatir un modèle pour baguette, on passe sa bibliothèque à MiniZinc avec
`-c --solver /scratch/arthur/baguette-b403e28/tools/baguette.msc`, puis on lance `main.exe` sur le
`.fzn` (voir `benchmark/solvers/baguette/run.sh`).

## /cluster pour vivre, /scratch pour calculer

`/cluster` (NFS, partagé par le groupe, permanent, plus lent) porte le dépôt,
`/cluster/arthur/codes-cp`. On y lit, on y écrit le code et les notes, et les résultats légers y
restent (les lignes `.res`, les modèles gzippés des runs, les tableaux).

`/scratch` (13 To, local au nœud, rapide) peut être effacé par une réinstallation ou une panne. On y
compile et on y lance. Tout ce qui est lourd ou se régénère y va, sous `/scratch/arthur/codes-cp-work`
(variable `WORK`) :
- `runs/` : les FlatZinc, les `.opb` et les preuves des runs de `bench/run1.sh` et `bench/rs1.sh`.
  Le `.pbp` est supprimé après vérification, sauf si `KEEP` est posé, et il reste alors sur `/scratch`.
- `benchmark/instances/`, `benchmark/logs/` : les instances générées et les sorties des solveurs du
  benchmark. Les `.res` vont dans `benchmark/results/` sur `/cluster`.
- `bin/` : les binaires compilés du dépôt (`mindist2`).
- `dom/` : les preuves fusionnées de la chaîne de dominance (les `.dzn` et `.json` restent dans `dom/`).

Aucune preuve n'est gardée sur `/cluster`, sauf les petites preuves de test suivies par git
(`notes/dominance/`, `benchmark/smoke/`). Les solveurs sont compilés dans `/scratch/arthur/tools` et se
réinstallent avec leurs `benchmark/solvers/*/install.sh`. La licence Gurobi est sur `/cluster` parce
qu'elle ne se régénère pas sans `grbgetkey`.

Le 19/11, les résultats légers de l'ancien clone sur `/scratch` ont été recopiés dans le dépôt sur
`/cluster`, puis ce clone a été supprimé avec ses preuves.

## Ce qui est ignoré par git mais gardé sur /cluster

- `results/runs/` : les `.res`, `.log`, `.sol` et les modèles gzippés (`.fzn.gz`, `.opb.gz`) des runs.
- `benchmark/results/` : les `.res` des campagnes.
- `dom/` : les `.dzn` et `.json` des modèles symétriques.
- `papers/` et les PDF, `external/` (le dépôt de l'article AAAI-26).
