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

## 4. Les codes correcteurs, sur un exemple qu'on suivra jusqu'au bout

**À quoi sert un code.** On veut envoyer 4 bits sur un canal bruité, où un bit peut s'inverser. On
envoie plutôt 8 bits, choisis de sorte que deux messages envoyables diffèrent toujours en au moins 4
positions. Si un seul bit est inversé en route, le mot reçu reste plus proche du mot envoyé que de tout
autre, et on corrige l'erreur. L'ensemble des mots envoyables s'appelle un **code**.

**L'exemple fil rouge : le code de Hamming étendu.** On part de 4 bits de message u = (u1, u2, u3, u4)
et on calcule 4 bits de contrôle en multipliant par une matrice A (les calculs sont modulo 2, donc
1 + 1 = 0, c'est le XOR) :

    G = [ I | A ] = 1 0 0 0 | 0 1 1 1        mot envoyé = (u, u·A)
                    0 1 0 0 | 1 0 1 1
                    0 0 1 0 | 1 1 0 1
                    0 0 0 1 | 1 1 1 0

Chaque mot du code est une somme (XOR) de lignes de G. Quelques exemples :

| lignes choisies S | partie gauche (= u) | partie droite (XOR des lignes de A) | poids |
|---|---|---|---|
| {1} | 1000 | 0111 | 1 + 3 = 4 |
| {1, 2} | 1100 | 0111 ⊕ 1011 = 1100 | 2 + 2 = 4 |
| {1, 2, 3} | 1110 | 1100 ⊕ 1101 = 0001 | 3 + 1 = 4 |
| {1, 2, 3, 4} | 1111 | 0001 ⊕ 1110 = 1111 | 4 + 4 = 8 |

On voit sur ce tableau la formule utilisée partout dans nos modèles, c'est-à-dire que le **poids**
(le nombre de 1) d'un mot vaut |S| plus le poids du XOR des lignes de A choisies. Si on énumère les
16 choix de S, on trouve le mot nul, 14 mots de poids 4 et un mot de poids 8 (tout à 1). On résume ça
par l'**énumérateur des poids** 1 + 14 x⁴ + x⁸.

**La notation [n, k, d].** C'est la carte d'identité d'un code linéaire.

- n est la **longueur** des mots, ici 8 ;
- k est la **dimension**, le nombre de bits de message, ici 4. Le code a 2^k = 16 mots ;
- d est la **distance minimale**, le plus petit poids d'un mot non nul, ici 4. Comme le code est
  stable par XOR, la distance entre deux mots est le poids de leur XOR, donc d est aussi la plus petite
  distance entre deux mots distincts. Un code de distance d corrige ⌊(d−1)/2⌋ erreurs.

Notre exemple est donc un code **[8, 4, 4]**. On veut d grand pour n et k donnés, mais les deux
s'opposent. Plus il y a de mots, moins ils peuvent être éloignés les uns des autres. C'est exactement la
même tension que pour les sphères, où on veut beaucoup de centres et une grande distance entre eux.

**Les deux propriétés qui comptent pour nous.** Notre exemple les a toutes les deux.

- **Auto-dual.** Deux mots quelconques du code ont un produit scalaire pair (ils ont un nombre pair
  de 1 en commun), et le code est le plus grand possible avec cette propriété (k = n/2). Par exemple
  10000111 et 01001011 ont deux 1 en commun. Sur la matrice, cela se lit A·Aᵀ = I.
- **Doublement pair.** Tous les poids sont multiples de 4. C'est le cas ici (0, 4 et 8).

**La version code du problème de départ.** Pour ces codes, la même théorie que celle de la section 3
(avec des polynômes invariants à la place des formes modulaires) donne la borne d ≤ 4 ⌊n/24⌋ + 4. Notre
[8, 4, 4] l'atteint. Le code de Golay [24, 12, 8] est le code extrémal de longueur 24. Il est unique, et
c'est le cousin du réseau de Leech. À la longueur 48, le code QR48 [48, 24, 12] est extrémal. À la
longueur 72, l'existence d'un code [72, 36, 16] est **un problème ouvert depuis 1973**.

## 5. Le pont entre codes et réseaux

À partir d'un code C, on fabrique un réseau en prenant tous les vecteurs entiers qui, réduits modulo 2,
donnent un mot de C. C'est la **construction A**.

    A(C) = { x ∈ Z^n : x mod 2 ∈ C },   avec la norme x·x / 2.

**Suite de l'exemple fil rouge.** Appliquée au code [8, 4, 4] de la section 4, la construction A donne
exactement E8, le meilleur empilement de la dimension 8. Comptons les vecteurs de norme 2, c'est-à-dire
les x entiers avec x·x = 4. Il y en a de deux sortes.

- Un ±1 sur chacune des 4 positions d'un mot de poids 4, et des 0 ailleurs. Réduit modulo 2, c'est le
  mot de code, donc x est dans le réseau. Il y a 14 mots de poids 4 et 2⁴ = 16 choix de signes, ce qui
  fait 224 vecteurs.
- ±2 sur une seule position. Réduit modulo 2, c'est le mot nul, qui est dans le code. Cela fait
  2 × 8 = 16 vecteurs.

On retrouve les 224 + 16 = 240 voisins de chaque boule dans E8. Le dictionnaire entre les deux mondes
se lit directement sur cet exemple.

| côté code | côté réseau (construction A) | sur l'exemple |
|---|---|---|
| mot de code c | vecteurs x ≡ c (mod 2) | 10000111 donne (1,0,0,0,0,1,1,1) et ses variantes de signe |
| poids w d'un mot 0/1 | norme w/2 | poids 4 donne norme 2 |
| distance minimale d | minimum min(d/2, 2) | d = 4 donne minimum 2 |
| auto-dual | unimodulaire | E8 est unimodulaire |
| doublement pair | pair | E8 est pair |
| énumérateur des poids | série thêta | 1 + 14x⁴ + x⁸ donne 1 + 240q + … |

Le problème se voit dans la ligne « minimum min(d/2, 2) » du dictionnaire. Les vecteurs ±2e_i sont
toujours là, et ont toujours une norme 4/2 = 2. La construction A ne peut donc jamais dépasser le
minimum 2, ce qui suffit en dimension 8 mais pas en dimension 24. Pour Leech,
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
- **Prouver qu'il n'y a rien** (réponse UNSAT). Sur l'exemple fil rouge, on demande « un mot non nul de
  poids ≤ 3 dans le code [8, 4, 4] ». Les variables sont les 4 bits u, et les contraintes calculent
  u·A puis bornent le poids total. Le solveur répond UNSAT, ce qui prouve d ≥ 4. C'est exactement le
  modèle `models/minweight.mzn`, avec QR48 ou QR80 à la place du code de Hamming. Un autre exemple est « trouve un vecteur non nul de norme 2
  dans le réseau de Leech ». Le modèle `models/shortvec.mzn` a pour variables le mot de code (u), le
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
(A·Aᵀ = I), donc le même code s'écrit aussi [Aᵀ | I]. Sur l'exemple fil rouge, un mot de poids ≤ 3 a au
plus un 1 à gauche ou au plus un 1 à droite. À gauche, cela veut dire une seule ligne de G, et les quatre
lignes ont un poids 4. À droite, c'est la même chose avec [Aᵀ | I]. Huit vérifications suffisent au
lieu de seize. En longueur 80, l'écart devient énorme. Un mot de poids au plus 12 a au plus 6 uns sur
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

## B. Plan A, certifier des résultats connus

Chaque ligne est un UNSAT. Une preuve acceptée par VeriPB donne une vérification indépendante d'un résultat
publié (à notre connaissance, aucun de ces résultats n'avait de certificat). Les chiffres détaillés par
solveur sont dans le tableau B-détail plus bas. ✔︎ veut dire « preuve vérifiée par VeriPB ».

| id | question | méthode | statut | résultat | ce que ça veut dire |
|---|---|---|---|---|---|
| B1 | Leech n'a aucun vecteur de norme 2 | `shortvec.mzn`, Leech = construction B du code de Golay + translaté, w·w ≤ 16 | ✅ ✔︎ | baguette 4,5 min, preuve 313 Mo vérifiée en 24 s. GCS 5 min, preuve 35 Go vérifiée en 40 min. | Leech est extrémal, avec un certificat. C'est le minimum 4 qui fait de lui le meilleur empilement en dimension 24. |
| B2 | Golay n'a aucun mot de poids 4 | `minweight.mzn`, code fixé | ✅ ✔︎ | moins d'une seconde pour tous les solveurs, preuves de quelques Mo | Golay a bien une distance de 8. |
| B3 | QR48 n'a aucun mot de poids ≤ 8 | `minweight.mzn`, puis découpage en deux moitiés | ✅ ✔︎ | sans découpage, preuve GCS de 32 Go. Avec découpage, 2 × 3 s et 2 × 360 Mo (GCS), 2 × 2,5 min et 2 × 143 Mo (baguette). | QR48 a une distance de 12, c'est le code extrémal de longueur 48. |
| B3b | QR72 n'a aucun mot de poids ≤ 8 | idem | ✅ ✔︎ | sans découpage, la preuve GCS dépasse 200 Go. Avec découpage, GCS 2 × 35 s et 2 × 4 Go, baguette 2 × 66 min et 2 × 1 Go. | distance ≥ 12 (QR72 n'est pas extrémal, il lui faudrait 16). Sert d'échelon de difficulté. |
| B4 | QR80 n'a aucun mot de poids ≤ 12 | idem | 🔄 | sans découpage, rien en 1 h. Avec découpage, UNSAT en 9 min (Chuffed) et 12 min (GCS) par moitié. La preuve GCS dépasse 200 Go, et baguette tourne encore. | QR80 a une distance de 16. C'est le code qu'utilisent Stehlé et Watkins pour le réseau N80. Pas encore certifié. |
| B4b | QR104 n'a aucun mot de poids ≤ 16 | idem | ❌ | UNKNOWN en 1 h, même avec découpage | c'est la limite actuelle du modèle CP. Le programme dédié `mindist` règle les quatre codes précédents en moins d'une seconde. |
| B5 | P48q n'a aucun vecteur de norme ≤ 4 | `shortvec.mzn`, découpage en trois cas (voir l'en-tête du modèle) | 🔄 | UNSAT par Chuffed dans les trois cas (19 min, 16 min, 31 s). GCS ne conclut dans aucun cas en 1 h. Preuves en cours. | P48q est extrémal (minimum 6). C'est vrai sans preuve, et la certification est en cours. |
| B5b | P48p n'a aucun vecteur de norme ≤ 4 | idem | ✅ sans preuve | UNSAT par Chuffed (55 min, 56 min, 3,5 min). GCS ne conclut pas. | P48p est extrémal. Certifier demandera un meilleur modèle ou beaucoup plus de temps. |
| B6 | un [72,36,16] n'a pas d'automorphisme d'ordre 7 (Feulner et Nebe) | `aut.mzn` (structure F ⊕ E de l'article), un cas par dimension k de la partie C1 | 🔄 | k = 0, 1 UNSAT ✔︎ (baguette et GCS). k = 2 UNSAT en 4 s avec Chuffed, mais GCS et baguette ne concluent pas en 2 h. k = 3, 4, 5 donnent des codes de la relaxation dont la distance est < 16, et la boucle paresseuse tourne. | les cas faciles du théorème sont reproduits. Les cas k = 3 à 5 sont ceux où l'article a énuméré 70 millions de sous-codes, et c'est là que tout se joue. La brisure de symétrie LEX est admise. |
| B7 | idem pour Z3×Z3, D10, l'ordre 6, Z4, Z2×Z2×Z2 | même schéma | ⏳ | | |
| B8 | non-existence de (40,8,17) et (35,10,13) | `linear.mzn` + CNF de l'article AAAI | ❌ | Chuffed, GCS et Kissat UNKNOWN en 1 h | même Kissat ne conclut pas en 1 h. L'article lui donnait 24 h. On laisse de côté. |

