% =========================================================================================
%  Un code [n, n/2, d] auto-dual doublement pair qui admet un automorphisme σ d'ordre p
% =========================================================================================
%
%  1. LA QUESTION
%  --------------
%  Le code binaire auto-dual doublement pair [72,36,16] est un problème ouvert depuis 1973.
%  On sait seulement que son groupe d'automorphismes serait minuscule : l'ordre 7 est exclu
%  (Feulner–Nebe, arXiv 1110.6012, Théorème 4.2), l'ordre 5 ne l'est PAS. Ce modèle pose la
%  question « existe-t-il un tel code invariant par une permutation σ d'ordre premier p
%  donnée ? ». Avec p = 7 on doit retrouver UNSAT (le résultat de Feulner–Nebe) ; avec
%  p = 5 c'est la recherche ouverte. Voir ../notes/aut-order-p.md pour les instances.
%
%  σ est fixée à l'avance : c cycles de longueur p sur les positions 1..p*c (le cycle l
%  occupe les positions (l-1)p+1 .. lp et σ décale d'un cran dans chaque cycle), puis f
%  points fixes. Longueur n = p*c + f. Ce n'est pas une hypothèse : toute permutation
%  d'ordre p a cette forme à renumérotation près, et le TYPE (c, f) est donné par la
%  littérature (Conway–Pless 1982 : à 72, p = 7 donne c = 10, f = 2 ; p = 5 donne c = 14,
%  f = 2).
%
%  2. LE THÉORÈME DE STRUCTURE (Huffman ; Feulner–Nebe §II)
%  ---------------------------------------------------------
%  Tout code C invariant par σ se coupe en deux morceaux orthogonaux, C = F ⊕ E :
%
%   (F) le sous-code FIXE : les mots c tels que σ(c) = c, c'est-à-dire CONSTANTS sur chaque
%       cycle. Un tel mot est décrit par c + f bits (un bit par cycle, un par point fixe) :
%       c'est un mot de C0 ≤ F2^(c+f). Si C est auto-dual, C0 l'est aussi, de dimension
%       h = (c+f)/2. Poids du mot relevé : p * (poids sur les cycles) + (poids sur les
%       points fixes).
%
%   (E) le sous-code des mots de poids PAIR sur chaque cycle et NULS sur les points fixes.
%       Dimension (p-1)c/2. Un bloc de p bits (un cycle) se lit comme un polynôme de
%       R = F2[x]/(x^p - 1), et σ agit comme la multiplication par x. Les blocs de poids
%       pair forment l'idéal I = (x+1)R, qui se décompose en corps finis :
%          T = 1 composante : I ≅ F_{2^(p-1)}           (p = 3, 5, 11, 13, ...)
%          T = 2 composantes conjuguées : I ≅ K1 ⊕ K2,
%                K1 ≅ K2 ≅ F_{2^((p-1)/2)}              (p = 7, 23, 47, ...)
%       Pour p = 7 : F2[x]/(x^7-1) ≅ F2 ⊕ F8 ⊕ F8 ; pour p = 5 : ≅ F2 ⊕ F16.
%       ε1 désigne l'unité du corps K1 (un polynôme idempotent : ε1² = ε1). La conjugaison
%       a(x) ↦ a(1/x) (renverser chaque cycle) échange K1 et K2 quand T = 2, et fixe K1
%       quand T = 1.
%
%  Le produit scalaire binaire, lu bloc par bloc, devient la forme « hermitienne »
%  H(u,v) = Σ_l u_l · conj(v_l) ∈ R : deux mots u, v de E sont orthogonaux ainsi que tous
%  leurs décalés σ^s si et seulement si H(u,v) = 0.
%
%   - T = 1 : E est un code K1-linéaire de longueur c, dimension c/2, auto-dual pour H.
%   - T = 2 : E = E1 ⊕ E2 avec E1 ≤ K1^c de dimension k (un PARAMÈTRE) et E2 ≤ K2^c
%     l'orthogonal de E1 pour H. Chacun est automatiquement isotrope (K1·K1 = 0 pour H),
%     donc l'auto-dualité de E se résume à « E2 = orthogonal de E1 ».
%
%  3. LES INCONNUES
%  ----------------
%  (F) A0 : une matrice h × (c+f) de bits, les lignes génératrices de C0. Pas de forme
%      systématique ici ; on pose la distance sur TOUTES les 2^h - 1 combinaisons de lignes
%      de C0 (h ≤ 8 en pratique, donc au plus 255), ce qui force les lignes à être
%      indépendantes.
%  (E) Forme SYSTÉMATIQUE sur les blocs. On permute les CYCLES (une permutation des
%      cycles commute avec σ, elle ne change ni les poids ni l'invariance) pour que les
%      kr premiers blocs portent un ensemble d'information de E1 :
%          lignes de E1 :  [ ε1·I_kr | M ]      M : kr × (c-kr) blocs, chacun dans K1
%      Quand T = 2, l'orthogonal se calcule à la main (pas d'inconnue de plus) :
%          lignes de E2 :  [ conj(M)^T | ε2·I_(c-kr) ]
%      (vérification : H(ligne r de E1, ligne s de E2) = M[r,s] + M[r,s] = 0 en car. 2).
%      Les générateurs BINAIRES d'une ligne ρ de E sont ses décalés x^s·ρ, s = 0..deg-1,
%      avec deg = dim K1 sur F2 ; x^s·ε1 (s < deg) est une base de K1 sur F2.
%      Total : h + (nombre de lignes de E)·deg = n/2 générateurs binaires.
%
%  4. LES CONTRAINTES
%  ------------------
%   (a) M est dans K1 : M = ε1·M (linéaire : un produit par une CONSTANTE est un XOR de
%       décalés). Quand T = 1, K1 = I et cela dit seulement « poids pair ».
%   (b) Auto-dualité : lignes de C0 deux à deux orthogonales (le facteur p est impair,
%       il disparaît modulo 2) ; si T = 1, H(ρ, ρ') = 0 pour toutes les lignes de E ;
%       si T = 2 rien à poser. F ⊥ E est automatique (bloc constant · bloc pair = 0).
%   (c) Doublement pair : chaque générateur binaire a un poids multiple de 4 (avec (b),
%       cela suffit pour tout le code). Un décalé a le poids de sa ligne : une contrainte
%       par ligne.
%   (d) Distance ≥ d, RELAXÉE comme dans code.mzn. Une « unité » est soit une ligne de C0
%       relevée, soit un multiple β·ρ d'une ligne ρ de E par un scalaire β ≠ 0 de K1,
%       c'est-à-dire un XOR non vide de décalés x^s·ρ. On pose « poids ≥ d » pour toute
%       somme d'au plus K unités venant de lignes DIFFÉRENTES (K ∈ 1..3), plus toutes les
%       combinaisons de C0. Une relaxation UNSAT reste un UNSAT valide : elle accepte plus
%       de codes que la vraie question.
%
%  5. HYPOTHÈSES ET BRISURES DE SYMÉTRIE (non certifiées, à garder en tête)
%  -----------------------------------------------------------------------
%   H1  Le type (c, f) de σ est pris dans la littérature (Conway–Pless 1982), pas prouvé ici.
%   H2  Forme systématique de E1 après permutation des cycles : sans perte de généralité
%       (argument du §3), mais admis, pas certifié.
%   H3  Quand T = 2 on peut supposer k ≤ c/2 : renverser chaque cycle (une permutation qui
%       conjugue σ en σ^-1, même groupe) échange E1 et E2, donc k et c - k. Feulner–Nebe
%       font la même réduction (« one of the two dual parameter sets »). C'est à
%       l'utilisateur de ne lancer que k ≤ c/2 ; le modèle accepte tout k.
%   H4  LEX = true : les lignes de A0 sont triées strictement décroissantes (ordre lex).
%       Valide : permuter les lignes génératrices de C0 ne change pas le code.
%   Pas d'autre brisure. Le centralisateur de σ (décalages x^t dans chaque cycle, S_kr ×
%   S_(c-kr) sur les blocs, S_f sur les points fixes) reste entièrement libre.
%
%  6. LES OPTIONS (-D "p=7;c=10;f=2;d=16;k=5;K=2;KS=0;LEX=true;nE=0;E=[];")
%  ------------------------------------------------------------------------
%     p, c, f : ordre de σ, nombre de p-cycles, nombre de points fixes.
%     d       : distance minimale voulue (multiple de 4).
%     k       : dimension de E1 sur K1 quand T = 2 (0..c). Quand T = 1, mettre k = c/2.
%     K       : taille max des sommes d'unités contraintes (1, 2 ou 3).
%     KS      : 0 = tous les scalaires β de K1 (2^deg - 1 par ligne, deg ≤ 16) ; sinon
%               seulement les β qui sont des XOR d'au plus KS décalés (1..3), pour les
%               grands p (p = 47 : deg = 23).
%     LEX     : brisure H4.
%     nE, E   : combinaisons de lignes de G ajoutées une par une par ../scripts/autcegar.py
%               (distance paresseuse, comme cegar.py pour code.mzn). Sinon "nE=0;E=[];".
%  Vérification indépendante d'une solution : python3 ../scripts/autcheck.py p c f < sortie
% =========================================================================================

