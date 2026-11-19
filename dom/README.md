# La symétrie justifiée dans la preuve (piste 7 de ROADMAP.md)

Le but est de remplacer un axiome de symétrie par une étape de preuve que VeriPB vérifie. Ici,
l'axiome impose les coordonnées 1, 2 et 3 dans le support d'un mot de poids minimal.
L'exemple à quatre bits de `notes/dominance/` explique la règle de dominance.

## La chaîne

1. `scripts/symcode.py P WMAX 3` écrit `dom/sym_pP_wWMAX.dzn` et `.json`. On utilise le code QR
   étendu de longueur P+1 (P = 7 pour Hamming [8,4,4], P = 23 pour Golay), la liste de ses mots
   de poids minimal, les clauses x_c ∨ ¬x_b, et pour chaque clause un automorphisme témoin pris
   dans PSL(2, P). Le groupe est engendré puis vérifié élément par élément.
2. `models/minweight_sym.mzn` écrit le code de façon symétrique. Le mot doit être orthogonal à
   chaque mot de poids minimal, avec un entier y_w par mot. Un automorphisme envoie donc chaque
   contrainte sur une contrainte, et chaque variable sur une variable.
3. baguette résout le modèle avec les clauses, qui y figurent comme axiomes, et écrit un .opb et
   un .pbp.
4. `scripts/dommerge.py` retire les clauses du .opb, puis écrit une seule preuve. Elle définit
   l'ordre « x_c1, puis x_c2, puis x_c3, un 1 avant un 0 », redérive chaque clause par une ligne
   `dom` qui porte la même étiquette @cN, et continue avec la preuve de baguette sans la
   modifier. La fusion marche sans renuméroter parce que baguette ne désigne les contraintes que
   par leurs étiquettes.
5. VeriPB vérifie le tout : `dom/run.sh NOM` fait les étapes 1 à 4 sur le nœud, puis refait la
   vérification avec des témoins faux (`BAD=all`).

## Résultats (18/11, baguette 2c97b16, VeriPB 3.0.2)

| instance | baguette | preuve fusionnée | témoin faux partout |
|---|---|---|---|
| Hamming, poids ≤ 2 (UNSAT) | 0,01 s | ✅ UNSAT, 18 lignes dom | refusé à la 1re ligne dom |
| Hamming, poids ≤ 4 (SAT) | 0,01 s | ✅ SAT | refusé |
| Golay, poids ≤ 4 (UNSAT) | 0,12 s, 20 nœuds (203 sans les clauses) | ✅ UNSAT en 0,34 s, 66 lignes dom, 10 Mo | refusé |
| Golay, poids ≤ 8 (SAT) | 0,12 s | ✅ SAT en 0,30 s | refusé |
| QR48, poids ≤ 8 (UNSAT) | 94 s, 1 205 nœuds | ✅ UNSAT en 4 min 30 environ, 138 lignes dom, 834 Mo (dont 500 Mo de témoins) | refusé à la 1re ligne dom |

Un seul témoin faux (`BAD=k`) est refusé sur la première ligne de chaque bloc et accepté sur les
dernières. Ce n'est pas un trou. À la fin d'un bloc, les clauses déjà dérivées ne laissent que
deux ou trois coordonnées possibles dans le support, aucun mot du code n'a ce support, et la
clause découle des autres par propagation (RUP) sans avoir besoin du témoin.

## Ce qui reste

- Les témoins écrivent toutes les variables déplacées, 1536 par ligne pour Golay et 69 024 pour
  QR48, d'où 500 Mo de témoins sur QR48. Ce n'est pas encore ce qui limite.
- Le modèle symétrique a une contrainte par mot de poids minimal. Il reste à mesurer s'il tient
  la comparaison avec la forme systématique sur QR48 et QR80.
- Les deux autres preuves à lex de la piste 7 (AAAI-26 `linear.mzn`, `aut.mzn` avec LEX) restent
  à faire.

# Deuxième partie : le tri des colonnes du benchmark AAAI-26

`models/linear_dom.mzn` reprend `linear.mzn` (codes linéaires (n, k, d) quelconques) avec pour seule
brisure de symétrie le tri des colonnes de A. Chaque contrainte « colonne j ≤ colonne j+1 » est une
seule inégalité à coefficients 8, 4, 2, 1 (la colonne lue comme un nombre binaire). Toutes les
contraintes du modèle sont écrites colonne par colonne de la même façon, donc l'échange de deux
colonnes voisines est un témoin qui s'écrit comme une liste de variables.

`scripts/domlex.py` retire ces inégalités du .opb de baguette et les redérive par `dom`. L'ordre lit
A colonne par colonne comme un seul nombre binaire, et le témoin échange les colonnes j et j+1 de A,
de X (les XOR des lignes) et des entiers `bool2int` que MiniZinc a introduits. VeriPB ne trouve pas
seul que l'échange fait descendre dans l'ordre, parce qu'il faut multiplier l'inégalité par
(2^k − 1)·2^(N − k(j+2)). La sous-preuve donne cette multiplication, une ligne `pol` par but.
`dom/runlex.sh NOM "n=..;k=..;d=..;LEX=..;"` fait toute la chaîne sur le nœud.

