# La règle de dominance sur un exemple de quatre bits

Le code de parité de longueur 4 (les mots de poids pair). Question : existe-t-il un mot non nul de
poids ≤ 2 ? Variables x1 à x4 pour les coordonnées, x5 pour la parité (x1 + x2 + x3 + x4 = 2 x5).

- `parite4.opb` : le modèle.
- `parite4.pbp` : impose « la coordonnée 1 est dans le support » par deux lignes `dom`, dont les
  témoins sont les échanges (1 2) et (1 3), puis conclut x1 = 1 par `rup`. VeriPB 3.0.2 l'accepte.
- `parite4_faux.pbp` : le même avec un témoin qui n'est pas une symétrie (x1 -> x3 seul). VeriPB le
  refuse à la ligne 25, parce que l'image de 0011 est 1011, qui est de poids impair.

`~/.cargo/bin/veripb parite4.opb parite4.pbp`