### B-détail : temps par solveur (secondes), taille de preuve, vérification

| instance | Chuffed | GCS | GCS + preuve | baguette (toujours avec preuve) |
|---|---|---|---|---|
| Leech, norme 2 | 0,2 | 4,1 | 308, 35 Go, ✔︎ en 2414 s | 269, 313 Mo, ✔︎ en 24 s |
| Golay, poids 4 | 0,2 | 0,2 | 0,2, 7 Mo, ✔︎ | 0,5, 2 Mo, ✔︎ |
| QR48, poids ≤ 8, sans découpage | 7,4 | 27 | 238, 32 Go, ✔︎ en 1251 s (38 Go de RAM) | > 7200 |
| QR48, avec découpage (par moitié) | 0,6 | 0,9 | 3,3, 360 Mo, ✔︎ en 20 s | 125 à 153, 143 Mo, ✔︎ en 7 s |
| QR72, poids ≤ 8, sans découpage | 150 | 617 | preuve > 200 Go | > 7200 |
| QR72, avec découpage (par moitié) | 3 | 6 | 34, 4,2 Go, ✔︎ en 210 s | 3910 à 4048, 1,1 Go, ✔︎ en 57 s |
| QR80, poids ≤ 12, sans découpage | > 3600 | > 3600 | | |
| QR80, avec découpage (par moitié) | 524 | 713 | preuve > 200 Go | en cours |
| QR104, poids ≤ 16, avec découpage | > 3600 | > 3600 | | |
| P48q, norme ≤ 4 (b=0 gauche, b=0 droite, b=1) | 1117, 983, 31 | > 3600 ×3 | en cours | en cours |
| P48p, norme ≤ 4 (idem) | 3316, 3343, 210 | > 3600 ×3 | | |
| ordre 7, k = 0 / 1 / 2 | 0,9 / 3,3 / 4,3 | 0,9 / 3,3 / > 3600 | ✔︎ / ✔︎ / > 7200 | ✔︎ / ✔︎ / > 7200 |

