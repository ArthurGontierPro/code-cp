# Résultats

Ce fichier a deux parties. La première est un tutoriel qui explique ce qu'on cherche, pour quelqu'un
qui arrive sur le projet (niveau master, sans connaître les réseaux ni les codes). La seconde est le
tableau des expériences.

---

# Partie 1. Tutoriel : ce qu'on cherche et pourquoi

## 1. Empiler des sphères

On veut ranger des boules toutes identiques dans l'espace de dimension n, sans qu'elles se chevauchent,
en remplissant le plus de place possible. En dimension 2, la meilleure façon est l'arrangement en nid
d'abeille, où chaque disque touche six voisins. En dimension 3, c'est l'empilement des oranges chez
le primeur (Kepler l'avait conjecturé en 1611, Hales l'a prouvé en 1998 avec l'aide de l'ordinateur).

Dans les dimensions plus grandes, on ne sait presque rien. Il y a deux exceptions spectaculaires, les
dimensions 8 et 24, où Viazovska (médaille Fields 2022) a prouvé que les empilements optimaux sont
ceux donnés par deux objets très particuliers, le réseau E8 et le réseau de Leech. Ce projet part de
la question suivante. Que se passe-t-il en dimension 48, 72, 96, c'est-à-dire aux multiples de 24 ?

## 2. Les réseaux

Un réseau, c'est l'ensemble des combinaisons entières de n vecteurs indépendants b_1, …, b_n.
Par exemple Z² (les points à coordonnées entières du plan) est le réseau engendré par (1,0) et (0,1).
On pose une boule sur chaque point du réseau. Toutes les boules ont le même rayon, égal à la moitié de
la plus petite distance entre deux points, donc à la moitié de la longueur du plus court vecteur non nul.

Le vocabulaire utile :

- la **norme** d'un vecteur v est v·v, le carré de sa longueur ;
- le **minimum** μ du réseau est la plus petite norme d'un vecteur non nul ;
- la **matrice de Gram** G est la matrice des produits scalaires b_i·b_j. La norme du vecteur
  x_1 b_1 + … + x_n b_n vaut xᵀGx, donc toute la géométrie du réseau tient dans G ;
- le **déterminant** det G est le carré du volume d'une maille. Un réseau est **unimodulaire** si
  det G = 1, c'est-à-dire si une maille a un volume 1 ;
- il est **pair** si toutes les normes sont des entiers pairs.

Pour un réseau unimodulaire, il y a exactement un point par unité de volume. La densité de
l'empilement ne dépend donc que du rayon des boules, c'est-à-dire du minimum μ. **Chercher un bon
empilement revient alors à chercher un réseau pair unimodulaire de minimum le plus grand possible.**

Exemple. Le réseau E8, en dimension 8, est pair, unimodulaire, de minimum 2. Il a 240 vecteurs de
norme 2, donc chaque boule en touche 240 autres. Le réseau de Leech, en dimension 24, est pair,
unimodulaire, de minimum 4, et chaque boule en touche 196 560.

## 3. Pourquoi les multiples de 24

Les réseaux pairs unimodulaires n'existent qu'en dimension multiple de 8. Pour un tel réseau, on
range les vecteurs par norme dans une série, la **série thêta**

    θ(q) = Σ_v q^(v·v / 2) = 1 + a_1 q + a_2 q² + …,     a_m = nombre de vecteurs de norme 2m.

Un théorème profond dit que θ appartient à un espace de **formes modulaires** de dimension ⌊n/24⌋ + 1.
On peut donc choisir les ⌊n/24⌋ premiers coefficients a_1, a_2, … et tout le reste en découle. Au
mieux on annule les ⌊n/24⌋ premiers, ce qui donne la borne

    μ ≤ 2 ⌊n/24⌋ + 2.

Un réseau qui atteint cette borne est dit **extrémal**. La borne ne monte qu'aux multiples de 24.
C'est pour ça que 24, 48, 72, 96 sont les dimensions intéressantes.

| dimension | minimum extrémal | réseaux extrémaux connus |
|---|---|---|
| 8 | 2 | E8 (unique) |
| 24 | 4 | Leech (unique) |
| 48 | 6 | 4 connus (P48p, P48q, P48n, P48m), liste complète inconnue |
| 72 | 8 | 1 connu (Γ72, Nebe 2010), cherché pendant 40 ans |
| 96 | 10 | aucun connu, question ouverte |