include "lex_greater.mzn";

int: p;  int: c;  int: f;  int: d;  int: k;  int: K;  int: KS;  bool: LEX;
int: nE;  array[1..nE] of set of int: E;   % combinaisons paresseuses (autcegar.py)

int: n = p*c + f;
int: N2 = n div 2;                 % nombre de générateurs binaires
int: h = (c + f) div 2;            % dimension de C0 (le sous-code fixe)

% ---- L'anneau R = F2[x]/(x^p - 1) : un polynôme est un tableau de bits indexé 0..p-1 ----
function int: pow2mod(int: t) = if t = 0 then 1 mod p else (2 * pow2mod(t-1)) mod p endif;
int: deg = min([t | t in 1..p-1 where pow2mod(t) = 1]);   % ordre de 2 mod p = dim K1
int: T = (p - 1) div deg;                                 % nombre de composantes de I
set of int: Q = {(i*i) mod p | i in 1..p-1};              % résidus quadratiques mod p

% ε1 : l'unité de K1. T = 1 : ε1 = x + x² + ... + x^(p-1). T = 2 : ε1 = 1 + Σ_{i∈Q} x^i
% (Q est stable par i ↦ 2i, donc ε1(x)² = ε1(x²) = ε1 ; poids pair, donc ε1·(Σ x^i) = 0).
array[0..p-1] of bool: eps1 = array1d(0..p-1,
  if T = 1 then [i != 0 | i in 0..p-1] else [(i = 0) xor (i in Q) | i in 0..p-1] endif);