Les tests de contrôle (SAT attendu) passent tous. On trouve un vecteur de norme 4 dans Leech, de norme 6
dans P48p et P48q, et des mots de poids 12 et 16 dans QR48 et QR80, avec des preuves SAT vérifiées.

## C. Plan B, la question ouverte [72,36,16]

| id | question | méthode | statut | résultat | ce que ça veut dire |
|---|---|---|---|---|---|
| C1 | existe-t-il un [72,36,16] avec un automorphisme d'ordre 5 ? | `aut.mzn`, type de cycles 5^14 1^2, relaxation K et boucle paresseuse | 🔄 | la relaxation K=2 rend en 3 h un code auto-dual doublement pair de distance 12, invariant par l'ordre 5. La boucle paresseuse tourne avec 4 h par tour. | rien de conclusif pour l'instant. SAT avec d=16 serait un résultat majeur. UNSAT réduirait le groupe à l'ordre 1, 2, 3 ou 4. |
| C2 | idem pour l'ordre 3 (type 3^24) | idem | 🔄 | un premier tour n'a pas abouti en 1 h | probablement hors de portée. |
| C3 | idem pour l'ordre 2 et pour Z2×Z2 | | ⏳ | | le modèle actuel ne traite que les ordres premiers impairs. |

## D. Plan C, les réseaux directement (modèle de Gram)

