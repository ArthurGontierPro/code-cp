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
envoie plutôt 8 bits, choisis de sorte que deux messages envoyables diffèrent toujours sur au moins 4
bits. Si un seul bit est inversé en route, le mot reçu reste plus proche du mot envoyé que de tout
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

Un peu de vocabulaire. Un mot est une suite de n bits, et sa **coordonnée i** est son i-ème bit. Le
**support** d'un mot est l'ensemble des coordonnées où il vaut 1. Par exemple le mot 10000111 a pour
support {1, 6, 7, 8}. Le **poids** d'un mot est la taille de son support, c'est-à-dire son nombre de 1.

On voit sur ce tableau la formule utilisée partout dans nos modèles, c'est-à-dire que le poids d'un mot
vaut |S| plus le poids du XOR des lignes de A choisies. Si on énumère les
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

**Les objets.** Côté réseau, on manipule des vecteurs x = (x_1, …, x_n) dont les n **coordonnées** x_i
sont des entiers (on écrit x ∈ Z^n). Côté code, on manipule des mots de n bits. On passe d'un vecteur à
un mot en **réduisant chaque coordonnée modulo 2**, c'est-à-dire en remplaçant chaque x_i par son reste
dans la division par 2 (0 si x_i est pair, 1 s'il est impair). Par exemple le vecteur (3, 0, −1, 2)
se réduit en le mot 1010. On note e_i le vecteur qui a un 1 à la coordonnée i et des 0 ailleurs.

**La construction A.** À partir d'un code C de longueur n, on garde tous les vecteurs à coordonnées
entières dont la réduction modulo 2 est un mot de C :

    A(C) = { x ∈ Z^n : (x_1 mod 2, …, x_n mod 2) ∈ C }.

C'est bien un réseau, puisque la somme de deux tels vecteurs se réduit en la somme (XOR) de deux mots du
code, qui est encore dans le code. On garde les coordonnées entières pour calculer facilement, mais on
mesure la norme d'un vecteur de A(C) par x·x / 2, c'est-à-dire la somme des x_i² divisée par 2. Ce
facteur 1/2 revient à rétrécir tout le réseau d'un facteur √2, et c'est ce rétrécissement qui le rend
unimodulaire quand le code est auto-dual.

**Suite de l'exemple fil rouge.** Appliquée au code [8, 4, 4] de la section 4, la construction A donne
exactement E8, le meilleur empilement de la dimension 8. Comptons les vecteurs de E8 de norme 2,
c'est-à-dire les vecteurs x de A(C) tels que x_1² + … + x_8² = 4. Une somme de huit carrés d'entiers ne
vaut 4 que de deux façons, quatre coordonnées égales à ±1 (et les autres nulles), ou une coordonnée
égale à ±2 (et les autres nulles).

- Quatre coordonnées à ±1. La réduction modulo 2 de x est le mot qui vaut 1 sur ces quatre
  coordonnées. Le vecteur x est donc dans le réseau exactement quand ce mot de poids 4 est un mot du
  code, c'est-à-dire quand les quatre coordonnées forment le support d'un des 14 mots de poids 4. Pour
  chacun, on choisit librement les 4 signes, soit 2⁴ = 16 choix. Cela fait 14 × 16 = 224 vecteurs.
  Par exemple, le mot 10000111 donne (1, 0, 0, 0, 0, 1, 1, 1), (−1, 0, 0, 0, 0, 1, 1, 1), et ainsi
  de suite.
- Une coordonnée à ±2. C'est le vecteur ±2e_i. Sa réduction modulo 2 est le mot nul, qui est toujours
  dans le code. Cela fait 2 × 8 = 16 vecteurs.

On retrouve les 224 + 16 = 240 voisins de chaque boule dans E8. Le dictionnaire entre les deux mondes
se lit directement sur cet exemple.

| côté code | côté réseau (construction A) | sur l'exemple |
|---|---|---|
| un mot de code c | les vecteurs x dont la réduction modulo 2 vaut c | le mot 10000111 donne (1,0,0,0,0,1,1,1) et ses variantes de signe |
| un mot de poids w | le vecteur à coordonnées 0 et 1 qui le recopie, de norme w/2 | poids 4 donne norme 2 |
| distance minimale d | minimum égal à min(d/2, 2) | d = 4 donne minimum 2 |
| auto-dual | unimodulaire | E8 est unimodulaire |
| doublement pair | pair | E8 est pair |
| énumérateur des poids | série thêta | 1 + 14x⁴ + x⁸ donne 1 + 240q + … |

Le problème se voit dans la ligne « minimum égal à min(d/2, 2) » du dictionnaire. Les vecteurs ±2e_i
sont toujours dans A(C), quel que soit le code, et ont toujours une norme 4/2 = 2. La construction A ne
peut donc jamais dépasser le minimum 2, ce qui suffit en dimension 8 mais pas en dimension 24. Pour
Leech, on part du code de Golay et on ajoute deux étapes. Les vecteurs ont alors des coordonnées entières
et une norme égale à x·x / 8, c'est-à-dire qu'on rétrécit cette fois d'un facteur √8.

1. la **construction B**. Parmi les vecteurs y de la construction A, on ne garde que ceux dont la
   somme des coordonnées y_1 + … + y_n est multiple de 4, puis on les multiplie par 2. Le vecteur 2e_i
   a pour somme 2, donc il disparaît. Le réseau obtenu a un minimum de 4, mais il a deux fois trop peu
   de points par unité de volume pour être unimodulaire ;
2. on double la densité en ajoutant un **translaté**, c'est-à-dire une seconde copie du même réseau
   décalée du vecteur (−3, 1, 1, …, 1). Ce vecteur a pour norme (9 + 23)/8 = 4.

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
| B4 | QR80 n'a aucun mot de poids ≤ 12 | idem, puis chaque moitié découpée selon la 1re, la 2e, puis la 3e ligne choisie (cas disjoints, lancés en parallèle) | ✅ ✔︎ | 2154 preuves baguette vérifiées (52 cas au 1er niveau, 1152 au 2e, 950 au 3e). Un script vérifie que ces cas couvrent tous les mots. Au total 168 Go de preuves, 149 heures-cœur de résolution, 3,6 h de vérification. | QR80 a une distance de 16, avec un certificat. C'est le code qu'utilisent Stehlé et Watkins pour le réseau N80. Admis : le découpage en moitiés et en cas, chacun tenant en une ligne. |
| B4c | QR80, avec les automorphismes | `minweight_fix.mzn` : deux moitiés, et trois coordonnées imposées dans le support, parce que PSL(2,p) est 3-homogène pour p ≡ 3 mod 4. Validé par comptage : 21 mots de poids 8 dans Golay et 220 de poids 12 dans QR48 par triplet, comme le veut le 3-design. | 🔄 | Le gain dépend de l'endroit où tombent les trois coordonnées. Avec les trois à gauche, la moitié gauche passe à 1,2 s avec Chuffed (au lieu de 523 s), et à 147 s avec baguette, preuve de 223 Mo ✔︎. La moitié droite, où ces coordonnées ne sont pas des variables de branchement, reste à 196 s. Avec deux coordonnées à gauche et une à droite, Chuffed met 7,6 s + 39,5 s, soit 47 s au lieu de 1048 s pour les deux moitiés. Baguette en cours avec ce triplet, et QR104 avec les deux triplets. | les symétries du code divisent le travail par plusieurs centaines. Admis : la 3-homogénéité (un théorème de groupes), en plus des deux moitiés. |
| B4b | QR104 n'a aucun mot de poids ≤ 16 | `minweight_fix.mzn` : deux moitiés, puis trois coordonnées imposées (deux à gauche, une à droite), puis la moitié droite découpée selon la 2e ligne choisie (52 cas) | ✅ sans preuve | Chuffed : moitié gauche UNSAT en 32 min (GCS 50 min), moitié droite 52 cas UNSAT, 2,6 h au total, 25 min pour le plus long. Sans les automorphismes, rien en 1 h. | QR104 a une distance de 20, c'est le code extrémal de longueur 104 (valeur connue, retrouvée). Admis : la 3-homogénéité de PSL(2,103), en plus des moitiés et du découpage. La preuve baguette est l'étape suivante. |
| B5 | P48q n'a aucun vecteur de norme ≤ 4 | `shortvec.mzn`, découpage en trois cas (voir l'en-tête du modèle) | 🔄 | UNSAT par Chuffed dans les trois cas (19 min, 16 min, 31 s). GCS ne conclut dans aucun cas en 1 h. Preuves en cours. | P48q est extrémal (minimum 6). C'est vrai sans preuve, et la certification est en cours. |
| B5b | P48p n'a aucun vecteur de norme ≤ 4 | idem | ✅ sans preuve | UNSAT par Chuffed (55 min, 56 min, 3,5 min). GCS ne conclut pas. | P48p est extrémal. Certifier demandera un meilleur modèle ou beaucoup plus de temps. |
| B6 | un [72,36,16] n'a pas d'automorphisme d'ordre 7 (Feulner et Nebe) | `aut.mzn` (structure F ⊕ E de l'article), un cas par dimension k de la partie C1 | 🔄 | k = 0, 1, 2 UNSAT ✔︎. Pour k = 2, baguette conclut en 5 s avec une preuve de 1 Mo si on branche sur les bits générateurs en essayant 1 d'abord (voir B-heur), et ne conclut pas en 30 min sinon. k = 3, 4, 5 donnent des codes de la relaxation dont la distance est < 16, et la boucle paresseuse tourne. | les cas faciles du théorème sont reproduits. Les cas k = 3 à 5 sont ceux où l'article a énuméré 70 millions de sous-codes, et c'est là que tout se joue. La brisure de symétrie LEX est admise. |
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
| QR80, avec découpage (par moitié) | 524 | 713 | preuve > 200 Go | > 7200 |
| QR80, moitiés × 1re ligne (80 cas) | ≤ 86 par cas | | | 52 cas ✔︎, les cas 1re ligne ≤ 14 > 3 h |
| QR80, × 2e ligne (1178 cas) | | | | 1152 cas ✔︎, 26 cas > 2 h |
| QR80, × 3e ligne pour ces 26 (950 cas) | | | | 950 cas ✔︎. QR80 complet. |
| QR104, poids ≤ 16, avec découpage | > 3600 | > 3600 | | |
| P48q, norme ≤ 4 (b=0 gauche, b=0 droite, b=1) | 1117, 983, 31 | > 3600 ×3 | en cours | en cours |
| P48p, norme ≤ 4 (idem) | 3316, 3343, 210 | > 3600 ×3 | | |
| ordre 7, k = 0 / 1 / 2 | 0,9 / 3,3 / 4,3 | 0,9 / 3,3 / > 3600 | ✔︎ / ✔︎ / > 7200 | ✔︎ / ✔︎ / 5,2 avec `indomain_max`, 1 Mo, ✔︎ |