array[0..p-1] of bool: eps2 = array1d(0..p-1, [eps1[(p - i) mod p] | i in 0..p-1]);

function bool: parity(array[int] of bool: v) = sum(b in v)(bool2int(b)) mod 2 = 1;
function array[int] of bool: pmul(array[int] of bool: a, array[int] of bool: b) =
  array1d(0..p-1, [parity([a[j] /\ b[(i - j + p) mod p] | j in 0..p-1]) | i in 0..p-1]);

constraint assert(p >= 3 /\ forall(q in 2..p-1)(p mod q != 0), "p doit être premier impair");
constraint assert((c + f) mod 2 = 0, "c + f doit être pair");
constraint assert(d mod 4 = 0 /\ d > 0, "d doit être un multiple de 4");
constraint assert(T = 1 \/ (T = 2 /\ p mod 8 = 7),
  "seuls T = 1 (2 primitif mod p) et T = 2 avec p ≡ 7 mod 8 (K1, K2 conjugués) sont codés");
constraint assert(T = 2 \/ (c mod 2 = 0 /\ k = c div 2), "T = 1 : il faut c pair et k = c/2");
constraint assert(k >= 0 /\ k <= c, "0 ≤ k ≤ c");
constraint assert(forall(i in 0..p-1)(pmul(eps1, eps1)[i] = eps1[i]), "ε1 n'est pas idempotent");
constraint assert(T = 1 \/ forall(i in 0..p-1)(not pmul(eps1, eps2)[i]), "ε1·ε2 ≠ 0");
constraint assert(K >= 1 /\ K <= 3 /\ KS >= 0 /\ KS <= 3, "K ∈ 1..3, KS ∈ 0..3");
constraint assert(KS > 0 \/ deg <= 16, "KS = 0 énumère 2^deg scalaires : prendre KS ≥ 1");
constraint assert(h <= 12, "h > 12 : trop de combinaisons de C0");

