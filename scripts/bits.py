"""HISTORIQUE (16/11) : première journée, ancien dossier /scratch/arthur/golay du nœud, modèle code.mzn ou golay.mzn. Gardé pour reproduire STATUS.md (16/11).

bits.py < solver output -> the A matrix as one line of 0/1 (for mindist)."""
import re, sys
m = re.search(r'\[((?:\s*(?:true|false),)+\s*(?:true|false))\]', sys.stdin.read())
if not m: sys.exit("no A")
print("".join("1" if v.strip() == "true" else "0" for v in m.group(1).split(",")))
