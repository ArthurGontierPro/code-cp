# Feuille de route

Le but est d'utiliser des solveurs de contraintes avec journal de preuve sur les empilements denses de
sphères en dimension 24k, c'est-à-dire les réseaux pairs unimodulaires extrémaux. En dimension 24 il
n'y en a qu'un (Leech), en 48 on en connaît quatre, en 72 un seul (Nebe), et en 96 on n'en connaît
aucun. Le détail des résultats est dans `RESULTS.md`. Ce fichier dit seulement ce qui est fait, ce qui
tourne et ce qui vient ensuite.

## Fait

- **R0. Le bug de `--time-limit` de baguette.** Mesuré, il dépasse sa limite d'environ 8 %, et ses
  preuves sont complètes. Signalé dans le WORKLOG de baguette, devenu la tâche M6-T21. Les scripts
  ont quitté l'ancien dossier `/scratch/arthur/golay`, sauf ceux de la première journée.
- **R1. La littérature** sur les réseaux extrémaux en dimension 48, 72 et 96 :
  `notes/lattices-literature.md`.
- **R3. Des codes aux réseaux.** Leech est construit à partir de Golay (construction B plus un
  translaté), et son minimum 4 est certifié. La distance de Golay, QR48, QR72 et QR80 est certifiée,
  celle de QR104 est établie sans preuve. P48p et P48q sont extrémaux d'après Chuffed, sans preuve.
- **Les tests du modèle** (RESULTS.md, section E). Les découpages et les constructions donnent
  exactement les nombres connus sur Golay, QR48 et Leech.

## Mis de côté

- **R2. Leech à partir de rien** (matrice de Gram en inconnue). La contrainte det G = 1 ne s'écrit pas
  simplement en CP, et tout le domaine passe par les codes. Voir RESULTS.md, bloc D.

## En cours sur le nœud

- La certification de P48 par baguette (`bench/p48bag.sh`) et ses tests d'équivalence (52 millions de
  vecteurs).
- La preuve baguette de QR104 et de QR80 avec les symétries du code (`bench/fix.sh`, `c104rbag.sh`).
- Les boucles paresseuses du modèle d'automorphismes sont arrêtées (18/11). Elles ne convergeaient
  pas, même en longueur 48. Seul l'ordre 23 en longueur 48 a abouti, et il retrouve QR48.

## Ensuite

- **R4. Le [72, 36, 16] par ses automorphismes.** Remplacer la boucle paresseuse monolithique par la
  décomposition de Feulner et Nebe : énumérer les codes composants (C1 sur F8 avec d(C1) ≥ 4 et
  d(C1⊥) ≥ 4), puis les recoller, chaque étape étant un problème CP borné et certifiable. D'abord
  l'ordre 7 en 72 (reproduire leur théorème), puis l'ordre 5 en 72 et en 96 (`notes/length96.md`).
- **R5. La chaîne de confiance.** Pour l'instant on teste la faisabilité et on comprend ce qu'on fait.
  Si un résultat en vaut la peine, on le refera avec la chaîne complète, c'est-à-dire des découpages et
  des symétries justifiés dans la preuve, puis la vérification par CakePB.
- **R6. Ce qu'on attend de baguette** (demandes dans son WORKLOG) : le coût par nœud sur les modèles
  pleins de XOR, une étude d'heuristiques, l'oubli de clauses par LBD, les redémarrages, les cubes
  sous hypothèses, la parité, et la correction du `bool_xor` avec une constante.
