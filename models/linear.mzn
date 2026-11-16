% =========================================================================================
%  Code linéaire binaire (n, k, d) quelconque : la formulation de Kochemazov et al., AAAI-26
% =========================================================================================
%  (voir notes/golay-leech-model.md, section "Comparison with ... AAAI-26", et leur
%   external/AAAI-2026-Codes/Encodings/constraint_encoding.py, que ce modèle reproduit)
%
%  On cherche k mots de longueur n (la génératrice G = [I_k | A], A de taille k × (n-k))
%  tels que tout mot non nul du code ait au moins d bits à 1. Contrairement à code.mzn,
%  il n'y a pas d'auto-dualité : seule la distance compte.
%
%  Pour un ensemble S de lignes, poids = |S| + poids(XOR des lignes de A dans S) ; on pose
%  donc  poids(XOR_S A) ≥ d - |S|  pour tous les S non vides avec |S| < d (au-delà c'est
%  automatique). k ≤ 12 dans leur benchmark, donc au plus 4095 ensembles.
%
%  SB (leur brisure de symétrie, reproduite à l'identique) :
%    - première ligne de A fixée : des 0, une case libre, puis d-1 uns à la fin
%      (A[1, 1..m-d] = 0, A[1, m-d+2..m] = 1, avec m = n - k) ;
%    - colonnes de A STRICTEMENT croissantes, lues comme des nombres binaires dont la
%      ligne 1 est le bit de poids fort.
%    L'article ne justifie pas que cette brisure garde une solution ; on la reprend telle
%    quelle pour comparer à leurs chiffres.
%
%  T (≥ 0 pour l'activer, -1 sinon) : au plus T mots de poids exactement d ("error
%    coefficient"), avec leur astuce : une variable l_S par ensemble, la contrainte devient
%    poids + l_S ≥ d - |S| + 1, et somme des l_S ≤ T.
% =========================================================================================

int: n;  int: k;  int: d;
bool: SB;
int: T;                          % -1 = pas de borne sur le nombre de mots de poids d
int: m = n - k;
set of int: R = 1..k;
set of int: C = 1..m;

array[R, C] of var bool: A;

% ensembles de lignes = masques de k bits ; même partage des XOR que golay.mzn
function int: pc(int: s) = sum(b in 0..k-1)((s div pow(2,b)) mod 2);
function int: low(int: s) = min([b | b in 0..k-1 where (s div pow(2,b)) mod 2 = 1]);
set of int: S = {s | s in 1..pow(2,k)-1 where pc(s) < d};
array[1..pow(2,k)-1, C] of var bool: X;
constraint forall(s in 1..pow(2,k)-1 diff S, j in C)(X[s,j] = false);
constraint forall(s in S, j in C)(
  if pc(s) = 1 then X[s,j] = A[low(s)+1, j]
  else X[s,j] = (X[s - pow(2,low(s)), j] xor A[low(s)+1, j]) endif);

% distance, avec ou sans la variable l_S
array[1..pow(2,k)-1] of var bool: l;
constraint forall(s in S)(
  if T < 0 then sum(j in C)(bool2int(X[s,j])) >= d - pc(s)
  else sum(j in C)(bool2int(X[s,j])) + bool2int(l[s]) >= d - pc(s) + 1 endif);
constraint forall(s in 1..pow(2,k)-1 where T < 0 \/ not (s in S))(l[s] = false);
constraint if T >= 0 then sum(s in S)(bool2int(l[s])) <= T else true endif;

% leur brisure de symétrie
include "lex_less.mzn";
constraint if SB then
  forall(j in 1..m-d)(A[1,j] = false) /\ forall(j in m-d+2..m)(A[1,j] = true) /\
  forall(j in 1..m-1)(lex_less(col(A,j), col(A,j+1)))
else true endif;

solve satisfy;
output [ "A = array2d(1..\(k*m), ", show(array1d(A)), ")\n" ];
