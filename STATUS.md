# Journal d'étape

Un court résumé par journée, le plus récent en haut. Le détail est dans `RESULTS.md` (le tableau) et
`ROADMAP.md` (la suite).

## 18/11

- Tests d'équivalence par énumération (RESULTS.md, section E) : Golay, QR48 et Leech donnent exactement
  les nombres connus, découpages compris. Le modèle d'automorphismes retrouve QR48 pour l'ordre 23.
- Les symétries des codes QR (trois coordonnées imposées) rendent QR80 vingt fois plus rapide et
  QR104 faisable, sans preuve pour l'instant.
- L'heuristique « 1 d'abord » résout l'ordre 7, k = 2 en 150 nœuds, avec une preuve baguette de 1 Mo.
  Les boucles de longueur 72 font maintenant des tours de quelques minutes.
- Demandes à baguette : coût par nœud, heuristiques, oubli de clauses, redémarrages, cubes, parité,
  `bool_xor` avec une constante.

## 17/11

- Distance de QR80 certifiée par 2154 preuves baguette. Leech, Golay, QR48 et QR72 certifiés. P48p et
  P48q extrémaux d'après Chuffed. Tutoriel de RESULTS.md écrit.
- Bug de MiniZinc 2.10.1 (segfault à l'aplatissement) contourné dans `aut.mzn`.

## 16/11 (première journée, les codes eux-mêmes)

### Ce qu'on sait faire

| Problème | Résultat | Avec quoi |
|---|---|---|
| Trouver le Golay [24,12,8] | quelques secondes | Chuffed ; baguette avec preuve vérifiée par VeriPB |
| Prouver que "lignes + paires de lignes" (K=2) imposent le Golay | UNSAT en 21 s, preuve VeriPB vérifiée | baguette (le double-lex est admis, pas certifié) |
| Trouver q48 [48,24,12] | 8 s | Chuffed, seulement avec la forme BDC (hypothèse tirée de la littérature) |
| Trouver un [72,36,12] auto-dual | 2 à 3 min | GCS et la boucle paresseuse, forme BDC |
| Benchmark AAAI-26 (51 codes linéaires) | Kissat 29/51 en 1 h (ils ont 38 en 24 h), GCS 11, Chuffed 6, baguette 1 | leur formulation reproduite dans models/linear.mzn |

Outils : models/code.mzn (auto-dual, commenté en français), models/linear.mzn (AAAI-26),
scripts/mindist.c (distance exacte), scripts/cegar.py (distance paresseuse),
bench/ (runner du benchmark sur le nœud).

### Ce qu'on ne sait pas faire

- q48 sans la forme BDC : aucune méthode n'aboutit (Chuffed, recherche libre, paresseuse).
- 72 avec d=16 sous BDC : on attend UNSAT (résultat connu), on ne l'obtient pas.
- 96 : rien. Les codes extrémaux à 72 et 96 sont des problèmes ouverts.
- Certifier la brisure de symétrie (journaliser le double-lex dans VeriPB).

### En cours

- Bug baguette : sur le benchmark, 36 preuves illisibles. Cause : baguette ne s'arrête
  pas à sa --time-limit sur les longs runs et mon timeout extérieur le tue en pleine
  écriture. Mesure lancée sur le nœud (limites 600/1200/2400/3600 s, dbg/).

### Ce qu'on veut faire ensuite (par ordre)

1. Corriger le bug de --time-limit (dans baguette, via le protocole multi-sessions).
2. Non-existence certifiée de petits codes connus : (40,8,17), (35,10,13).
   VeriPB (baguette) contre DRAT (Kissat). Angle "article" le plus net.
3. Optimiser T (option T ≤ u de linear.mzn) pour comparer à leurs meilleurs T.
4. Plus tard : distance paresseuse DANS le solveur (propagateur), seul moyen
   plausible de passer q48 sans hypothèse ; journaliser le lex pour l'unicité.