% XOR d'un tableau de booléens (arbre équilibré ; les constantes sont simplifiées)
function var bool: xr(array[int] of var bool: v) =
  let { int: m = length(v); array[1..m] of var bool: w = array1d(1..m, v) } in
  if m = 0 then false elseif m = 1 then w[1]
  else xr(w[1..m div 2]) xor xr(w[m div 2 + 1..m]) endif;

int: kr = k;                       % lignes de E1 (T = 1 : k = c/2, c'est tout E)
int: NR = if T = 1 then kr else c endif;   % lignes de E sur K1 (et K2)
constraint assert(h + NR * deg = N2, "dimension totale ≠ n/2");

% ---- LES INCONNUES ----
array[1..h, 1..c+f] of var bool: A0;                 % C0 : bits par cycle, puis points fixes
array[1..kr, 1..c-kr, 0..p-1] of var bool: M;        % partie libre de E1, blocs dans K1

% (a) M[r,j] ∈ K1
constraint forall(r in 1..kr, j in 1..c-kr)(
  if T = 1 then not xr([M[r,j,i] | i in 0..p-1])                       % poids pair
  else forall(i in 0..p-1)(M[r,j,i] = xr([M[r,j,(i-a+p) mod p] | a in 0..p-1 where eps1[a]]))
  endif);

% B[e, l, i] : bit i du bloc l de la ligne e de E (e ≤ kr : E1 ; e > kr : E2 si T = 2)
array[1..NR, 1..c, 0..p-1] of var bool: B = array3d(1..NR, 1..c, 0..p-1, [
  if e <= kr then
    if l <= kr then (l = e /\ eps1[i]) else M[e, l-kr, i] endif
  else
    if l <= kr then M[l, e-kr, (p - i) mod p] else (l = e /\ eps2[i]) endif
  endif | e in 1..NR, l in 1..c, i in 0..p-1]);

% G : la matrice génératrice binaire complète, n/2 × n.
%   ligne g ≤ h           : ligne g de C0 relevée (bit répété p fois sur chaque cycle)
%   ligne h+(e-1)deg+s+1  : x^s · (ligne e de E), nulle sur les points fixes
function int: gen(int: e, int: s) = h + (e-1)*deg + s + 1;
array[1..N2, 1..n] of var bool: G = array2d(1..N2, 1..n, [
  if g <= h then
    (if q <= p*c then A0[g, (q-1) div p + 1] else A0[g, c + q - p*c] endif)
  else
    (if q <= p*c then B[(g-h-1) div deg + 1, (q-1) div p + 1,
                        ((q-1) mod p - (g-h-1) mod deg + p) mod p]
     else false endif)
  endif | g in 1..N2, q in 1..n]);

% ---- (b) auto-dualité ----
constraint forall(a, b in 1..h where a < b)(
  not xr([A0[a,l] /\ A0[b,l] | l in 1..c+f]));
% T = 1 : H(ρ_e, ρ_e') = 0, coefficient par coefficient (coefficient s = produit scalaire
% binaire de x^s·ρ_e avec ρ_e'). Pour e = e', s et -s donnent la même équation.
constraint if T = 1 then
  forall(e1, e2 in 1..NR, s in 0..p-1 where e1 < e2 \/ (e1 = e2 /\ s >= 1 /\ 2*s < p))(
    not xr([B[e1,l,(i-s+p) mod p] /\ B[e2,l,i] | l in 1..c, i in 0..p-1]))
  else true endif;

% ---- (c) doublement pair : un poids multiple de 4 par ligne ----
constraint forall(g in 1..h)(
  (p * sum(l in 1..c)(bool2int(A0[g,l])) + sum(j in 1..f)(bool2int(A0[g,c+j]))) mod 4 = 0);
constraint forall(e in 1..NR)(sum(l in 1..c, i in 0..p-1)(bool2int(B[e,l,i])) mod 4 = 0);

% ---- (d) distance, relaxée ----
% Scalaires β ≠ 0 de K1, vus comme ensembles de décalés s ∈ 0..deg-1 à additionner.
array[int] of set of int: SC =
  if KS = 0 then [ {s | s in 0..deg-1 where (m div pow(2, s)) mod 2 = 1} | m in 1..pow(2, deg)-1 ]
  else [ {a} | a in 0..deg-1 ]
    ++ [ {a, b} | a, b in 0..deg-1 where a < b /\ KS >= 2 ]
    ++ [ {a, b, z} | a, b, z in 0..deg-1 where a < b /\ b < z /\ KS >= 3 ] endif;
% Unités : (ligne d'origine, ensemble de générateurs binaires à XORer)
array[int] of int: urow = [ r | r in 1..h ] ++ [ h + e | e in 1..NR, m in index_set(SC) ];
array[int] of set of int: ugen = [ {r} | r in 1..h ]
  ++ [ {gen(e, s) | s in SC[m]} | e in 1..NR, m in index_set(SC) ];
int: NU = length(urow);
array[1..NU, 1..n] of var bool: UB =
  array2d(1..NU, 1..n, [ xr([G[g,q] | g in ugen[u]]) | u in 1..NU, q in 1..n ]);
% Paires et triplets d'unités de lignes différentes (les triplets réutilisent les paires)
array[int] of int: P2a = [ u1 | u1, u2 in 1..NU where K >= 2 /\ urow[u1] < urow[u2] ];
array[int] of int: P2b = [ u2 | u1, u2 in 1..NU where K >= 2 /\ urow[u1] < urow[u2] ];
array[1..length(P2a), 1..n] of var bool: PB = array2d(1..length(P2a), 1..n,
  [ UB[P2a[t], q] xor UB[P2b[t], q] | t in index_set(P2a), q in 1..n ]);
array[int] of int: T3p = [ t | t in index_set(P2a), u in 1..NU where K >= 3 /\ urow[u] > urow[P2b[t]] ];
array[int] of int: T3u = [ u | t in index_set(P2a), u in 1..NU where K >= 3 /\ urow[u] > urow[P2b[t]] ];
array[1..length(T3p), 1..n] of var bool: TB = array2d(1..length(T3p), 1..n,
  [ PB[T3p[t], q] xor UB[T3u[t], q] | t in index_set(T3p), q in 1..n ]);
% Combinaisons de C0 de plus de K lignes (celles d'au plus K lignes sont déjà ci-dessus)
array[int] of set of int: FS = [ S | m in 1..pow(2, h)-1,
  S in [{r | r in 1..h where (m div pow(2, r-1)) mod 2 = 1}] where card(S) > K ];

constraint forall(u in 1..NU)(sum(q in 1..n)(bool2int(UB[u,q])) >= d);
constraint forall(t in index_set(P2a))(sum(q in 1..n)(bool2int(PB[t,q])) >= d);
constraint forall(t in index_set(T3p))(sum(q in 1..n)(bool2int(TB[t,q])) >= d);
constraint forall(S in FS)(
  p * sum(l in 1..c)(bool2int(xr([A0[r,l] | r in S])))
  + sum(j in 1..f)(bool2int(xr([A0[r,c+j] | r in S]))) >= d);

% Combinaisons de générateurs binaires (indices de lignes de G) ajoutées par autcegar.py :
% même contrainte de poids. Mettre "nE=0;E=[];" sinon.
% (parité linéaire plutôt que l'arbre xr : avec des milliers d'ensembles E de taille ~25,
%  l'arbre fait planter l'aplatissement de MiniZinc 2.10.1, segfault mesuré le 2026-11-18)
function var bool: xlin(array[int] of var bool: v) =
  let { var bool: b; var 0..length(v) div 2: z;
        constraint sum(x in v)(bool2int(x)) = 2 * z + bool2int(b) } in b;
constraint forall(e in 1..nE)(sum(q in 1..n)(bool2int(xlin([G[g,q] | g in E[e]]))) >= d);

% ---- H4 : lignes de C0 strictement décroissantes ----
constraint if LEX then forall(r in 1..h-1)(lex_greater(row(A0, r), row(A0, r+1))) else true endif;

solve satisfy;
output [ "G " ++ concat([ if fix(G[g,q]) then "1" else "0" endif | q in 1..n ]) ++ "\n" | g in 1..N2 ];
