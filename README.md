# codes-cp

Des solveurs de contraintes, avec journal de preuve, pour les empilements de sphères en dimension
24k. Le but est de certifier des résultats connus sur les réseaux extrémaux et les codes qui les
construisent (Leech, P48, codes QR), puis d'attaquer une question ouverte, l'existence d'un code
binaire auto-dual doublement pair [72, 36, 16].

Les solveurs utilisés sont Chuffed (rapide, sans preuve), GCS (Glasgow Constraint Solver, avec preuve
VeriPB), baguette (notre solveur, toujours avec preuve, gardé dans chaque comparaison parce que ses
échecs ont trouvé de vrais bugs) et Kissat (SAT pur, pour le benchmark AAAI-26).

## Par où commencer

1. `RESULTS.md`, partie 1. Un tutoriel pour un étudiant de master, qui part des empilements de sphères
   et suit un seul exemple, le code de Hamming étendu [8, 4, 4], jusqu'au réseau E8 et aux modèles.
2. `RESULTS.md`, partie 2. Le tableau de toutes les expériences, avec ce que chaque résultat veut
   dire, et la section E qui liste ce que les preuves admettent.
3. Les en-têtes des modèles, dans l'ordre `minweight.mzn`, `minweight_fix.mzn`, `shortvec.mzn`,
   `aut.mzn`. Chacun explique en français ce qu'il cherche et pourquoi c'est correct.
4. `notes/lattices-literature.md` pour l'état de l'art, `notes/aut-order-p.md` pour le modèle
   d'automorphismes.

## Ce qu'il y a dans le dépôt

### models/

| fichier | rôle |
|---|---|
| `minweight.mzn` | un mot de poids ≤ Wmax dans un code binaire fixé (Golay, QR48 à QR104). UNSAT certifie la distance. Options des deux moitiés (HALF) et du découpage en cas (FIRST, SECOND, THIRD). |
| `minweight_fix.mzn` | le même, avec des coordonnées imposées dans le support du mot, ce qui est permis par les symétries du code (PSL(2, p) est 3-homogène). |
| `shortvec.mzn` | un vecteur court dans un réseau construit à partir d'un code (Leech, P48p, P48q). UNSAT certifie le minimum. |
| `aut.mzn` | un code [n, n/2, d] auto-dual doublement pair invariant par une permutation d'ordre premier p. Sert à reproduire les exclusions de la littérature et à chercher le [72, 36, 16]. |
| `code.mzn`, `golay.mzn` | la première approche (16/11), qui cherche le code lui-même, matrice génératrice en inconnue. Retrouve Golay, pas QR48 sans hypothèse. Gardés pour les explications. |
| `linear.mzn` | la formulation du benchmark AAAI-26 (codes linéaires quelconques), reproduite pour comparer. |

### scripts/

| fichier | rôle |
|---|---|
| `gen_instances.py` | construit les codes QR et les réseaux, vérifie ce qu'il affirme (auto-dual, doublement pair, A·Aᵀ = ±I), écrit les `.dzn` dans `instances/` (non suivi par git, à régénérer). |
| `mindist.c` | distance minimale exacte d'un code auto-dual, par l'argument des deux moitiés. Sert de juge indépendant. |
| `autcegar.py`, `autcheck.py` | la boucle paresseuse du modèle d'automorphismes, et la vérification indépendante d'un code trouvé. |
| `equivcount.py` | les tests d'équivalence par énumération (RESULTS.md, section E). |
| les autres | les scripts de la première journée (16/11), écrits pour l'ancien dossier `/scratch/arthur/golay` du nœud. Historiques, chacun le dit dans son en-tête. |

### bench/

`run1.sh` lance un run (Chuffed, GCS, GCS avec preuve ou baguette) et garde le `.fzn` et le `.opb`
compressés à côté du résultat. Les autres scripts lancent chacun un bloc du tableau, et leur en-tête
dit lequel. `launch.sh`, `job.sh` et `instances.csv` forment le benchmark AAAI-26.

### Le reste

- `notes/` : la littérature, le modèle d'automorphismes, les idées de départ (`golay-leech-model.md`).
- `fzn/make.sh` : régénère le FlatZinc que reçoit chaque solveur, pour le lire.
- `results/` : les résultats gardés dans git. Les runs eux-mêmes restent sur le nœud.
- `external/` (non suivi) : le dépôt de l'article AAAI-26, https://github.com/veinamond/AAAI-2026-Codes,
  à 4c5b8dc. Les PDF sont gardés localement et ne sont pas redistribués.

## Où ça tourne

Toutes les expériences tournent sur fataepyc-07, dans `/scratch/arthur/codes-cp`, un clone de ce dépôt
mis à jour par `git pull`. La machine, ses outils et ses règles sont décrits dans `notes/noeud.md`.
Une session Claude commence par `CLAUDE.md`, puis `notes/etat.md`.