### B-heur : l'effet de l'heuristique de branchement (2026-11-18, `bench/heur.sh`)

| instance | recherche | Chuffed | baguette |
|---|---|---|---|
| QR48, une moitié | sans annotation | 23 668 nœuds, 0,6 s | 23 367 nœuds, 135 s |
| | bits u dans l'ordre, 1 d'abord | 11 710 nœuds, 0,3 s | 23 429 nœuds, 92 s |
| QR72, une moitié | sans annotation | 90 500 nœuds, 2,8 s | 75 750 nœuds, > 1800 s |
| ordre 7, k = 2 | sans annotation | 11 nœuds, 0,01 s | 51 000 nœuds, > 1800 s |
| | bits générateurs dans l'ordre, 0 d'abord | 16 millions de nœuds, > 1800 s | 48 000 nœuds, > 1800 s |
| | bits générateurs dans l'ordre, 1 d'abord | 140 nœuds, 0,01 s | 158 nœuds, 5,2 s, preuve 1 Mo ✔︎ |

Les temps de Chuffed sont ceux du solveur seul. L'aplatissement ajoute environ 4 s pour l'ordre 7.

Sur les codes fixés, l'heuristique ne change presque rien. Baguette visite autant de nœuds que Chuffed,
mais chaque nœud lui coûte environ 200 fois plus, et ce coût augmente avec le nombre de clauses
apprises. Sur le modèle d'automorphismes, c'est le choix de la valeur qui décide, pour les deux
solveurs. Essayer 1 d'abord résout le cas k = 2 en 150 nœuds, alors qu'essayer 0 d'abord ne finit
pas en 30 min. L'écart qu'on attribuait à baguette venait donc de l'heuristique par défaut. Ces
mesures, une étude d'heuristiques et l'oubli de clauses selon le LBD sont demandés à baguette dans
son WORKLOG. Le baguette du nœud est une version ancienne (2c97b16), et il faudra refaire la mesure
avec la version courante.

