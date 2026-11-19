# codes-cp, pour une session Claude

Ce fichier dit où trouver chaque chose et les règles qui ne se discutent pas. Le reste est dans les
fichiers par sujet ci-dessous, à lire selon la tâche plutôt que d'un bloc.

## Où lire quoi

| sujet | fichier |
|---|---|
| le but du projet et ce qui vient ensuite | `ROADMAP.md` |
| l'état courant, ce qui tourne, ce qui reste à faire | `notes/etat.md` (à mettre à jour en fin de session) |
| la machine, ce qui y tourne d'autre, où sont les outils | `notes/noeud.md` |
| comment on travaille (mesures, choix des solveurs, agents) | `notes/methode.md` |
| les résultats et le tutoriel | `RESULTS.md` |
| le benchmark multi-paradigmes | `notes/benchmark-plan.md`, `benchmark/README.md` |
| la preuve des symétries par la règle de dominance | `dom/README.md`, `dom/report.md` |

## Règles

- Le dépôt est public (github.com/ArthurGontierPro/code-cp). Jamais de PDF d'article (ils sont
  ignorés par git et restent dans `papers/`), jamais de données privées, jamais d'adresse mail ni de
  clé ou de fichier de licence.
- Les règles de la machine (tuer par PID, parallélisme, mémoire) sont dans le `~/.claude/CLAUDE.md` du
  nœud. Propre à ce projet : les runs `ladbug` (`/scratch/arthur/ladbug-*`) ne sont pas à nous, et
  `benchmark/run/campaign.sh` applique déjà la limite de 92 runs à 32 Go chacun.
- `/scratch` peut être effacé. En fin de session, `bash scripts/save.sh` copie sur `/cluster` ce que git
  ne contient pas (voir `notes/noeud.md`).
- On ne commite que des chemins explicites, jamais `git add -A`. Les messages de commit finissent par
  la ligne `Co-Authored-By` de la session.
- La direction est les réseaux extrémaux en dimension 24k. On ne cherche pas à certifier l'article
  AAAI-26 sur les codes, qui sert seulement de benchmark.
