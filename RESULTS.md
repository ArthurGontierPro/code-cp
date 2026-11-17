# Tableau des résultats

Une ligne par expérience, qu'elle soit faite, en cours ou prévue. On la remplit au fur et à mesure.
La dernière colonne dit ce que le résultat signifie pour la question de départ, c'est-à-dire
les empilements de sphères en dimension 24k et les réseaux extrémaux.

Statuts : ✅ fait · 🔄 en cours · ⏳ prévu · ❌ échec ou hors de portée.
Le nœud fataepyc-07 a 192 cœurs, donc tout ce qui est marqué ⏳ dans un même bloc peut tourner en parallèle.

## A. Ce qui est déjà acquis

| id | question | méthode | statut | résultat | ce que ça veut dire |
|---|---|---|---|---|---|
| A1 | trouver le code de Golay [24,12,8] | code.mzn, Chuffed et baguette | ✅ | quelques secondes, preuve VeriPB acceptée | le modèle est correct. Golay donne Leech par la construction B, en ajoutant un vecteur. |
| A2 | « les lignes et les paires de lignes » suffisent-elles à imposer d=8 en 24 ? | code.mzn, K=2, baguette | ✅ | UNSAT en 21 s, preuve vérifiée | une relaxation K=2 caractérise déjà Golay. La brisure de symétrie (double-lex) est admise, non certifiée. |
| A3 | trouver le code QR48 [48,24,12] | code.mzn sous BDC, Chuffed | ✅ | 8 s | on retrouve le code extrémal de longueur 48, mais seulement sous une hypothèse de forme tirée de la littérature. |
| A4 | trouver q48 sans hypothèse | Chuffed, CEGAR | ❌ | rien en 20 min | sans symétrie imposée, l'espace est trop grand. C'est pour ça que la littérature impose un groupe d'automorphismes. |
| A5 | trouver un [72,36,12] auto-dual | GCS + boucle paresseuse, BDC | ✅ | 2 à 3 min | facile, mais d=12 est loin de l'extrémal (16). |
| A6 | [72,36,16] sous BDC | Chuffed, GCS | ❌ | pas de conclusion | impossible par construction, car la BDC a un automorphisme d'ordre 35 et la littérature exclut tout ordre > 5. |
| A7 | benchmark AAAI-26 (51 codes linéaires) | linear.mzn | ✅ | Kissat 29/51 en 1 h, GCS 11, Chuffed 6, baguette 1 | sur ce type de problème, le SAT pur domine nos modèles CP. |
| A8 | bug de `--time-limit` de baguette | dbg/ sur le nœud | ✅ | baguette dépasse sa limite d'environ 8 %, mais ses preuves sont complètes | les preuves illisibles venaient de notre timeout extérieur. Demande déposée dans WORKLOG. |

## B. Plan A, certifier des résultats connus (preuves VeriPB, jamais certifiés à ce jour)

Chaque ligne est un UNSAT. Une preuve acceptée par VeriPB donne une vérification indépendante d'un résultat publié.
On lance chaque instance avec GCS, baguette et Kissat (DRAT) pour comparer, et chaque désaccord est un bug à chercher.

| id | question | méthode | statut | résultat | ce que ça veut dire |
|---|---|---|---|---|---|
| B1 | Leech n'a aucun vecteur de norme 2 | Gram de Leech fixé, x entier borné par la diagonale de G⁻¹, xᵀGx = 2 | ⏳ | | premier certificat de la propriété qui fait de Leech un réseau extrémal. Il valide la chaîne de preuve sur les réseaux. |
| B2 | le code de Golay a une distance de 8, et non 4 | code fixé, recherche d'un mot de poids 4 | ⏳ | | même chose côté codes. C'est un test facile. |
| B3 | QR48 a une distance de 12 | idem | ⏳ | | certifie le code qui donne les réseaux extrémaux de dimension 48 par codes. |
| B4 | QR80 a une distance de 16 | idem | ⏳ | | c'est le code qu'utilisent Stehlé et Watkins pour prouver que N80 est extrémal. |
| B5 | P48p et P48q n'ont aucun vecteur de norme 2 ou 4 | Gram (catalogue de Nebe), énumération bornée | ⏳ | | certifierait l'extrémalité d'un réseau de dimension 48 (le minimum 6 suit). C'est la limite de l'énumération directe, on mesurera jusqu'où ça passe. |
| B6 | un [72,36,16] n'a pas d'automorphisme d'ordre 7 (Nebe 2012) | code invariant sous σ d'ordre 7, découpage en cas de l'article | ⏳ | | première vérification indépendante d'une exclusion publiée, qui n'existait jusqu'ici que comme calcul Magma. |
| B7 | idem pour Z3×Z3, D10, l'ordre 6, Z4, et Z2×Z2×Z2 | même schéma, un modèle par groupe | ⏳ | | certifie la liste des groupes encore possibles (ordre 1, 2, 3, 5, ou Z2×Z2). |
| B8 | non-existence de petits codes linéaires (40,8,17), (35,10,13) | linear.mzn | ⏳ | | permet de comparer les preuves VeriPB aux preuves DRAT sur des résultats connus. C'est l'angle de l'article AAAI. |

## C. Plan B, la question ouverte [72,36,16]

| id | question | méthode | statut | résultat | ce que ça veut dire |
|---|---|---|---|---|---|
| C1 | existe-t-il un [72,36,16] avec un automorphisme d'ordre 5 ? | code invariant sous σ d'ordre 5, recherche avec GCS | ⏳ | | SAT serait un résultat majeur (un problème ouvert depuis 1973). UNSAT réduirait le groupe à l'ordre 1, 2 ou 3. |
| C2 | idem pour l'ordre 3 | idem | ⏳ | | même chose. L'espace est plus grand et probablement hors de portée. |
| C3 | idem pour l'ordre 2 et pour Z2×Z2 | idem | ⏳ | | ces cas sont sans doute les plus durs. |

## D. Plan C, les réseaux directement (modèle de Gram)

| id | question | méthode | statut | résultat | ce que ça veut dire |
|---|---|---|---|---|---|
| D1 | retrouver un réseau pair unimodulaire de dimension 24 et de minimum 4 | Gram variable, coupes paresseuses sur les vecteurs courts (Fincke-Pohst) | ⏳ | | si on retrouve Leech, la méthode marche. Leech est le seul réseau possible, donc ça teste aussi l'unicité. |
| D2 | idem en dimension 48 avec un automorphisme imposé | idem | ⏳ | | retrouver P48p ou P48q. Un cinquième réseau serait nouveau. |

## Ce qu'on ne fera pas, et pourquoi

| cible | raison |
|---|---|
| un code ternaire [72,36,21] | il n'existe pas, parce que sa série de poids aurait un coefficient négatif |
| une énumération directe en dimension 72 et plus | personne ne la fait. Stehlé et Watkins estiment déjà plusieurs mois pour la norme 4 en dimension 80. |
| les réseaux en dimension 96 | aucune approche connue n'y arrive pour l'instant |
