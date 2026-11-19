# Plan : un benchmark de codes et de réseaux pour comparer les paradigmes de résolution

Idée du 19/11, à faire plus tard (ROADMAP, piste 9). Le but est double. Il s'agit de trouver le
meilleur solveur pour chaque type de modèle, et de comparer les paradigmes entre eux, y compris ceux
qu'on croit inutiles. Ce fichier liste les problèmes, leurs modèles, les paradigmes avec leurs
meilleurs solveurs, puis la méthode et les phases. Les points marqués « à vérifier » sont des
souvenirs à contrôler avant de s'en servir.

Ce qui rend ce benchmark intéressant tient en trois points.

- La réponse est connue pour presque toutes les instances (énumérateurs de poids, tables de
  bornes, classifications, séries thêta). Chaque solveur est donc vérifié, et pas seulement
  chronométré. Une mauvaise réponse est un bug trouvé.
- Les familles sont graduées, du code de 8 bits jusqu'aux questions ouvertes.
- Chaque problème existe sous plusieurs écritures. Le 19/11, c'est l'écriture qui a tout décidé
  (`dom/report.md`). Les compétitions donnent en général une seule forme par instance.

## 1. Les problèmes et leurs modèles

Chaque famille a une forme canonique (la donnée mathématique et la question), puis plusieurs
écritures. Une écriture est désignée par un code court, réutilisé dans les tableaux de résultats.

### P1. Distance minimale d'un code fixé

Question : existe-t-il un mot non nul de poids ≤ w ? On prend w = d − 1 (ou d − 4 pour un code
doublement pair), où la réponse attendue est UNSAT, et w = d, où elle est SAT.

Instances :
- codes QR binaires étendus de longueur 8, 24, 32, 48, 72, 80, 104 (déjà générés) ;
- codes BCH et leurs extensions, codes de Reed–Muller RM(r, m) jusqu'à m = 8 ;
- codes doublement circulants et codes auto-duaux extrémaux connus ;
- codes aléatoires [n, n/2] de n = 32 à 128, dont la distance est calculée à part ;
- les codes ternaires (QR ternaires, codes de Pless), qui donnent une variante sur GF(3).

Écritures :

| code | écriture | ce qu'elle teste |
|---|---|---|
| E-SYS-XC | forme systématique [I \| A], XOR en chaînes, en clauses (`minweight.mzn`) | l'écriture habituelle |
| E-SYS-XN | la même, avec les XOR natifs (CryptoMiniSat, `bool_xor` de CP-SAT) | le raisonnement XOR natif |
| E-CHK-S | une base de parités écrites en sommes Σx = 2y (`minweight_chk.mzn`, ENC = 2) | l'apprentissage PB, la relaxation linéaire en MILP |
| E-ORB-S | toute l'orbite des mots de poids minimal, en sommes (`minweight_sym.mzn`) | la redondance, la symétrie certifiable |
| E-ORB-X | l'orbite en XOR | la redondance pour SAT et la reconstruction de XOR |
| E-HALF | E-SYS avec le découpage en deux moitiés et en cubes (FIRST, SECOND, THIRD) | le parallélisme, les petites preuves |
| E-FIX | n'importe laquelle avec 1, 2 ou 3 coordonnées imposées | la symétrie, et sa preuve par dominance |
| E-TREL | le treillis minimal du code (graphe des états) | la programmation dynamique, les BDD |
| E-ILP | E-CHK-S écrite en MPS ou LP, y entier | le MILP |
| E-QUBO | le poids comme énergie, les parités en pénalités | le recuit et les solveurs quadratiques |

La borne de poids Σx ≤ w a elle-même plusieurs écritures en SAT : totaliseur, compteur
séquentiel, réseau de tri, additionneur. C'est un second facteur à croiser pour les solveurs SAT.

### P2. Compter les mots de poids w (l'énumérateur de poids)

Même modèle que P1, mais on demande le nombre exact de solutions de poids exactement w. La réponse
vient de l'énumérateur (759 pour Golay, 17296 pour QR48), vérifiable par l'identité de MacWilliams.
Écritures : E-SYS-XC et E-SYS-XN pour le #SAT, E-TREL pour la programmation dynamique (le comptage
sur treillis est exact et classique), E-SYS en énumération CP (`-a`), comme `scripts/equivcount.py`.

### P3. Existence d'un code [n, k, d] (le problème de l'article AAAI-26)

