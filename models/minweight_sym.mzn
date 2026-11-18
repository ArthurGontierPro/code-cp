% =========================================================================================
%  Un mot de faible poids dans un code binaire fixé, écrit de façon SYMÉTRIQUE
% =========================================================================================
%  Même question que minweight.mzn (un mot non nul de poids ≤ Wmax), mais le code est donné
%  par la liste W de ses mots de poids minimal : x est dans le code (auto-dual) si et
%  seulement s'il est orthogonal à chacun d'eux, c'est-à-dire si la somme de x sur chaque mot
%  w est paire, ce qu'on écrit somme = 2·y_w avec un entier y_w par mot.
%  Pourquoi cette écriture : un automorphisme du code envoie l'ensemble W sur lui-même, donc
%  chaque contrainte du modèle sur une autre contrainte du modèle. La règle de dominance de
%  VeriPB peut alors utiliser l'automorphisme comme témoin (notes/dominance/, dom/README.md).
%
%  Les clauses x[FA[t]] ∨ ¬x[FB[t]], placées en DERNIER, imposent les coordonnées 1, 2, 3
%  dans le support (comme minweight_fix.mzn). Elles ne sont pas des axiomes : chacune est
%  dérivée par une ligne dom (scripts/dommerge.py), qui doit retrouver le même numéro de
%  contrainte que dans le .opb du solveur.
%  Instances : scripts/symcode.py écrit dom/sym_pP_wW.dzn (P = 7 Hamming, P = 23 Golay).
% =========================================================================================
int: n;  int: nW;  int: wd;  int: Wmax;
array[1..nW, 1..n] of 0..1: W;
int: nF;  array[1..nF] of 1..n: FA;  array[1..nF] of 1..n: FB;

array[1..n] of var bool: x;
array[1..nW] of var 0..min(wd, Wmax) div 2: y;     % la somme sur w ne dépasse ni |w| ni le poids du mot

constraint forall(w in 1..nW)(sum(i in 1..n where W[w, i] = 1)(bool2int(x[i])) = 2 * y[w]);
constraint sum(i in 1..n)(bool2int(x[i])) >= 1;
constraint sum(i in 1..n)(bool2int(x[i])) <= Wmax;
constraint forall(t in 1..nF)(x[FA[t]] \/ not x[FB[t]]);

solve satisfy;
output ["x = \(x)\n"];