| id | question | méthode | statut | résultat | ce que ça veut dire |
|---|---|---|---|---|---|
| D1 | retrouver un réseau pair unimodulaire de dimension 24 et de minimum 4 | Gram variable, coupes paresseuses | mis de côté | | la contrainte det G = 1 n'est pas exprimable simplement en CP. Et en passant par un code, D1 se ramène à A1 (Golay donne Leech). Toute la littérature passe par les codes, et les résultats du bloc B montrent pourquoi. |
| D2 | idem en dimension 48 avec un automorphisme imposé | idem | mis de côté | | même raison. |

## Ce qu'on retient (2026-11-17)

- **Ce qui marche.** Avec le bon modèle, on certifie l'extrémalité de Leech et la distance des codes
  de Golay, QR48 et QR72. La seule chose admise est le découpage en deux moitiés, qui tient en une
  ligne sur papier. Les preuves font de quelques Mo à 4 Go, et VeriPB les vérifie en quelques minutes.
- **Ce qui décide de tout, c'est le modèle.** Le découpage en deux moitiés divise les temps par 10 à
  50 et les preuves par 100. Le solveur ne trouve pas seul cet argument.
- **GCS contre baguette.** GCS résout plus vite, mais ses preuves sont 3 à 100 fois plus grosses.
  Baguette résout plus lentement, souvent de beaucoup, mais ses preuves sont plus petites et se
  vérifient vite. Sur le modèle d'automorphismes (k=2), Chuffed conclut en 4 s alors que GCS et
  baguette ne concluent pas en 2 h. C'est un écart à comprendre, et peut-être un bon cas test pour
  baguette.
- **Les limites actuelles.** QR104 en minweight. P48 avec preuve, où seul Chuffed conclut. Les cas
  k = 3 à 5 de l'ordre 7, qui ont demandé à Feulner et Nebe une énumération de 70 millions de codes.

## Ce qu'on ne fera pas, et pourquoi

| cible | raison |
|---|---|
| un code ternaire [72,36,21] | il n'existe pas, parce que sa série de poids aurait un coefficient négatif |
| une énumération directe en dimension 72 et plus | personne ne la fait. Stehlé et Watkins estiment déjà plusieurs mois pour la norme 4 en dimension 80. |
| les réseaux en dimension 96 | aucune approche connue n'y arrive pour l'instant |