Question : existe-t-il un code linéaire binaire de longueur n, de dimension k et de distance ≥ d ?
La réponse vient des tables de bornes de Grassl (codetables.de). On prend SAT quand un code est
connu, et UNSAT quand la borne supérieure est prouvée (petits n). Écritures :
- E-AAAI : leur CNF (`construct_SAT.py`), avec et sans leur brisure de symétrie ;
- E-LIN : `linear.mzn`, notre écriture MiniZinc ;
- E-LIN-DOM : `linear_dom.mzn`, avec le tri des colonnes justifiable par dominance ;
- E-LIN-S : les poids écrits en sommes au lieu de XOR (à écrire) ;
- E-MAX : la version optimisation, maximiser d, pour MaxSAT, MILP et CP-SAT.

### P4. Codes auto-duaux avec un automorphisme imposé

Question : existe-t-il un code auto-dual doublement pair [n, n/2, d] invariant par une
permutation d'ordre premier p d'un type donné ? Les réponses viennent des classifications publiées
(en longueur 48 : l'ordre 23 donne QR48 ; l'ordre 7 est exclu). Écritures : `aut.mzn` (forme
systématique des composantes, LEX), la décomposition de Feulner et Nebe (piste R4), et une écriture
SAT directe. C'est la famille la plus proche de la question ouverte du [72, 36, 16].

### P5. Vecteurs courts d'un réseau

Question : le réseau a-t-il un vecteur non nul de norme ≤ M ? Réponses par les séries thêta (E8,
Barnes–Wall BW16, Coxeter–Todd K12, Leech, P48p, P48q). Écritures :
- E-LAT-CODE : `shortvec.mzn`, le réseau construit à partir d'un code ;
- E-LAT-GRAM : coordonnées entières dans une base, norme par la matrice de Gram (quadratique,
  donc MIQP, ou bits pour SAT et PB) ;
- E-LAT-SPLIT : les découpages (b = 0, b = 1, moitiés).

### P6. Designs et codes à poids constant

Questions classiques de CSPLib, dont la réponse est souvent connue :
- existence d'un système de Steiner S(t, k, v), par exemple S(5, 8, 24), qui vient de Golay ;
- taille minimale d'un design de recouvrement C(v, k, t) (tables de La Jolla) ;
- taille maximale d'un code à poids constant A(n, d, w) (tables de Brouwer).

Écritures : matrice d'incidence avec des contraintes de cardinalité (CP, SAT, PB, MILP), et des
règles d'ASP, qui sont naturelles pour ce type de problème.

### P7. Décodage

Question : quel est le mot du code le plus proche d'un mot reçu donné ? C'est une optimisation.
Ses écritures sont les mêmes que P1 avec un objectif, et elle est naturelle pour MaxSAT et le
MILP. Elle se génère en quantité, avec une réponse connue quand le bruit est sous la moitié de d.

## 2. Les paradigmes et leurs meilleurs solveurs

La colonne « preuve » dit ce que le solveur sait certifier. C'est une colonne de plus pour la
comparaison, et elle compte pour ce projet.

