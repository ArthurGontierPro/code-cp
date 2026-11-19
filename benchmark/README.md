# Benchmark multi-paradigmes (piste 9, `notes/benchmark-plan.md`)

Des problèmes de codes et de réseaux, chacun sous plusieurs écritures, avec la réponse connue, pour
comparer le meilleur solveur de chaque paradigme. Ce dossier contient l'outillage. Les instances
générées et les logs des solveurs vont sur `/scratch/arthur/codes-cp-work/benchmark/`, les `.res` dans
`benchmark/results/` du dépôt sur `/cluster`. Seules les instances de test (`smoke/`) sont suivies par git.

## Organisation

| dossier | contenu |
|---|---|
| `gen/` | un générateur par famille (P1, P3, …), qui écrit la forme canonique JSON d'une instance |
| `writers/` | `write.py` : de la forme canonique vers chaque format (CNF, CNF+XOR, OPB, WCNF, LP, ASP, SMT-LIB, DZN) |
| `solvers/NOM/` | `install.sh` (installe dans `/scratch/arthur/tools/bench/NOM`, idempotent) et `run.sh` (interface commune ci-dessous) |
| `smoke/` | les instances de test de chaque format (Golay), avec leur réponse attendue |
| `run/` | `smoke.sh` (tous les solveurs sur les instances de test), puis le lanceur commun et la collecte des résultats |

## La forme canonique (famille P1, distance minimale)

Un fichier JSON :

```json
{"family": "P1", "name": "golay24_w4", "field": 2, "n": 24, "k": 12,
 "checks": [[0,1,...], ...],        "rows of a parity-check matrix H: x is a codeword iff H x = 0",
 "wmax": 4, "fixed": [],            "coordinates (0-based) imposed in the support, by clauses",
 "expected": "UNSAT", "expected_opt": 8, "source": "d(Golay) = 8"}
```

La question de décision est « existe-t-il x ≠ 0 avec H x = 0 et poids(x) ≤ wmax ? ». La version
optimisation (MaxSAT, MILP, ASP, DP) est « minimiser poids(x) avec x ≠ 0 et H x = 0 », de réponse d.

## Les formats et ce qu'ils contiennent

| extension | format | parité | borne de poids | pour |
|---|---|---|---|---|
| `.cnf` | DIMACS | chaînes de XOR en clauses (Tseitin) | totaliseur | SAT, #SAT, recherche locale |
| `.xnf` | DIMACS avec lignes `x` | XOR natifs | totaliseur | CryptoMiniSat |
| `.opb` | OPB | Σ h·x − 2·(y en binaire) = 0 | inégalité linéaire | PB |
| `.wcnf` | WCNF 2022 (`h` pour les dures) | XOR en clauses, dures | x_i faux, souples de poids 1 | MaxSAT (optimisation) |
| `.lp` | LP de CPLEX | Σ h·x − 2y = 0, y entier | linéaire (ou objectif) | MILP |
| `.asp` | clingo | `#count` pair | `#count` ≤ wmax (ou `#minimize`) | ASP |
| `.smt2` | SMT-LIB, QF_LIA | `xor` n-aire | somme de `ite` | SMT |
| `.dzn` | MiniZinc, pour `models/minweight_chk.mzn` (ENC 1 ou 2) | XOR ou sommes | linéaire | CP, MILP par MiniZinc |
| `.json` | la forme canonique | | | programmation dynamique sur treillis |

## L'interface des solveurs

`solvers/NOM/run.sh INPUT TIMELIMIT_S` lance le solveur sur un fichier du format qu'il attend,
recopie sa sortie, et finit par une ligne unique

```
RESULT status=SAT|UNSAT|OPTIMUM|UNKNOWN|ERROR value=<objectif ou -> time=<secondes>
```

`solvers/NOM/install.sh` installe le solveur dans `/scratch/arthur/tools/bench/NOM` (jamais
ailleurs), sans droits root, et écrit sa version exacte (tag ou commit, sha256 du binaire) dans
`/scratch/arthur/tools/bench/NOM/VERSION`. `solvers/NOM/INFO` dit en une ligne le paradigme, le
format d'entrée et ce que le solveur sait prouver.

## État au 19/11

24 solveurs sont installés sur le nœud. `run/smoke.sh` les lance tous sur les instances de test,
et les 91 runs donnent la réponse attendue (`run/smoke-result.txt`).

