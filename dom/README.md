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

Un seul témoin faux (`BAD=k`) est refusé sur la première ligne de chaque bloc et accepté sur les
dernières. Ce n'est pas un trou. À la fin d'un bloc, les clauses déjà dérivées ne laissent que
deux ou trois coordonnées possibles dans le support, aucun mot du code n'a ce support, et la
clause découle des autres par propagation (RUP) sans avoir besoin du témoin.

## Ce qui reste

- Les témoins écrivent toutes les variables déplacées (3024 par ligne pour Golay), d'où 10 Mo de
  preuve pour 66 lignes. Pour QR48 (17296 mots) ce sera environ 70 000 par ligne.
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