| paradigme | solveurs | familles où il est naturel | preuve |
|---|---|---|---|
| SAT (CDCL) | Kissat, CaDiCaL (vainqueurs des compétitions SAT récentes) | P1, P3, P6 | DRAT, LRAT, vérifiable par cake_lpr (vérifié en CakeML) |
| SAT avec XOR | CryptoMiniSat (élimination de Gauss–Jordan) | P1, P2 | XLRUP ou FRAT-XOR, `--xlrup` (à vérifier) |
| PB | RoundingSat, Exact (son successeur), Sat4j en coupes, NaPS (traduit en SAT) | P1, P3, P6 | VeriPB (RoundingSat, Exact) |
| CP avec apprentissage (LCG) | OR-Tools CP-SAT (vainqueur répété du MiniZinc Challenge), Chuffed, Pumpkin, Huub | tous | VeriPB pour Pumpkin (à vérifier), aucune pour CP-SAT |
| CP classique | Gecode, Choco, GCS, baguette | tous | VeriPB (GCS, baguette) |
| MILP | Gurobi (si licence académique), CPLEX, SCIP, HiGHS | P1 (E-ILP), P3 (E-MAX), P5, P7 | certificats VIPR par SCIP exact |
| MaxSAT | EvalMaxSAT, UWrMaxSat, CASHWMaxSAT, MaxHS (bien classés aux évaluations récentes, à vérifier) | P3 (E-MAX), P7 | VeriPB pour certains (travaux de Berg et al., à vérifier) |
| ASP | clingo (clasp), WASP | P6, P3 | rien de standard |
| SMT | Z3, cvc5, Bitwuzla, Yices2 (bit-vecteurs, popcount) | P1, P5 | cvc5 (Alethe), partielle |
| comptage (#SAT) | SharpSAT-TD, d4, Ganak, GPMC | P2 | CPOG pour le comptage certifié |
| compilation, BDD | CUDD, Sylvan (à choisir) | P1, P2 | non |
| programmation dynamique | un Viterbi sur le treillis minimal du code, à écrire | P1, P2, P7 | le calcul est petit et peut être relu |
| recherche locale | yalsat, CCAnr (SAT), NuWLS (MaxSAT) | les instances SAT seulement | aucune, et rien pour UNSAT |
| QUBO, recuit | recuit simulé (dwave-neal), éventuellement un recuit quantique | P1 en SAT, P7 | aucune |
| algèbre | bases de Gröbner (msolve) sur GF(2) | petits P1 et P3, par curiosité | non |
| algorithmes dédiés (référence) | Brouwer–Zimmermann (Magma, GAP/Guava, Sage), décodage par ensembles d'information (Stern, Dumer, BJMM), énumération et crible de réseaux (fplll, G6K) | P1, P5 | non |

On s'attend à ce que :
- la programmation dynamique sur treillis soit très forte sur les petits codes (le treillis
  minimal de Golay a au plus 256 états) et s'effondre quand la largeur du treillis explose ;
- l'ASP soit faible sur les parités, faute de XOR natif, mais à sa place sur les designs ;
- les algorithmes dédiés battent tout le monde sur P1 et P5, sans certificat. Ce sont des
  références, pas des concurrents ;
- le recuit trouve vite les mots de poids d (SAT) et ne sache rien dire des cas UNSAT.

## 3. La méthode

- Un générateur par famille écrit une forme canonique en JSON (la donnée, la question, la réponse
  attendue et sa source). Les écrivains par format en tirent chaque écriture : `.mzn`/`.dzn`, CNF,
  CNF avec XOR, OPB, WCNF, MPS ou LP, programme ASP, SMT-LIB, treillis.
- Avant tout run, la réponse attendue est revérifiée par un calcul indépendant (`mindist.c`,
  énumérateurs, identité de MacWilliams).
- Même machine, limites de temps uniformes (par exemple 1 h), trois graines pour les solveurs
  aléatoires, mémoire bornée.
- Deux tableaux par famille, l'un à écriture égale (le même fichier pour tous), l'autre où chaque
  solveur a sa meilleure écriture. Le relecteur du 19/11 a montré que c'est la première objection.
- Les scores sont le PAR-2 (comme les compétitions SAT), le nombre d'instances résolues, et le
  nombre de réponses fausses, qui doit être nul.
- Les preuves produites sont vérifiées quand le paradigme en a.
- Les générateurs et les écritures sont publiés, et les experts de chaque paradigme sont invités
  à proposer la leur. Un paradigme qu'on connaît mal ne doit pas perdre à cause de notre écriture.

## 4. Les phases

| phase | contenu | ce qui existe déjà |
|---|---|---|
| 0 | forme canonique, écrivains par format, vérification des réponses attendues | gen_instances, symcode, qr2sym, gencnf, opb2plain, run1, rs1, sat1 |
| 1 | P1 et P3, avec SAT, SAT+XOR, PB, CP (CP-SAT, Chuffed, Gecode, GCS, baguette), MILP (HiGHS, SCIP), la DP sur treillis et Brouwer–Zimmermann comme référence | presque tous les modèles de P1 et P3, Kissat, CryptoMiniSat, RoundingSat |
| 2 | P2 (comptage) et P5 (réseaux, avec fplll comme référence) | equivcount, shortvec |
| 3 | ASP, SMT, MaxSAT et P7, puis P6 et le QUBO | rien |
| 4 | la colonne preuves, la rédaction, et la soumission des familles aux compétitions SAT, PB et MiniZinc | VeriPB, la chaîne `dom/` |

Ordre de grandeur :
- La phase 1 demande une à deux semaines de travail et quelques jours de calcul sur le nœud
  (192 cœurs).
- Les phases suivantes s'ajoutent famille par famille.

Les risques sont les suivants :
- l'ampleur, qu'on contient avec des phases livrables chacune ;
- les licences (Gurobi, Magma) ;
- l'équité des écritures (voir la méthode).

Le résultat se publierait comme article de benchmark, par exemple dans *Constraints* ou dans la
partie données d'une conférence CP ou SAT, et les familles iraient aux compétitions.
