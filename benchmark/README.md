# Benchmark multi-paradigmes (piste 9, `notes/benchmark-plan.md`)

Des problèmes de codes et de réseaux, chacun sous plusieurs écritures, avec la réponse connue, pour
comparer le meilleur solveur de chaque paradigme. Ce dossier contient l'outillage. Les gros fichiers
d'instances et les résultats restent sur le nœud (`/scratch/arthur/codes-cp/benchmark/`), seules
les instances de test (`smoke/`) sont suivies par git.

## Organisation

| dossier | contenu |
|---|---|
| `gen/` | un générateur par famille (P1, P3, …), qui écrit la forme canonique JSON d'une instance |
| `writers/` | `write.py` : de la forme canonique vers chaque format (CNF, CNF+XOR, OPB, WCNF, LP, ASP, SMT-LIB, DZN) |
| `solvers/NOM/` | `install.sh` (installe dans `/scratch/arthur/tools/bench/NOM`, idempotent) et `run.sh` (interface commune ci-dessous) |
| `smoke/` | les instances de test de chaque format (Golay), avec leur réponse attendue |
| `run/` | le lanceur commun et la collecte des résultats |

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
