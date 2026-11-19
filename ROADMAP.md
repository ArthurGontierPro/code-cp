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

## Pistes à garder (18/11)

Discutées le 18/11, aucune n'est lancée. Les numéros sont ceux de la discussion.

Résultats mathématiques certifiés

1. Certifier les exclusions publiées pour le [72, 36, 16] (ordre 7 par Feulner et Nebe, types
   d'ordre 2, 3 et 5 par Bouyuklieva, Yankov, Borello et d'autres). Ce sont des calculs Magma sans
   certificat. C'est R4 poussé jusqu'au bout, et c'est publiable même sans résultat nouveau.
2. Certifier le minimum 8 du réseau de Nebe Γ72. Il faut un modèle neuf, parce que Γ72 se construit à
   partir de Leech sur Z[(1+√−7)/2] et pas à partir d'un code binaire.
3. La dimension 96 par des constructions structurées (codes sur Z_{2k}, réseaux idéaux dans
   Q(ζ97)). Spéculatif, attend que 1 marche. Voir `notes/length96.md`.

Faiblesses des solveurs

4. La parité. Tous les modèles de codes sont des XOR, aucun de nos solveurs CP ne raisonne dessus.
   Comparer avec CryptoMiniSat (élimination de Gauss), puis un propagateur de Gauss journalisé dans
   baguette (preuves de parité de Gocht et Nordström, AAAI 2021).
5. Le coût par nœud et l'heuristique. Rejouer le tableau B-heur quand baguette aura ses redémarrages,
   son oubli par LBD et ses heuristiques.
6. Le comptage. Les comptes connus (759, 17296, 196560, 52416000) sont des bancs pour les compteurs
   de modèles, et le comptage certifié existe (CPOG, Bryant et al., 2023).

Chaîne de confiance

7. Justifier la fixation de trois coordonnées (minweight_fix) par la règle de dominance de VeriPB,
   avec les automorphismes de PSL(2, p) comme témoins. La difficulté connue est que l'encodage actuel
   (forme systématique, chaînes de XOR) n'est pas symétrique, donc l'image d'une contrainte par un
   automorphisme du code n'est pas une contrainte de la base. Fait le 18/11 sur Hamming et Golay
   avec un modèle symétrique et les preuves de baguette, en une seule preuve VeriPB (`dom/`).
8. Recoller les cas et les moitiés par des conclusions ¬cube et un fichier qui les combine.

Un benchmark multi-paradigmes (ajouté le 19/11, à faire plus tard)

9. Une liste aussi complète que possible des problèmes de codes et de réseaux, chacun sous plusieurs
   écritures, avec la réponse connue. On y lancerait le meilleur solveur de chaque paradigme : SAT,
   SAT avec XOR, PB, CP, MILP, MaxSAT, ASP, SMT, comptage, programmation dynamique sur treillis,
   recherche locale, QUBO, avec les algorithmes dédiés comme référence. Les problèmes, les
   écritures, les solveurs, la méthode et les phases sont dans `notes/benchmark-plan.md`. La phase 1
   (distance minimale et existence de codes) réutilise presque tout l'outillage du 18/11 et du
   19/11.

Ordre proposé : 7, puis 1, avec 4 en parallèle côté baguette. 2 et 6 font de bons sujets d'étudiant.
