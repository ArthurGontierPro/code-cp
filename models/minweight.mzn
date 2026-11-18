% =========================================================================================
%  Un mot de faible poids dans un code binaire FIXÉ (Golay, QR48, QR80)
% =========================================================================================
%  Le code est donné sous forme systématique G = [I_k | A]. Un mot du code est fixé par le
%  choix des lignes qu'on additionne (u ∈ {0,1}^k) ; son poids vaut
%      |u|  +  poids(XOR des lignes de A choisies).
%  Question : existe-t-il un mot non nul de poids ≤ Wmax ?
%    - Wmax = d - 4 (le poids est multiple de 4 dans un code doublement pair) : on attend
%      UNSAT, ce qui certifie la distance minimale d (Golay 8, QR48 et QR72 12, QR80 16,
%      QR104 20) ;
%    - Wmax = d : on attend SAT, ce qui teste le modèle.
%  Pas de brisure de symétrie : la preuve d'UNSAT n'admet aucune hypothèse.
%
%  Pour le cours : RESULTS.md §4 (le code de Hamming [8,4,4] traité à la main avec ce modèle),
%  §6 (ce que veut dire UNSAT) et §7 (les deux moitiés). Les découpages sont testés par
%  énumération (RESULTS.md, section E, lignes E3 et E4) : sur Golay et QR48, les deux moitiés
%  redonnent exactement les 759 et 17296 mots de poids minimal, et chaque cas FIRST / SECOND /
%  THIRD est l'union disjointe de ses sous-cas. Variante avec des coordonnées imposées par les
%  symétries du code : minweight_fix.mzn.
% =========================================================================================

int: k;  int: m;
array[1..k, 1..m] of 0..1: A;
int: Wmax;                                % passer -D "Wmax=4;"
int: HALF;                                % au plus HALF lignes choisies (HALF = k : aucune restriction)
int: FIRST;                               % 0 : rien ; i > 0 : la première ligne choisie est la ligne i
int: SECOND;                              % 0 : rien ; -1 : la ligne FIRST est seule ; j > FIRST : la 2e ligne choisie est j
int: THIRD;                               % idem pour la 3e ligne choisie (-1 : pas de 3e ligne)
%  FIRST découpe encore chaque moitié en k cas disjoints (u_1 = … = u_{i-1} = 0, u_i = 1). Les k
%  cas recouvrent tous les u non nuls, donc k UNSAT valent un UNSAT ; on les lance en parallèle.
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
constraint if FIRST > 0 then u[FIRST] /\ forall(i in 1..FIRST-1)(not u[i]) else true endif;
constraint if SECOND = -1 then forall(i in FIRST+1..k)(not u[i])
           elseif SECOND > 0 then u[SECOND] /\ forall(i in FIRST+1..SECOND-1)(not u[i]) else true endif;
constraint if THIRD = -1 then forall(i in SECOND+1..k)(not u[i])
           elseif THIRD > 0 then u[THIRD] /\ forall(i in SECOND+1..THIRD-1)(not u[i]) else true endif;
constraint sum(i in 1..k)(bool2int(u[i])) + sum(j in 1..m)(bool2int(c[j])) <= Wmax;

solve satisfy;
output ["weight = \(sum(i in 1..k)(bool2int(fix(u[i]))) + sum(j in 1..m)(bool2int(fix(c[j]))))\nu = \(u)\n"];
