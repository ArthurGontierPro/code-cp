# Comment on travaille

## Mesurer

On donne des nombres mesurés, pas des prédictions. Une affirmation sur un solveur s'appuie sur un run
dont on peut montrer la sortie. Quand une explication n'est qu'une interprétation, on le dit.

Une comparaison se fait à recherche égale quand c'est possible (la même annotation de branchement pour
tous les solveurs CP), sinon on le signale. Une instance dont la réponse est connue est vérifiée par un
calcul indépendant avant d'être utilisée (`benchmark/verify/`).

## Choisir le solveur

baguette n'est pas l'objet de recherche de ce dépôt. Quand il est le plus lent, on résout à grande
échelle avec un autre, choisi par la mesure. GCS si on veut une preuve, Chuffed pour une sonde rapide,
Kissat ou CryptoMiniSat quand le problème est du SAT pur ou plein de XOR.

On garde quand même baguette dans chaque comparaison, parce que ses échecs sur des formes de problèmes
nouvelles trouvent de vrais bugs (le dépassement de `--time-limit` du 16/11, par exemple). Une
anomalie de baguette se signale dans le WORKLOG de baguette, section `## Cross-session requests`, ou
comme ligne de sa `docs/ROADMAP.md` en suivant son protocole de réservation.

## Les agents

On peut lancer plusieurs agents Opus en parallèle pour le travail du projet. On ne coupe pas un agent
en route, parce qu'il laisserait un état à moitié fait. Pendant qu'ils tournent, on commence tout ce
qui ne touche pas à leurs fichiers. Un nœud qui n'est pas à 92 cœurs est du temps perdu.

Un agent reçoit les chemins, les fichiers à lire et ce qu'on attend en retour, pas une exploration.
Son rapport dit ce qu'il a mesuré et ce qu'il n'a pas pu vérifier.

## La confiance

Pour l'instant on teste la faisabilité et on cherche à comprendre les solveurs, les modèles et les
symétries. Un résultat qui en vaut la peine sera refait avec la chaîne de confiance complète
(découpages et symétries justifiés dans la preuve, vérification par CakePB). Voir `ROADMAP.md`, R5.