| paradigme | solveurs (dossier `solvers/`) | entrée | preuve possible |
|---|---|---|---|
| SAT | kissat 4.0.2, cadical 3.1.0 | .cnf | DRAT, LRAT |
| SAT avec XOR | cryptominisat 5.18.0 | .xnf, .cnf | XLRUP, vérifiée par cake_xlrup (CakeML), installé |
| recherche locale | yalsat | .cnf | aucune (SAT seulement) |
| PB | roundingsat, exact | .opb | VeriPB |
| MaxSAT | uwrmaxsat 2.0.6, evalmaxsat | .wcnf | aucune ici |
| comptage | ganak 2.9.0, gpmc 1.2.0 (comptage projeté) | .cnf avec `c p show` | aucune |
| CP avec apprentissage | chuffed, cpsat (OR-Tools 9.15), pumpkin, huub, baguette b403e28 | .dzn (MiniZinc) | DRCP pour pumpkin (son propre format), VeriPB pour baguette |
| CP sans apprentissage | gecode, gcs | .dzn | VeriPB pour gcs |
| MILP | highs (1.16 seul, 1.15 par MiniZinc), scip 10.0, gurobi 13.0.3 | .lp, .dzn | aucune ici (SCIP exact donnerait VIPR) |
| ASP | clingo 5.8.3 | .asp | aucune |
| SMT | z3, cvc5 1.4.2 | .smt2 | cvc5 peut en produire (non activé) |
| programmation dynamique | trellis-dp (le nôtre, Python) | .json | le calcul lui-même |

À savoir :
- `solvers/common.sh` regroupe les fonctions partagées (version, GMP, ligne RESULT).
- `solvers/venv312` reconstruit l'environnement Python 3.12 (`/scratch/arthur/tools/bench/venv312`),
  qui contient dd (BDD avec CUDD), dwave-neal (recuit pour le QUBO) et fpylll (réseaux).
- Les solveurs MiniZinc prennent `INPUT.dzn TL [ENC]`. `ENC` vaut 1 (XOR) ou 2 (sommes) pour
  `minweight_chk.mzn`, et `-` pour un modèle sans ENC (`MODEL=.../linear.mzn` pour P3).
- Gurobi tourne avec une licence académique liée à la machine. Le fichier est
  `/cluster/arthur/licences/gurobi/lic-<hostname>/gurobi.lic` (obtenu avec `grbgetkey --path`, jamais commité),
  valable jusqu'au 19/11/2027 sur fataepyc-07.
- Bitwuzla (pas d'arithmétique entière) et msolve (FLINT manquant) ne sont pas installés.

## Lancer et lire une campagne

Tout se fait sur le nœud, depuis `benchmark/` dans le dépôt sur `/cluster`, avec
`PY=/scratch/arthur/tools/venv/bin/python` et `W=/scratch/arthur/codes-cp-work`.

1. `$PY gen/phase1.py $W/benchmark/instances/phase1` construit les 115 instances de la phase 1 et leur
   `MANIFEST.tsv`. Chaque réponse P1 est d'abord recalculée à partir des seules matrices de parité
   par `verify/verify_p1.py` (énumération sur deux ensembles d'information, `verify/mindist2.c`,
   compilé sur `/scratch` avec
   `gcc -O3 -march=native -fopenmp -o $W/bin/mindist2 verify/mindist2.c`). Un désaccord arrête tout.
2. `$PY run/jobs.py $W/benchmark/instances/phase1 > $W/benchmark/phase1-jobs.tsv` écrit un run par ligne
   (instance, écriture, solveur).
3. `setsid nohup bash run/campaign.sh $W/benchmark/phase1-jobs.tsv results/phase1-p1 600 92 &` lance
   92 runs à la fois, chacun dans son scope systemd avec `MemoryMax=32G`. Un run déjà fait (son `.res`
   existe) est sauté, donc relancer la même commande après avoir ajouté un solveur ne lance que ses
   runs. Les `.res` restent dans `results/phase1-p1` sur `/cluster`, les logs des solveurs vont dans
   `$W/benchmark/logs/phase1-p1`. Le PID du lanceur est dans `results/phase1-p1/pid`, et `results/phase1-p1/done` apparaît à
   la fin. L'arrêt se fait par ce PID, puis par les scopes `b1-*` (voir l'en-tête de `campaign.sh`).
4. `$PY run/score.py results/phase1-p1 600` donne, par solveur et par écriture, les runs, les
   instances résolues, les réponses fausses et le PAR-2. `run/best.py` donne le meilleur solveur par
   groupe d'instances et par écriture.

État au 19/11 au soir : la première passe est faite (2 687 runs, Gurobi et `baguette-act` compris,
aucune réponse fausse). Le résumé est dans `notes/etat.md`.
