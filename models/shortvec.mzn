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
% =========================================================================================

int: N;  int: k;  int: p;  int: Q;  int: D;
array[1..N] of int: T;
array[1..k, 1..N] of 0..p-1: G;
int: M;                                   % norme maximale cherchée (passer -D "M=2;")

int: W = floor(sqrt(int2float(M * D)));   % |w_i| ≤ W puisque w_i² ≤ w·w ≤ M·D
int: tmax = max([abs(t) | t in T]);
int: Y = (W + tmax) div 2 + 1;           % |y_i| ≤ Y

array[1..k] of var 0..p-1: u;             % le mot de code est u·G mod p
var 0..1: b;                              % b = 1 : on est dans le translaté
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