Les tests de contrôle (SAT attendu) passent tous. On trouve un vecteur de norme 4 dans Leech, de norme 6
dans P48p et P48q, et des mots de poids 12 et 16 dans QR48 et QR80, avec des preuves SAT vérifiées.

## C. Plan B, la question ouverte [72,36,16]

| id | question | méthode | statut | résultat | ce que ça veut dire |
|---|---|---|---|---|---|
| C1 | existe-t-il un [72,36,16] avec un automorphisme d'ordre 5 ? | `aut.mzn`, type de cycles 5^14 1^2, relaxation K et boucle paresseuse | 🔄 | la relaxation K=2 rend en 3 h un code auto-dual doublement pair de distance 12, invariant par l'ordre 5. La boucle paresseuse tourne avec 4 h par tour. | rien de conclusif pour l'instant. SAT avec d=16 serait un résultat majeur. UNSAT réduirait le groupe à l'ordre 1, 2, 3 ou 4. |
| C2 | idem pour l'ordre 3 (type 3^24) | idem | 🔄 | aucun tour n'aboutit en 4 h | probablement hors de portée. |
| C3 | idem pour l'ordre 2 et pour Z2×Z2 | | ⏳ | | le modèle actuel ne traite que les ordres premiers impairs. |

Note (2026-11-18). Une partie des « UNKNOWN » des boucles paresseuses (ordre 7, k = 3) n'étaient pas
des timeouts. MiniZinc 2.10.1 plantait (segfault) en aplatissant le modèle quand les combinaisons
paresseuses dépassaient environ 3500 ensembles d'une vingtaine de lignes. Le XOR de ces ensembles est
maintenant écrit comme une parité linéaire, et les boucles sont relancées avec des tours de 8 h.