Une conséquence pratique de la série thêta est que si on sait qu'un réseau n'a aucun vecteur de norme
inférieure au minimum extrémal, alors il est extrémal et on connaît exactement son nombre de vecteurs
minimaux. **Prouver qu'un réseau est extrémal revient donc à prouver qu'un certain ensemble de
vecteurs courts est vide.** C'est exactement le genre de question qu'un solveur de contraintes sait
traiter, avec une réponse UNSAT.

## 4. Les codes correcteurs

Un code binaire linéaire de longueur n est un sous-espace C de F_2^n (des mots de n bits, stable par
XOR). Le **poids** d'un mot est son nombre de 1. La **distance minimale** d est le plus petit poids
d'un mot non nul. On note [n, k, d] un code de dimension k.

Les codes qui nous intéressent sont les analogues des réseaux pairs unimodulaires :

- **auto-dual** (C = C⊥, tout couple de mots a un produit scalaire nul modulo 2), l'analogue
  d'unimodulaire ;
- **doublement pair** (tous les poids sont multiples de 4), l'analogue de pair.

La même théorie (des polynômes invariants à la place des formes modulaires) donne la borne
d ≤ 4 ⌊n/24⌋ + 4, et un code qui l'atteint est extrémal. Le code de Golay [24, 12, 8] est le code
extrémal de longueur 24. Il est unique, et c'est le cousin du réseau de Leech. À la longueur 48, le
code QR48 [48, 24, 12] est extrémal. À la longueur 72, l'existence d'un code [72, 36, 16] est **un
problème ouvert depuis 1973**.

On écrit un tel code sous forme systématique, avec une matrice génératrice G = [I | A]. Un mot du code
s'obtient en choisissant un ensemble S de lignes et en les additionnant. Son poids vaut |S| plus le
poids du XOR des lignes de A choisies.

## 5. Le pont entre codes et réseaux

À partir d'un code C, on fabrique un réseau en prenant tous les vecteurs entiers qui, réduits modulo 2,
donnent un mot de C. C'est la **construction A**.

    A(C) = { x ∈ Z^n : x mod 2 ∈ C },   avec la norme x·x / 2.

Exemple. Le code de Hamming étendu [8, 4, 4] donne exactement E8. Les vecteurs de norme 2 sont de deux
sortes, ±2e_i (car 2e_i ≡ 0 mod 2, et 0 est un mot du code), et les mots de poids 4 avec des signes ±1.

Le problème est que ±2e_i est toujours là et a toujours une norme 4/2 = 2. La construction A ne peut
donc jamais dépasser le minimum 2, ce qui suffit en dimension 8 mais pas en dimension 24. Pour Leech,
on ajoute deux étapes :

1. la **construction B**, qui ne garde que les x dont la somme des coordonnées est multiple de 4. Cela
   élimine les ±2e_i. Le réseau obtenu a un minimum plus grand, mais il est deux fois trop peu dense ;
2. on double la densité en ajoutant un **translaté**, c'est-à-dire une seconde copie du réseau décalée
   par le vecteur (−3, 1, 1, …, 1)/√8.

Partir du code de Golay donne alors le réseau de Leech. Pour P48p et P48q, c'est la même recette, mais
sur des codes **ternaires** (modulo 3) [48, 24, 15], suivie elle aussi d'un doublement de densité.
Dans la littérature, tous les réseaux extrémaux en dimension 48 et plus viennent de ce genre de
construction. Les preuves d'extrémalité passent aussi par le code, parce que l'énumération directe de
tous les vecteurs courts devient hors de portée vers 60 à 80 dimensions (Stehlé et Watkins estiment
à plusieurs mois la recherche des vecteurs de norme 4 en dimension 80).

## 6. Ce que fait le solveur

On pose trois sortes de questions à un solveur de contraintes (Chuffed, GCS, baguette).

- **Trouver** (réponse SAT). Par exemple, « trouve un code auto-dual doublement pair de longueur 48 et
  de distance 12 ». Le solveur rend le code, qu'on vérifie indépendamment en calculant sa distance.
