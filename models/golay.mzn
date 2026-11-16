% =========================================================================================
%  Le code de Golay étendu [24,12,8] : version autonome, n = 12 en dur
% =========================================================================================
%
%  C'est la première version du modèle, gardée parce qu'elle est autonome (pas de fichier
%  de données) et plus courte à lire. La version générale, qui traite aussi la longueur 48
%  et contient l'explication complète (codes, poids, forme systématique, options), est
%  code.mzn. Ce fichier-ci en est le cas particulier n = 12, d = 8.
%
%  EN DEUX MOTS
%  On cherche 12 mots de 24 bits (les lignes de la matrice génératrice [I_12 | A]) tels
%  que les 4096 mots obtenus en les combinant par XOR forment un code :
%    (a) auto-dual       : deux lignes ont toujours un nombre pair de 1 en commun ;
%    (b) doublement pair : chaque ligne a un poids multiple de 4 ;
%    (c) de distance 8   : tout mot non nul a au moins 8 bits à 1.
%  Un théorème dit qu'un seul code vérifie tout cela (à permutation près) : le Golay.
%  Les inconnues sont les 144 bits de A. La partie I_12 est fixée.
%
%  LA FORMULE CLÉ
%  Si on combine un ensemble S de lignes, la partie identité du mot obtenu contient
%  exactement |S| bits à 1 (un par ligne choisie). Donc :
%        poids du mot  =  |S|  +  poids(XOR des lignes de A dans S)
%  et la condition (c) s'écrit, pour chacun des 4095 ensembles S non vides :
%        |S| + poids(XOR_S A)  ≥  8.
%  Pour |S| ≥ 8 c'est automatique : il reste les ensembles de 1 à 7 lignes.
%
%  OPTIONS (toutes obligatoires) :   minizinc -D "K=4;LEX=false;COLS=false;" golay.mzn
%    K    : on ne pose (c) que pour les ensembles d'au plus K lignes (K ≥ 7 = complet).
%           Avec K petit on résout une relaxation, qui peut accepter de faux codes.
%    LEX  : brisure de symétrie double-lex (lignes et colonnes de A triées).
%    COLS : les mêmes contraintes sur les colonnes de A. Correct car [A^T | I] engendre
%           le même code (code auto-dual) ; redondant, pour aider la propagation.
% =========================================================================================

int: K;
bool: LEX;
bool: COLS;
int: n = 12;
set of int: R = 1..n;

% ---- LES INCONNUES : les 144 bits de A ----
array[R, R] of var bool: A;

% ---- Les ensembles de lignes, codés comme des entiers de 12 bits (masques) ----
% Le masque s = 0b000000000101 désigne l'ensemble {ligne 1, ligne 3}.
% pc(s) = nombre de lignes de l'ensemble, low(s) = indice (à partir de 0) de sa plus
% petite ligne. S = les ensembles sur lesquels on pose la condition (c).
function int: pc(int: s) = sum(b in 0..n-1)((s div pow(2,b)) mod 2);
function int: low(int: s) = min([b | b in 0..n-1 where (s div pow(2,b)) mod 2 = 1]);
set of int: S = {s | s in 1..pow(2,n)-1 where pc(s) <= min(K, 7)};

% ---- Les propriétés (a), (b), (c) pour les lignes d'une matrice M ----
% (prédicat pour pouvoir l'appliquer à A, et avec COLS à sa transposée)
predicate golay_rows(array[R, R] of var bool: M) =
  let { array[R] of var 0..2: u;                  % quotient par 4 du poids
        array[R, R] of var 0..6: t;               % moitié du nombre de 1 communs
        array[1..pow(2,n)-1, R] of var bool: X }  % X[s,k] = bit k du XOR des lignes de s
  in
  % (b) poids de la ligne = 1 (partie I) + |M_i|, multiple de 4  <=>  |M_i| = 3 + 4u
  forall(i in R)(sum(k in R)(bool2int(M[i,k])) = 3 + 4*u[i]) /\
  % (a) |M_i ET M_j| pair, écrit "= 2t" faute d'opérateur modulo linéaire.
  %     (les parties identité de deux lignes différentes n'ont aucun 1 en commun)
  forall(i, j in R where i < j)(sum(k in R)(bool2int(M[i,k] /\ M[j,k])) = 2*t[i,j]) /\
  % les ensembles hors de S ne servent pas : leurs X sont fixés à faux (et disparaissent)
  forall(s in 1..pow(2,n)-1 diff S, k in R)(X[s,k] = false) /\
  % XOR d'un ensemble = XOR de l'ensemble sans sa plus petite ligne, XOR cette ligne.
  % Chaque ensemble coûte ainsi un seul xor par bit, en réutilisant un plus petit.
  forall(s in S, k in R)(
    if pc(s) = 1 then X[s,k] = M[low(s)+1, k]
    else X[s,k] = (X[s - pow(2,low(s)), k] xor M[low(s)+1, k]) endif) /\
  % (c) |S| + poids(XOR) ≥ 8
  forall(s in S)(sum(k in R)(bool2int(X[s,k])) >= 8 - pc(s));

constraint golay_rows(A);
constraint if COLS then golay_rows(array2d(R, R, [A[j,i] | i, j in R])) else true endif;

% ---- LEX : lignes de A triées, colonnes de A triées ----
% Permuter les lignes (avec les colonnes de I correspondantes) ou les colonnes de A donne
% un code équivalent : on n'en garde qu'un représentant, trié.
include "lex_lesseq.mzn";
constraint if LEX then
  forall(i in 1..n-1)(lex_lesseq(row(A,i), row(A,i+1))) /\
  forall(j in 1..n-1)(lex_lesseq(col(A,j), col(A,j+1)))
else true endif;

solve satisfy;
output [ "A = array2d(1..144, ", show(A), ")\n" ];

% =========================================================================================
%  RÉCAPITULATIF DES MEILLEURS RÉSULTATS (2026-11-16, nœud fataepyc-07)
% =========================================================================================
%  Détails et tableaux complets : ../golay-leech-model.md, section Results.
%  "Golay" = le code trouvé a été vérifié hors solveur (check.py : 759 mots de poids 8,
%  2576 de poids 12, 759 de poids 16).
%
%  Trouver le Golay, avec ce modèle :
%    Chuffed, K=2, LEX, COLS ........ 235 nœuds, 0,9 s, Golay
%    Chuffed, K=4 ..................... 589 nœuds, 1,4 s, Golay
%    Chuffed, K=2..7 .................. 0,5 à 5,5 s, toujours Golay
%    baguette + preuve, K=3 ........... 1 959 nœuds, 5,7 s, preuve 27 Mo VÉRIFIÉE (1,4 s)
%    baguette + preuve, K=7 (complet) . 1 959 nœuds, 46 s, preuve 143 Mo VÉRIFIÉE (8,9 s)
%    baguette, K=1 et K=2 ............. échec en 30 min (recherche, pas modèle)
%
%  Ce qu'on a appris :
%    - K=1 ne suffit pas (Chuffed trouve un code avec des mots de poids 4) ;
%    - K=2 suffit : voir code.mzn, option WEIGHT=4, prouvé UNSAT par baguette + VeriPB ;
%    - la contrainte "chaque ligne a poids ≥ 8" (ensembles d'une ligne) est décisive :
%      sans elle, ni Chuffed ni baguette ne trouvaient rien en 10 à 30 min ;
%    - LEX ralentit la recherche d'UNE solution (×4 en nœuds) mais est indispensable
%      pour prouver qu'il n'y en a pas (questions UNSAT de code.mzn).
% =========================================================================================