## D. Plan C, les réseaux directement (modèle de Gram)

| id | question | méthode | statut | résultat | ce que ça veut dire |
|---|---|---|---|---|---|
| D1 | retrouver un réseau pair unimodulaire de dimension 24 et de minimum 4 | Gram variable, coupes paresseuses | mis de côté | | la contrainte det G = 1 n'est pas exprimable simplement en CP. Et en passant par un code, D1 se ramène à A1 (Golay donne Leech). Toute la littérature passe par les codes, et les résultats du bloc B montrent pourquoi. |
| D2 | idem en dimension 48 avec un automorphisme imposé | idem | mis de côté | | même raison. |

## E. Ce que les preuves admettent, et comment on le teste

VeriPB prouve qu'un fichier `.opb` n'a pas de solution. Tout raccourci du modèle (un découpage, une
borne de domaine, une brisure de symétrie) est écrit dans ce fichier comme un axiome, et le
vérificateur ne peut pas savoir s'il est justifié. Une borne fausse d'une unité donnerait un UNSAT faux
avec une preuve parfaitement vérifiée. Ce tableau liste ces axiomes et la façon dont on les teste.

Le test principal est un test d'équivalence par énumération (`scripts/equivcount.py`, `bench/equiv.sh`).
On prend une instance où la réponse est SAT et où le nombre exact de solutions est connu (énumérateur des
poids d'un code, série thêta d'un réseau). On énumère toutes les solutions avec Chuffed, on les ramène aux
coordonnées d'origine, et on vérifie deux choses. Le modèle complet doit donner exactement le nombre
connu, sans doublon. Chaque découpage doit redonner l'ensemble de départ, avec des cas disjoints pour les
cubes.

