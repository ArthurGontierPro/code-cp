# Où on en est (2026-11-16)

## Ce qu'on sait faire

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

## Ce qu'on ne sait pas faire

- q48 sans la forme BDC : aucune méthode n'aboutit (Chuffed, recherche libre, paresseuse).
- 72 avec d=16 sous BDC : on attend UNSAT (résultat connu), on ne l'obtient pas.
- 96 : rien. Les codes extrémaux à 72 et 96 sont des problèmes ouverts.
- Certifier la brisure de symétrie (journaliser le double-lex dans VeriPB).

## En cours

- Bug baguette : sur le benchmark, 36 preuves illisibles. Cause : baguette ne s'arrête
  pas à sa --time-limit sur les longs runs et mon timeout extérieur le tue en pleine
  écriture. Mesure lancée sur le nœud (limites 600/1200/2400/3600 s, dbg/).

## Ce qu'on veut faire ensuite (par ordre)

1. Corriger le bug de --time-limit (dans baguette, via le protocole multi-sessions).
2. Non-existence certifiée de petits codes connus : (40,8,17), (35,10,13).
   VeriPB (baguette) contre DRAT (Kissat). Angle "article" le plus net.
3. Optimiser T (option T ≤ u de linear.mzn) pour comparer à leurs meilleurs T.
4. Plus tard : distance paresseuse DANS le solveur (propagateur), seul moyen
   plausible de passer q48 sans hypothèse ; journaliser le lex pour l'unicité.