| instance | LEX | baguette | preuve fusionnée | témoin faux (colonnes de A seules) |
|---|---|---|---|---|
| (10, 4, 5) | large | UNSAT | ✅ 5 lignes dom | refusé |
| (10, 4, 4) | large | SAT | ✅ | refusé |
| (14, 5, 7) | large | UNSAT | ✅ 8 lignes dom | refusé |
| (15, 5, 7) | large | SAT | ✅ 9 lignes dom | refusé |
| (10, 4, 5) | stricte | UNSAT | ❌ refusée au but « pas au-dessus » | |
| (15, 5, 7) | stricte | SAT | ❌ refusée au même endroit | |
| (4, 1, 4) | stricte | **UNSAT, à tort** | ❌ refusée | |
| (4, 1, 4) | large | SAT, le code à répétition | ✅ | accepté, à raison (k = 1, donc X = A et le témoin est juste) |

Le tri strict de l'article n'est pas une conséquence de la symétrie. Quand deux colonnes sont égales,
les échanger ne change rien, donc rien ne permet de les interdire. Sur le code à répétition [4, 1, 4],
dont toutes les colonnes valent 1, le tri strict rend le modèle UNSAT alors que le code existe. VeriPB
refuse la preuve fusionnée exactement là. Sur les instances du benchmark (k ≥ 8) ce n'est peut-être
pas grave, mais c'est un axiome non justifié, et la règle de dominance l'a trouvé toute seule.

# Troisième partie : ce que coûte le modèle symétrique (QR48, 18/11)

Question : un mot non nul de poids ≤ 8 dans QR48 (UNSAT). Le modèle symétrique a une parité par mot
de poids 12, soit 17296 contraintes de 13 variables. La forme systématique a 24 chaînes de XOR.
Les runs sont `bench/sym.sh` et `bench/symheur.sh` (`results/runs/SYM_*`, `SH_*`), avec baguette
2c97b16, le binaire du nœud. Les sessions de baguette optimisent en ce moment son coût par nœud et
sa recherche (M10, M11), donc ses chiffres sont ceux d'une version déjà dépassée.

| trois coordonnées imposées | nœuds | temps | temps par nœud |
|---|---|---|---|
| Chuffed, systématique | 11 306 | 0,13 s | 11 µs |
| Chuffed, symétrique, sans annotation | 28 666 (profondeur 17 301) | 104 s | 3,6 ms |
| Chuffed, symétrique, recherche sur x (1 d'abord) | 14 891 (profondeur 8) | 170 s | 11 ms |
| GCS, symétrique, sans annotation | 21 385 | 117 s | 5,5 ms |
| baguette, systématique | 27 178 | 128 s | 4,7 ms |
| baguette, symétrique, sans annotation | 1 205 | 96 s | 80 ms |
| baguette, symétrique, recherche sur x (1 d'abord) | 723 | 65 s | 90 ms |
| baguette, symétrique, sans analyse de conflits PB | ? | > 1800 s, 4,8 Go | |

- Le coût vient de la propagation, pas de la recherche. Chaque coordonnée est dans 4324 des 17296
  mots, donc chaque décision réveille des milliers de sommes (Chuffed fait 9000 propagations par
  nœud). Chuffed fait à peu près autant de nœuds que sur la forme systématique, mais chacun coûte
  1000 fois plus. Les 17296 parités sont 720 fois redondantes, puisque 24 suffisent à définir le
  code. On ne peut pas en garder moins tant que l'ensemble doit rester invariant par le groupe,
  parce que les mots de poids 12 forment une seule orbite de PSL(2, 47).
- Sans annotation, Chuffed et GCS branchent aussi sur les auxiliaires y_w (profondeur 17 301). Sur
  QR48 cela coûte peu, mais sur Golay sans symétrie GCS ne finit pas en 30 minutes (28 millions de
  nœuds), alors qu'en branchant sur x il finit en 855 nœuds. Chuffed passe de 10 403 à 430 nœuds.
- Baguette fait 20 à 40 fois moins de nœuds que les autres grâce à son analyse de conflits PB. Sur
  QR48 il apprend 588 contraintes PB, et 511 d'entre elles contiennent au moins deux auxiliaires
  y_w avec le coefficient 2. Il additionne donc des sommes de parité entre elles, ce qui revient à
  raisonner sur les XOR, chose que des clauses ne savent pas faire. Sans cette analyse, il ne
  finit pas. Sur la forme systématique, elle ne change rien (mêmes 27 178 nœuds), parce que les
  XOR y sont des clauses. Le prix est un nœud 20 fois plus cher que sur la forme systématique.
- Sans les trois coordonnées imposées, les rôles s'inversent complètement :

  | sans symétrie | Chuffed | GCS | baguette |
  |---|---|---|---|
  | forme systématique | 7,6 s, 409 892 nœuds | 27,5 s | pas fini en 1 h (113 315 nœuds) |
  | modèle symétrique | pas fini en 1 h (407 269 nœuds) | pas fini en 1 h | 1 951 s, 15 823 nœuds, 7 868 PB appris, preuve de 4,2 Go vérifiée |

  Chuffed fait le même nombre de nœuds sur les deux modèles, mais 500 fois plus lentement sur le
  modèle symétrique. Baguette est le seul à finir le modèle symétrique, avec 26 fois moins de nœuds
  que Chuffed, et il ne finit pas la forme systématique, où il n'apprend que des clauses. Sur ces
  problèmes, l'apprentissage PB vaut donc plus que le coût par nœud, à condition que le modèle lui
  donne des sommes à combiner.