| id | axiome | où il sert | justification | test | statut |
|---|---|---|---|---|---|
| E1 | l'instance est bien le code annoncé | B2 à B4b | calcul fini dans `gen_instances.py` (rang, auto-dual, doublement pair) | Golay donne 759 mots de poids 8, QR48 donne 17296 mots de poids 12 | ✅ 759 et 17296, sans doublon |
| E2 | chercher jusqu'au poids d−4 suffit | B2 à B4b | le code est doublement pair, donc aucun poids entre d−3 et d−1 | calcul fini, vérifié dans `gen_instances.py` | ✅ |
| E3 | les deux moitiés couvrent tous les mots | B3 à B4b | A·Aᵀ = I (vérifié en Python), et un mot de poids ≤ W a au plus W/2 uns d'un côté | moitié gauche ∪ moitié droite = modèle complet | ✅ Golay (507 + 507 mots, union 759), QR48 (10915 + 10915, union 17296) |
| E4 | les cubes FIRST/SECOND/THIRD forment une partition | B4 | un script vérifie que les 2154 cas de QR80 couvrent l'arbre | sur tout l'arbre de profondeur 3, chaque nœud est l'union disjointe de ses fils | ✅ Golay (754 runs), QR48 (5250 runs) |
| E5 | le modèle décrit bien le réseau (construction B ou B3, translaté T, bornes W, Y et z) | B1, B5 | SPLAG ch. 5 et 7, bornes calculées à la main dans l'en-tête de `shortvec.mzn` | Leech donne 196560 vecteurs de norme 4 (98256 avec b=0, 98304 avec b=1), P48p et P48q donnent 52416000 vecteurs de norme 6 | Leech ✅ (196560 = 98256 + 98304, en 16 s). P48 🔄 |
| E6 | le découpage de P48 (b=0 coupé en deux moitiés, b=1) | B5 | même argument que E3 sur le mot y mod 3 | à la norme 6 avec HALF = 9, l'union des deux moitiés redonne tout le cas b=0 | 🔄 |
| E7 | le théorème de structure, la forme systématique, le type de cycles, k ≤ c/2 et LEX | B6, C1, C2 | Huffman, Feulner–Nebe, Conway–Pless (papier). LEX pourrait être justifié dans VeriPB par la règle de dominance, si on l'écrit comme une permutation de littéraux. | le [48,24,12] est unique (QR48), avec Aut = PSL(2,47). Le modèle doit trouver un code pour l'ordre 3 (type 3^16) et l'ordre 23, et aucun pour les ordres 5, 7, 11, ni pour l'ordre 3 avec points fixes. En longueur 24, les tests sur Golay passent déjà (`notes/aut-order-p.md`). | 🔄 Ordre 23 ✅ : k = 0 UNSAT en 10 s, k = 1 FOUND après 50 tours de la boucle paresseuse (1 h 27), et le code trouvé a exactement l'énumérateur de QR48 (17296 mots de poids 12). Les autres cas tournent encore. Les boucles paresseuses ajoutent environ 40 combinaisons par tour et convergent lentement. |
| E8 | la chaîne mzn → fzn → opb | tout | non justifiée | les comptages passent par l'aplatissement pour Chuffed, qui n'est pas celui de baguette ni de GCS. Ils ne testent donc pas l'encodage `.opb`. | ⏳ |

## Ce qu'on retient (2026-11-17)

- **Ce qui marche.** Avec le bon modèle, on certifie l'extrémalité de Leech et la distance des codes
  de Golay, QR48, QR72 et QR80. Pour QR80, il a fallu découper en 2154 cas indépendants, ce qui
  rend la certification parallèle. La seule chose admise est le découpage en deux moitiés, qui tient en une
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

## Ce qu'on retient (2026-11-18)

- **Les symétries du code valent plus que le solveur.** Pour un code QR, PSL(2,p) est 3-homogène. On
  peut donc imposer trois coordonnées dans le support du mot cherché. QR80 passe de 2 × 523 s à 47 s
  avec Chuffed, et QR104, hors de portée la veille, est résolu sans preuve (B4b). Le choix des trois
  coordonnées compte. Celles qui tombent sur les variables de branchement aident beaucoup plus.
- **L'heuristique décide du modèle d'automorphismes.** Essayer 1 d'abord sur les bits générateurs
  résout l'ordre 7, k = 2 en 150 nœuds au lieu de millions, pour Chuffed comme pour baguette (B-heur).
  Les boucles paresseuses de longueur 72 font maintenant des tours de quelques minutes au lieu de 8 h.
- **Sur les codes fixés, baguette perd sur le coût par nœud**, à nombre de nœuds égal. C'est demandé
  à baguette, avec une étude d'heuristiques, l'oubli de clauses par LBD et les redémarrages.
- **Les tests d'équivalence par énumération passent** pour Golay, QR48 et Leech (section E). Ils ont
  aussi trouvé un trou dans la bibliothèque MiniZinc de baguette (`bool_xor` avec une constante).

## Ce qu'on ne fera pas, et pourquoi

| cible | raison |
|---|---|
| un code ternaire [72,36,21] | il n'existe pas, parce que sa série de poids aurait un coefficient négatif |
| une énumération directe en dimension 72 et plus | personne ne la fait. Stehlé et Watkins estiment déjà plusieurs mois pour la norme 4 en dimension 80. |
| les réseaux en dimension 96 | aucune approche connue n'y arrive pour l'instant |
