% =========================================================================================
%  Un mot de faible poids dans un code binaire FIXÉ (Golay, QR48, QR80)
% =========================================================================================
%  Le code est donné sous forme systématique G = [I_k | A]. Un mot du code est fixé par le
%  choix des lignes qu'on additionne (u ∈ {0,1}^k) ; son poids vaut
%      |u|  +  poids(XOR des lignes de A choisies).
%  Question : existe-t-il un mot non nul de poids ≤ Wmax ?
%    - Wmax = d - 4 (le poids est multiple de 4 dans un code doublement pair) : on attend
%      UNSAT, ce qui certifie la distance minimale d (Golay 8, QR48 12, QR80 16) ;
%    - Wmax = d : on attend SAT, ce qui teste le modèle.
%  Pas de brisure de symétrie : la preuve d'UNSAT n'admet aucune hypothèse.
% =========================================================================================

int: k;  int: m;
array[1..k, 1..m] of 0..1: A;
int: Wmax;                                % passer -D "Wmax=4;"
int: HALF;                                % au plus HALF lignes choisies (HALF = k : aucune restriction)
%  Argument des deux moitiés (celui de scripts/mindist.c). Si A·Aᵀ = I (code auto-dual), le
%  même code s'écrit aussi [Aᵀ | I] : un mot (u, c) avec c = u·A vérifie u = c·Aᵀ. Un mot de
%  poids ≤ Wmax a au plus Wmax/2 uns à gauche OU à droite. On lance donc deux instances,
%  « golay24.dzn » et « golay24_T.dzn » (A transposée) avec HALF = Wmax div 2 : deux UNSAT
%  prouvent qu'aucun mot de poids ≤ Wmax n'existe. Chaque cas est bien plus petit.

array[1..k] of var bool: u;
array[1..m] of var bool: c;               % partie redondante du mot

% c_j = XOR des u_i tels que A[i,j] = 1, écrit comme une chaîne de xor binaires
constraint forall(j in 1..m)(
  let { array[int] of int: R = [i | i in 1..k where A[i,j] = 1];
        int: r = length(R);
        array[1..r] of var bool: acc } in
  acc[1] = u[R[1]] /\
  forall(t in 2..r)(acc[t] = (acc[t-1] xor u[R[t]])) /\
  c[j] = acc[r]);

constraint sum(i in 1..k)(bool2int(u[i])) >= 1;
constraint sum(i in 1..k)(bool2int(u[i])) <= HALF;
constraint sum(i in 1..k)(bool2int(u[i])) + sum(j in 1..m)(bool2int(c[j])) <= Wmax;

solve satisfy;
output ["weight = \(sum(i in 1..k)(bool2int(fix(u[i]))) + sum(j in 1..m)(bool2int(fix(c[j]))))\nu = \(u)\n"];
