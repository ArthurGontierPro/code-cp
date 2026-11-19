# État courant

À mettre à jour en fin de session. L'historique jour par jour est dans `STATUS.md` et `RESULTS.md`.

## Au 19/11 au soir

Rien ne tourne sur le nœud pour codes-cp. Les runs P48 (énumération `equivcount` et baguette b1 avec
l'ancien binaire) ont été arrêtés le 19/11. Ils n'apportaient rien de neuf et l'ancien binaire est 2 à 5
fois plus lent que b403e28.

### Fait le 19/11

- Le benchmark, phase 1, première passe : 115 instances (P1 distance minimale, P3 existence de codes),
  27 configurations de solveurs, 2 687 runs de 10 min, sans preuve. Aucune réponse fausse. Les
  résultats sont dans `benchmark/results/phase1-p1/` sur le nœud, lus avec `benchmark/run/score.py` et
  `benchmark/run/best.py`. En bref :
  - P1 décision : CryptoMiniSat (60 sur 64) puis Kissat, CaDiCaL, RoundingSat et SCIP (57), Gurobi,
    HiGHS ; les solveurs CP entre 42 et 50 ; baguette 39 (sommes) et 36 (XOR).
  - P1 optimisation : Gurobi n'est battu par aucun solveur MaxSAT, et il trouve les mots plus vite que
    RoundingSat, qui prouve mieux les UNSAT.
  - P3 : la brisure de symétrie de l'article AAAI-26 fait presque tout (Kissat 30 sur 32 avec, 15 sans).
  - baguette avec ses options M10 (`baguette-act`) ne fait pas mieux que par défaut (40 et 31). L'écart
    avec Gecode, qui n'apprend rien, vient du coût de propagation par nœud.
- La chaîne de dominance (`dom/`) : preuves fusionnées vérifiées pour Hamming, Golay et QR48.
- Le rapport `dom/report.md` (anglais, provisoire) sur QR48 et pourquoi baguette y apprend mieux avec
  les sommes.
- Deux pistes ajoutées à la roadmap de baguette (M13-codes-leads) : une relaxation linéaire comme étape
  de presolve, la détection de symétries.

### Reste à faire

1. Finir `dom/report.md` avec :
   - les résultats x3 (baguette b403e28, réglages `def`, `-f`, `act`, toutes les preuves vérifiées,
     dans `results/runs/X3_*`) ;
   - les gros codes en SAT (`results/runs/SB_*`) : QR80 sans symétrie résolu par CryptoMiniSat seul
     (1 064 s avec XOR natifs, 1 639 s sur clauses), QR104 résolu par personne en 1 h ;
   - la classification des 588 lignes apprises (`dom/learnedlp_p47.txt`) : 85 en A, 203 en B, 0 en C,
     300 en D. Aucune n'est une conséquence linéaire de toutes les équations, la moitié a demandé un
     arrondi.
2. La seconde passe du benchmark à 1 h, sur les instances que personne n'a résolues ou qu'un seul
   solveur a résolues.
3. Mesurer les nœuds par seconde de baguette, Chuffed et Gecode sur quelques instances P1, pour savoir
   quelle partie de la propagation coûte.
4. GaussMaxHS (MaxSAT avec XOR natifs), si une licence CPLEX est disponible.
5. Si on le veut, relancer la certification P48 avec baguette b403e28 ou plus récent.

### Questions ouvertes

- Comparer Gauss et les sommes dans baguette sur le même modèle. La session parité de baguette
  (M12-parity-T1, branche `wave49-parity`) refait sa mesure sur le modèle orbite.
