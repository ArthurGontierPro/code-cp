% =========================================================================================
%  Un vecteur court dans un réseau construit à partir d'un code (Leech, P48p, P48q)
% =========================================================================================
%  Question posée au solveur : le réseau contient-il un vecteur non nul de norme ≤ M ?
%    - avec M = minimum - 2 (Leech : M = 2 ; P48 : M = 4) on attend UNSAT, et une preuve
%      d'UNSAT est un certificat que le réseau est extrémal (pas de vecteur plus court que
%      le minimum annoncé) ;
%    - avec M = minimum on attend SAT (un vecteur minimal), ce qui teste le modèle.
%
%  Le réseau (voir scripts/gen_instances.py, qui vérifie la construction) :
%    w = 2·y + b·T,   y ≡ un mot du code (mod p),   somme(y) ≡ 0 (mod Q),   b ∈ {0,1}
%    norme(w) = (w·w) / D
%  b = 0 : la « construction B » (Leech, p = 2) ou « B3 » (P48, p = 3) appliquée au code ;
%  b = 1 : le translaté qui double la densité (T = (-3,1^23) pour Leech, (∓5, ±1^47) pour P48).
%  Le mot du code est u·G mod p, u ∈ F_p^k libre : y_i = Σ_j u_j G[j,i] + p·z_i, z_i entier.
%
%  Aucune brisure de symétrie : la preuve d'UNSAT est donc entièrement certifiable, sans
%  hypothèse admise. (w et -w sont tous deux cherchés ; c'est un facteur 2 au plus.)
%  Les seuls axiomes sont la construction elle-même et les bornes W, Y, z ci-dessous. Ils sont
%  testés par énumération (RESULTS.md, section E, ligne E5) : à la norme 4, Leech donne
%  exactement 196560 vecteurs, 98256 avec b = 0 et 98304 avec b = 1, ce qui correspond aux
%  formes connues (±4,±4,0^22), (±2^8,0^16) et (∓3,±1^23). Pour le cours : RESULTS.md §5.
% =========================================================================================

int: N;  int: k;  int: p;  int: Q;  int: D;
array[1..N] of int: T;
array[1..k, 1..N] of 0..p-1: G;
int: M;                                   % norme maximale cherchée (passer -D "M=2;")
int: BFIX;                                % -1 : b libre ; 0 ou 1 : b fixé (découpage en cas)
int: HALF;                                % au plus HALF coordonnées u_j non nulles (HALF = k : libre)
%  Découpage en cas pour P48 (fichiers p48X_L.dzn et p48X_R.dzn, voir gen_instances.py) :
%    b = 0 : w = 2y, w·w ≤ 48 donne y·y ≤ 12, donc le mot de code y mod 3 a au plus 12
%            coordonnées non nulles, donc au plus 6 sur une des deux moitiés. G est sous forme
%            systématique [I|A] (fichier _L) ou [I|-Aᵀ] (fichier _R, moitiés échangées), et
%            HALF = 6 borne la moitié choisie. Deux UNSAT couvrent tout le cas b = 0.
%    b = 1 : toutes les w_i sont impaires, donc w·w ≤ 48 force w_i = ±1 ; un seul run, HALF = k.

% Bornes des domaines. Elles sont écrites dans le .opb comme des axiomes : une borne trop
% serrée enlèverait des solutions sans que VeriPB puisse le voir. D'où la justification :
int: W = floor(sqrt(int2float(M * D)));   % |w_i| ≤ W puisque w_i² ≤ w·w ≤ M·D
int: tmax = max([abs(t) | t in T]);
int: Y = (W + tmax) div 2 + 1;           % |y_i| ≤ Y

array[1..k] of var 0..p-1: u;             % le mot de code est u·G mod p
var 0..1: b;                              % b = 1 : on est dans le translaté
constraint if BFIX >= 0 then b = BFIX else true endif;
constraint sum(j in 1..k)(bool2int(u[j] > 0)) <= HALF;
array[1..N] of var -Y..Y: y;
array[1..N] of var -W..W: w;
array[1..N] of var 0..W*W: sq;

% y_i ≡ (u·G)_i  (mod p)
constraint forall(i in 1..N)(
  let { int: S = sum(j in 1..k)((p-1) * G[j,i]);
        var (-Y - S) div p - 1 .. Y div p + 1: z } in
  y[i] = sum(j in 1..k where G[j,i] > 0)(G[j,i] * u[j]) + p * z);

% somme(y) ≡ 0 (mod Q)
constraint let { var -(N*Y) div Q - 1 .. (N*Y) div Q + 1: s } in sum(y) = Q * s;

% w, sa norme, et la question
constraint forall(i in 1..N)(w[i] = 2 * y[i] + b * T[i]);
constraint forall(i in 1..N)(sq[i] = w[i] * w[i]);
constraint sum(sq) <= M * D;
constraint sum(sq) >= 1;                 % w ≠ 0

solve satisfy;
output ["norm = \(sum(fix(sq)) div D)  b = \(b)\nw = \(w)\n"];
