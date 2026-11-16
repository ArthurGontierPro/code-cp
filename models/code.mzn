% =========================================================================================
%  À la recherche du code de Golay (et de son grand frère de longueur 48)
% =========================================================================================
%
%  1. CE QU'ON CHERCHE
%  -------------------
%  Un CODE BINAIRE est un ensemble de mots de bits, tous de la même longueur, qu'on
%  utilise pour transmettre des messages : si deux mots du code diffèrent toujours en au
%  moins d positions, on peut corriger jusqu'à (d-1)/2 bits abîmés en route, en
%  remplaçant le mot reçu par le mot du code le plus proche.
%
%  Un code LINÉAIRE est stable par XOR : le XOR de deux mots du code est encore un mot du
%  code. Il est alors entièrement décrit par une base de n mots (la MATRICE GÉNÉRATRICE,
%  n lignes) : les 2^n mots du code sont tous les XOR possibles de sous-ensembles de lignes.
%
%  Le POIDS d'un mot est son nombre de 1. Pour un code linéaire, la distance entre deux
%  mots est le poids de leur XOR, donc :
%        distance minimale d du code  =  plus petit poids d'un mot non nul.
%
%  Ici on cherche des mots de longueur 2n, avec n lignes génératrices :
%     n = 12, d = 8  : le CODE DE GOLAY ÉTENDU [24,12,8], 4096 mots, corrige 3 erreurs.
%                      Utilisé par Voyager, lié au réseau de Leech et au groupe Monstre.
%     n = 24, d = 12 : le code QR étendu q48 [48,24,12], 16 millions de mots.
%  Dans les deux cas on sait (théorème) qu'il existe UN SEUL tel code, à permutation des
%  positions près. Le chercher par contraintes est donc un test de "rigidité" : le
%  solveur doit retrouver un objet unique dans un espace immense (2^144, resp. 2^576).
%
%  2. LA FORME DE LA MATRICE
%  -------------------------
%  Toute matrice génératrice peut se mettre (en permutant les positions) sous forme
%  SYSTÉMATIQUE   G = [ I_n | A ]   où I_n est l'identité n×n et A une matrice n×n de
%  bits. Les inconnues du problème sont les n² bits de A, et rien d'autre.
%
%  Exemple jouet avec n = 3 :      ligne 1 :  1 0 0 | 0 1 1
%                                  ligne 2 :  0 1 0 | 1 0 1
%                                  ligne 3 :  0 0 1 | 1 1 0
%  Le mot "ligne 1 XOR ligne 3" vaut 1 0 1 | 1 0 1 : la partie gauche dit QUELLES lignes
%  on a combinées, la partie droite est le XOR des lignes correspondantes de A.
%  D'où la formule clé utilisée partout plus bas, pour un ensemble S de lignes :
%        poids(XOR des lignes de S)  =  |S|  +  poids(XOR des lignes de A dans S)
%
%  3. LES PROPRIÉTÉS DEMANDÉES
%  ---------------------------
%  (a) AUTO-DUAL : deux mots quelconques du code ont un nombre PAIR de 1 en commun
%      (produit scalaire nul modulo 2). Il suffit de le demander pour les lignes.
%      Pour deux lignes i ≠ j, les parties identité n'ont aucun 1 en commun, donc
%      la condition porte seulement sur A :  |A_i ET A_j| est pair.
%  (b) DOUBLEMENT PAIR : chaque mot a un poids multiple de 4. Avec (a), il suffit de le
%      demander pour les lignes :  1 + |A_i| ≡ 0 (mod 4).
%      Conséquence utile : les poids possibles sont 0, 4, 8, 12... donc "distance ≥ 8"
%      revient à "aucun mot de poids 4".
%  (c) DISTANCE MINIMALE d : pour TOUT ensemble non vide S de lignes,
%            |S| + poids(XOR des lignes de A dans S)  ≥  d.
%      Il y a 2^n - 1 ensembles S (4095 pour n = 12, 16 millions pour n = 24) : c'est la
%      partie chère. Deux remarques réduisent le travail :
%        - si |S| ≥ d, la contrainte est automatique (la partie identité suffit) ;
%        - on peut ne poser la contrainte que pour |S| ≤ K, et voir si ça suffit.
%      K est donc un bouton : K = 1 contraint chaque ligne seule, K = 2 aussi chaque
%      paire, etc. Pour n = 12, K = 7 est la condition complète. Avec K plus petit on
%      résout une RELAXATION, qui peut accepter de faux codes. Résultat mesuré : pour
%      n = 12, K = 1 ne suffit pas mais K = 2 suffit (prouvé UNSAT avec WEIGHT = 4).
%
%  4. LES OPTIONS (passées en -D "K=2;d=8;LEX=false;...")
%  -------------------------------------------------------
%     K      : taille maximale des combinaisons de lignes contraintes (voir 3c).
%     COLS   : pose aussi tout ça sur les COLONNES de A. C'est correct car, pour un code
%              auto-dual, [A^T | I] engendre le même code. Redondant, mais ça aide
%              parfois la propagation.
%     LEX    : brise les symétries. Permuter les lignes de A (avec les colonnes de I
%              correspondantes) ou permuter les colonnes de A donne un code équivalent ;
%              on impose donc que lignes et colonnes de A soient triées (double-lex).
%     BDC    : restreint A à la forme "bordée doublement circulante", où A est un bloc
%              circulant (chaque ligne est la précédente décalée d'un cran) entouré d'une
%              bordure. Golay et q48 admettent cette forme ; il ne reste qu'environ n
%              bits libres au lieu de n². C'est une RESTRICTION : utile pour trouver vite,
%              inutilisable pour prouver une unicité.
%     WEIGHT : 0 normalement. Si w > 0, on demande en plus "il existe un mot de poids w".
%              Sert à poser la question "la relaxation K interdit-elle déjà le poids 4 ?"
%              : UNSAT veut dire oui, SAT donne un contre-exemple.
%     nE, E  : combinaisons de lignes ajoutées une par une par cegar.py (distance
%              "paresseuse" : on résout, on regarde quels mots sont trop légers, on les
%              interdit, on recommence). Mettre "nE=0;E=[];" sinon.
%
%  Les données nS, sp, sr, sz viennent de subsets.py (liste des combinaisons, voir plus bas).
% =========================================================================================

int: n;          % nombre de lignes ; les mots ont 2n bits
int: d;          % distance minimale voulue
int: K;          % taille max des combinaisons contraintes
bool: LEX;  bool: COLS;  bool: BDC;  int: WEIGHT;
int: nE;  array[1..nE] of set of int: E;

% Liste des combinaisons de lignes (produite par subsets.py), triées par taille.
% Chaque combinaison s est construite à partir d'une plus petite : s = sp[s] + la ligne
% sr[s]. Ainsi le XOR de s se calcule avec UN seul xor à partir de celui de son parent,
% et les combinaisons partagent leurs calculs. sz[s] est le nombre de lignes de s.
int: nS;  array[1..nS] of int: sp;  array[1..nS] of int: sr;  array[1..nS] of int: sz;

set of int: R = 1..n;

% ---- LES INCONNUES : la matrice A (la partie droite de la génératrice) ----
array[R, R] of var bool: A;

% ---- Les propriétés (a), (b), (c) sur les lignes d'une matrice M ----
% Écrites comme un prédicat pour pouvoir les appliquer à A et, avec COLS, à sa transposée.
% X[s, k] est le bit k du XOR des lignes de M dans la combinaison s.
predicate code_rows(array[R, R] of var bool: M, array[int, R] of var bool: X) =
  let { array[R] of var 0..(n-3) div 4: u;      % quotient de la division par 4
        array[R, R] of var 0..n div 2: t } in   % moitié du nombre de 1 communs
  % (b) doublement pair : |M_i| = 3 + 4u, i.e. 1 + |M_i| multiple de 4
  forall(i in R)(sum(k in R)(bool2int(M[i,k])) = 3 + 4*u[i]) /\
  % (a) auto-dual : |M_i ET M_j| = 2t, i.e. pair. Pas d'opérateur "modulo" ici :
  %     on introduit le quotient t comme variable, c'est la façon linéaire de dire "pair".
  forall(i, j in R where i < j)(sum(k in R)(bool2int(M[i,k] /\ M[j,k])) = 2*t[i,j]) /\
  % définition des XOR de combinaisons, du plus petit au plus grand
  forall(s in 1..nS, k in R)(
    if sz[s] = 1 then X[s,k] = M[sr[s], k]
    else X[s,k] = (X[sp[s], k] xor M[sr[s], k]) endif) /\
  % (c) distance : |S| + poids(XOR) ≥ d, pour les combinaisons de taille ≤ K
  forall(s in 1..nS where sz[s] <= K /\ sz[s] < d)(sum(k in R)(bool2int(X[s,k])) >= d - sz[s]);

array[1..nS, R] of var bool: Xw;   % XOR des combinaisons de LIGNES de A
array[1..nS, R] of var bool: Xc;   % idem pour les COLONNES (utilisé seulement si COLS)
constraint code_rows(A, Xw);
constraint if COLS then code_rows(array2d(R, R, [A[j,i] | i, j in R]), Xc)
  else forall(s in 1..nS, k in R)(Xc[s,k] = false) endif;

% ---- LEX : lignes croissantes et colonnes croissantes (ordre lexicographique) ----
include "lex_lesseq.mzn";
constraint if LEX then
  forall(i in 1..n-1)(lex_lesseq(row(A,i), row(A,i+1))) /\
  forall(j in 1..n-1)(lex_lesseq(col(A,j), col(A,j+1)))
else true endif;

% ---- BDC : forme bordée doublement circulante ----
%      A = [ a | b b ... b ]          première ligne : un bit a puis n-1 fois le même b
%          [ c |             ]
%          [ c |  bloc       ]        première colonne : n-1 fois le même c
%          [ ...| circulant  ]        bloc (n-1)×(n-1) : la ligne i est la ligne 2
%          [ c |             ]        décalée de i-2 crans vers la droite
constraint if BDC then
  forall(j in 3..n)(A[1,j] = A[1,2]) /\ forall(i in 3..n)(A[i,1] = A[2,1]) /\
  forall(i in 3..n, j in 2..n)(A[i,j] = A[2, 2 + (j - i + n - 1) mod (n - 1)])
else true endif;

% ---- Combinaisons ajoutées paresseusement par cegar.py : même contrainte (c) ----
constraint forall(e in 1..nE)(
  let { array[R] of var bool: z = [xorall_val([A[i,k] | i in E[e]]) | k in R] } in
  sum(k in R)(bool2int(z[k])) >= d - card(E[e]));
function var bool: xorall_val(array[int] of var bool: v) =
  if length(v) = 1 then v[1] else xorall_val(v[1..length(v)-1]) xor v[length(v)] endif;

% ---- WEIGHT : "il existe une combinaison de m lignes dont le mot a le poids WEIGHT" ----
% Le mot a pour poids m + poids(X_s), d'où la condition. Un mot de poids w combine au plus
% w lignes, donc les données doivent lister les combinaisons jusqu'à la taille WEIGHT.
% Le témoin réutilise les X du modèle : c'est ce qui permet au solveur de voir le conflit
% avec (c). Une première version avec un vecteur témoin séparé n'aboutissait jamais.
constraint if WEIGHT > 0 then
  exists(s in 1..nS where sz[s] <= WEIGHT)(sum(k in R)(bool2int(Xw[s,k])) = WEIGHT - sz[s])
else true endif;

solve satisfy;
output [ "A = array2d(1..\(n*n), ", show(array1d(A)), ")\n" ];

% =========================================================================================
%  RÉCAPITULATIF DES MEILLEURS RÉSULTATS (2026-11-16, nœud fataepyc-07)
% =========================================================================================
%  Détails : ../golay-leech-model.md. Codes trouvés vérifiés hors solveur par check.py
%  (distribution complète des poids : Golay 759/2576/759, q48 17296 mots de poids 12).
%
%  GOLAY (n=12, d=8)
%    Question "K=2 suffit-il ?" (WEIGHT=4, LEX, COLS) :
%      Chuffed ............ UNSAT, 1 133 nœuds, 1,7 s
%      baguette + preuve .. UNSAT, 2 119 nœuds, 21 s, preuve 83 Mo VÉRIFIÉE par VeriPB
%                           (K=3 : 13 s, K=4 : 19 s, vérifiées aussi)
%      => contraindre les lignes seules et les paires de lignes impose la distance 8.
%      Réserve : le double-lex est une contrainte du modèle, sa validité (brisure de
%      symétrie correcte) est admise, pas certifiée dans la preuve.
%    K=1 avec WEIGHT=4 : SAT (contre-exemple à 6 mots de poids 4) => K=1 ne suffit pas.
%    Forme BDC : Chuffed 23 à 147 nœuds (< 2,5 s) ; baguette + preuve 267 nœuds, 6 s.
%    Distance paresseuse (cegar.py) depuis K=1 : 6 tours, 36 combinaisons, 50 s.
%
%  q48 (n=24, d=12)
%    Sans structure : RIEN, quel que soit K, LEX, COLS, la recherche libre de Chuffed
%      ou la distance paresseuse (20 à 30 min chaque).
%    Avec BDC : Chuffed trouve q48 à K=3 en 168 nœuds, 7,8 s (K=4 : 124 s).
%      baguette sur la même instance : plafond de 8 Go atteint après ~20 min et ~8 Go de
%      preuve écrits. C'est le benchmark le plus parlant pour le coût de baguette.
%    Distance paresseuse + BDC : q48 dès le premier tour, 3 s.
% =========================================================================================