- **Prouver qu'il n'y a rien** (réponse UNSAT). Par exemple, « trouve un vecteur non nul de norme 2 dans
  le réseau de Leech ». Le modèle `models/shortvec.mzn` a pour variables le mot de code (u), le
  décalage (b ∈ {0,1}) et les coordonnées (w). Ses contraintes disent que w appartient au réseau et
  que w·w ≤ 2·8. Si le solveur répond UNSAT, Leech n'a pas de vecteur de norme 2.
- **Certifier**. Un solveur est un programme de plusieurs dizaines de milliers de lignes, et il peut
  avoir des bugs. Un UNSAT seul ne vaut donc pas une preuve mathématique. GCS et baguette écrivent, en
  plus de la réponse, un journal de preuve au format VeriPB. C'est une suite d'étapes de raisonnement
  élémentaires, que le vérificateur `veripb` (un petit programme indépendant) relit une par une. Si
  VeriPB écrit `VERIFIED UNSATISFIABLE`, on n'a plus besoin de faire confiance au solveur, seulement au
  vérificateur et à la traduction du problème en contraintes.

Ce qui reste admis, et qu'on signale à chaque fois dans le tableau :

- la **brisure de symétrie**. Pour aller plus vite, on impose parfois un ordre sur les lignes ou les
  colonnes (contrainte `LEX`). C'est correct mathématiquement, mais cette étape n'est pas encore
  justifiée dans le journal de preuve ;
- le **découpage en cas** fait à la main (voir la section 7). Chaque cas a sa preuve, et l'argument
  qui dit que les cas couvrent tout tient en une ligne sur papier ;
- la **relaxation**. Pour la distance, on n'écrit parfois la contrainte que pour les combinaisons
  d'au plus K lignes. Un UNSAT de la relaxation reste un UNSAT du vrai problème. Un SAT, en revanche,
  ne prouve rien, et il faut vérifier le code trouvé.

## 7. Deux idées qui changent tout

**L'argument des deux moitiés.** Dans un code auto-dual écrit [I | A], la matrice A est inversible
(A·Aᵀ = I), donc le même code s'écrit aussi [Aᵀ | I]. Un mot de poids au plus 12 a au plus 6 uns sur
sa moitié gauche, ou au plus 6 uns sur sa moitié droite. On lance donc deux instances, une avec A et une
avec Aᵀ, chacune limitée à 6 lignes choisies. L'effet est énorme. Pour QR80, le solveur sans découpage
n'avait pas conclu après une heure, et avec le découpage il conclut en 9 minutes par moitié. Les
preuves de QR48 passent de 32 Go à 2 × 360 Mo.

La leçon générale est qu'un solveur ne trouve pas tout seul un argument mathématique un peu global
comme celui-ci. Le lui donner sous forme de découpage en cas coûte une ligne de papier et fait gagner
des ordres de grandeur.

**Les automorphismes.** Un automorphisme d'un code est une permutation des coordonnées qui envoie le
code sur lui-même. Les codes et réseaux connus ont presque tous beaucoup de symétries, et la méthode
classique pour en chercher de nouveaux consiste à imposer un groupe de symétries, ce qui réduit
énormément l'espace de recherche. Pour un code [72, 36, 16], une série d'articles (Nebe, Borello,
Feulner, et d'autres) a montré que son groupe d'automorphismes est minuscule, d'ordre 1, 2, 3, 4 ou 5,
ou le groupe Z2 × Z2. Chacune de ces exclusions est un calcul sur ordinateur, sans certificat. Les
reproduire avec un journal de preuve, puis attaquer les cas encore ouverts (ordre 5, ordre 3), c'est
l'objet des lignes B6 et C du tableau.

## 8. Comment lire le tableau

- **Chuffed** est un solveur CP avec apprentissage de clauses, très rapide mais sans preuve.
- **GCS** (Glasgow Constraint Solver) est plus lent, mais peut produire une preuve VeriPB.
- **baguette** est notre solveur avec preuve. Il est souvent plus lent, mais ses preuves sont
  parfois beaucoup plus petites, et le comparer aux autres sert aussi à lui trouver des bugs.
- On lance d'abord Chuffed et GCS sans preuve pour voir si l'instance est faisable. On ne lance les
  versions avec preuve (GCS, baguette, puis `veripb`) que si c'est le cas.
- `pbp_MB` est la taille du journal de preuve, `vwall` le temps de vérification. Une ligne n'est
  **certifiée** que si VeriPB a écrit `VERIFIED`.

---

# Partie 2. Tableau des expériences

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
