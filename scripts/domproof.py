"""domproof.py -- shared part of dommerge.py and domlex.py: splice dominance steps into a baguette proof.

baguette labels every constraint (@c1, @c2, ...) and its proof refers to constraints only by these
labels. So a constraint of the .opb can be removed from the .opb and derived again, under the same
label, at the head of the proof, and baguette's proof then continues unchanged.
"""
import re


def opb_lines(opb):
    """(all lines, {label: body}) of a baguette .opb"""
    O = open(opb).read().splitlines()
    body = {l.split(" ", 1)[0]: l.split(" ", 1)[1] for l in O if l.startswith("@c")}
    return O, body


def opb_vars(bodies):
    return set(re.findall(r"~?([A-Za-z_]\w*)", " ".join(bodies)))


def def_order(name, N, coef):
    """an order on N variables: u <= v iff sum coef[p] * (v_p - u_p) >= 0 (a weighted sum, e.g. lex)"""
    terms = " ".join(f"{-c} u{p + 1}" for p, c in enumerate(coef)) + " " + \
            " ".join(f"{c} v{p + 1}" for p, c in enumerate(coef))
    us = " ".join(f"u{p + 1}" for p in range(N)); vs = " ".join(f"v{p + 1}" for p in range(N))
    ws = " ".join(f"w{p + 1}" for p in range(N))
    return [f"def_order {name}", "  vars", f"    left {us};", f"    right {vs};", "    aux;", "  end;",
            "  def", f"    {terms} >= 0;", "  end;",
            "  transitivity", "    vars", f"      fresh_right {ws};", "    end;", "    proof",
            "      proofgoal #1", "        pol 1 2 + 3 +;", "      qed : -1;", "    qed;", "  end;", "end;"]


def merge(opb, pbp, out, order, load, steps, title):
    """steps: [(label, witness)] or [(label, witness, subproof lines)] in proof order; each labelled
    constraint leaves the .opb and is derived by `label dom body : witness ;`, followed by the
    subproof when there is one. order: def_order lines, load: the load_order line."""
    O, body = opb_lines(opb)
    steps = [st if len(st) == 3 else (st[0], st[1], None) for st in steps]
    removed = {st[0] for st in steps}
    assert removed <= set(body), "a step names a label that is not in the .opb"
    left = len(body) - len(removed)
    keep = [re.sub(r"#constraint= \d+", f"#constraint= {left}", l) for l in O
            if not (l.startswith("@c") and l.split(" ", 1)[0] in removed)]
    open(out + ".opb", "w").write("\n".join(keep) + "\n")
    P = open(pbp).read().splitlines()
    assert P[1].startswith("f "), P[1]
    head = [P[0], f"f {left} ;", f"% ---- {title} ----"] + order + [load]
    for lab, w, sub in steps:
        if sub is None:
            head.append(f"{lab} dom {body[lab].rstrip(' ;')} : {w} ;")
        else:
            head += [f"{lab} dom {body[lab].rstrip(' ;')} : {w} : subproof"] + sub + ["qed;"]
    head += ["load_order;", "% ---- baguette's proof, unchanged ----"]
    open(out + ".pbp", "w").write("\n".join(head + P[2:]) + "\n")
    return len(removed), left
