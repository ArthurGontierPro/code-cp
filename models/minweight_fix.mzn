% =========================================================================================
%  minweight.mzn + des coordonnées imposées dans le support (automorphismes du code)
% =========================================================================================
%  Le groupe d'automorphismes d'un code QR étendu de longueur p+1 contient PSL(2,p)
%  (Gleason–Prange), qui agit sur les p+1 coordonnées. Pour p ≡ 3 mod 4 (c'est le cas de
%  23, 47, 71, 79, 103), PSL(2,p) est 3-homogène : il envoie n'importe quel ensemble de 3
%  coordonnées sur n'importe quel autre. S'il existe un mot non nul de poids ≤ Wmax, son
%  support contient au moins 3 coordonnées (Wmax ≥ 3), et un automorphisme l'envoie donc sur
%  un mot de même poids dont le support contient 3 coordonnées FIXÉES à l'avance. On peut
%  imposer ces 3 coordonnées. C'est une brisure de symétrie ADMISE (non certifiée).
%  Elle se combine avec les deux moitiés, qui valent pour n'importe quel mot :
%    golay24.dzn   : FIXU = {1,2,3}, FIXC = {}       (u = coordonnées 1..k)
%    golay24_T.dzn : FIXU = {},      FIXC = {1,2,3}  (c' = coordonnées 1..k du code d'origine)
%  Test : avec Wmax = d, le nombre de mots trouvés doit être λ3 = A_d·C(d,3)/C(n,3)
%  (les mots de poids d d'un code QR étendu forment un 3-design).
% =========================================================================================
include "minweight.mzn";
set of int: FIXU;
set of int: FIXC;
constraint forall(i in FIXU)(u[i]);
% écrit comme une somme : « c[j] = true » fait produire à MiniZinc 2.10.1 des bool_xor(x, y, true)
% que la bibliothèque de baguette (2c97b16 et main du 2026-11-18) ne redéfinit pas
constraint sum(j in FIXC)(bool2int(c[j])) >= card(FIXC);
