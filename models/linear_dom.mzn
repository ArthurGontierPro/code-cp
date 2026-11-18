% =========================================================================================
%  Code linéaire binaire (n, k, d) quelconque, avec une brisure de symétrie JUSTIFIABLE
% =========================================================================================
%  Le modèle de linear.mzn (Kochemazov et al., AAAI-26), sans le nombre de mots de poids d,
%  avec pour seule brisure de symétrie le tri des colonnes de A, écrit pour que la règle de
%  dominance de VeriPB puisse le dériver (dom/README.md, deuxième partie).
%
%  Permuter les colonnes de A permute les coordonnées du code, donc ne change ni sa dimension
%  ni sa distance. Toutes les contraintes du modèle sont écrites colonne par colonne de la même
%  façon, donc l'échange des colonnes j et j+1 envoie chaque contrainte sur une contrainte et
%  chaque variable sur une variable. C'est ce qui permet de l'utiliser comme témoin.
%
%  LEX = 0 : pas de brisure.
%  LEX = 1 : colonnes croissantes au sens large, chaque colonne lue comme un nombre binaire dont
%            la ligne 1 est le bit de poids fort. Une seule inégalité par paire de colonnes
%            voisines, sans variable auxiliaire, placée en dernier dans le modèle.
%  LEX = 2 : colonnes STRICTEMENT croissantes, comme dans l'article. Ce n'est pas une conséquence
%            de la symétrie, parce qu'un code peut avoir deux colonnes égales (le code à
%            répétition [n, 1, n] en est fait). On le garde pour voir ce que VeriPB en dit.
%  La première ligne fixée de leur brisure n'est pas reprise. Elle demande de changer de base
%  du code, ce qui n'est pas une permutation de variables.
% =========================================================================================
int: n;  int: k;  int: d;  int: LEX;
int: m = n - k;
set of int: R = 1..k;
set of int: C = 1..m;

array[R, C] of var bool: A :: add_to_output;

function int: pc(int: s) = sum(b in 0..k-1)((s div pow(2,b)) mod 2);
function int: low(int: s) = min([b | b in 0..k-1 where (s div pow(2,b)) mod 2 = 1]);
set of int: S = {s | s in 1..pow(2,k)-1 where pc(s) < d};
% X[s, j] = XOR des lignes de A dans l'ensemble s, colonne j (utile seulement pour |s| < d, les
% autres sont fixés à faux). Le tableau est complet pour que le .fzn garde le nom de chaque X[s, j].
array[1..pow(2,k)-1, C] of var bool: X :: add_to_output;
constraint forall(s in 1..pow(2,k)-1 diff S, j in C)(X[s,j] = false);
constraint forall(s in S, j in C)(
  if pc(s) = 1 then X[s,j] = A[low(s)+1, j]
  else X[s,j] = (X[s - pow(2,low(s)), j] xor A[low(s)+1, j]) endif);
constraint forall(s in S)(sum(j in C)(bool2int(X[s,j])) >= d - pc(s));

constraint forall(j in 1..m-1)(
  let { var int: gap = sum(i in R)(pow(2, k-i) * (bool2int(A[i,j+1]) - bool2int(A[i,j]))) } in
  if LEX = 1 then gap >= 0 elseif LEX = 2 then gap >= 1 else true endif);

solve satisfy;
% X est affiché aussi, seulement pour que le .fzn garde le nom de chaque X[s, j] (scripts/domlex.py)
output [ "A = array2d(1..\(k), 1..\(m), ", show(array1d(A)), ")\n", "X = \(X)\n" ];
