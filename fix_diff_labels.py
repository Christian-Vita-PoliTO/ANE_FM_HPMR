#!/usr/bin/env python3
"""Rende compilabile l'output di latexdiff quando un'etichetta e' stata spostata.

latexdiff conserva le \\label anche dentro i blocchi cancellati. Se nel manoscritto
un'etichetta e' stata spostata da un punto all'altro, nel file delle differenze
risulta definita due volte e amsmath si ferma con "Multiple \\label's".

Qui le etichette che compaiono dentro un blocco cancellato vengono tolte: nessuno
le riferisce, e latexdiff rende quei blocchi con align* dove un'etichetta non e'
comunque ammessa. I riferimenti continuano a puntare alla definizione viva.
"""
import re
import sys

PATH = sys.argv[1] if len(sys.argv) > 1 else "diff_v1_v2.tex"

# i blocchi cancellati esistono in due varianti, quella normale e quella per i float
BLOCK = re.compile(
    r"\\DIFdelbegin(?:FL)?(?![a-zA-Z]).*?\\DIFdelend(?:FL)?(?![a-zA-Z])", re.S
)
# un'etichetta che occupa da sola una riga va tolta insieme alla riga: lasciare
# una riga vuota dentro \DIFdel{...} equivale a un \par e rompe la formula
LABEL_LINE = re.compile(r"(?m)^[ \t]*\\label\{[^}]*\}[ \t]*\n")
LABEL = re.compile(r"\\label\{[^}]*\}")

text = open(PATH).read()
renamed = 0


def strip(match):
    global renamed
    block = match.group(0)
    block, a = LABEL_LINE.subn("", block)
    block, b = LABEL.subn("", block)
    renamed += a + b
    return block


out = BLOCK.sub(strip, text)

# la versione sottomessa usava una chiave bibliografica con caratteri non ASCII,
# corretta poi nel manoscritto: nel testo cancellato riapparirebbe e romperebbe natbib
out, fixed = re.subn(r"Punger\u010di\u010d", "Pungercic", out)
if fixed:
    print("  chiavi bibliografiche non ASCII corrette: %d" % fixed)
if out != text:
    open(PATH, "w").write(out)
print("  etichette rimosse dai blocchi cancellati: %d" % renamed)
